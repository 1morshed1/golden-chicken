import logging
from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.gemini_client import GeminiClient, gemini_client
from app.ai.intent import classify_intent
from app.ai.prompts.system_prompt import get_system_prompt
from app.ai.rag.retriever import Retriever
from app.config import settings
from app.core.exceptions import AuthorizationError, NotFoundError
from app.models.chat import ChatMessage, ChatSession, MessageRole
from app.models.user import User
from app.repositories.chat_repository import ChatMessageRepository, ChatSessionRepository

logger = logging.getLogger(__name__)

session_repo = ChatSessionRepository()
message_repo = ChatMessageRepository()


class ChatService:
    def __init__(self, gemini: GeminiClient, retriever: Retriever | None = None):
        self.gemini = gemini
        self._retriever = retriever

    @property
    def retriever(self) -> Retriever:
        if self._retriever is None:
            self._retriever = Retriever()
        return self._retriever

    async def create_session(
        self, db: AsyncSession, user: User, title: str | None = None
    ) -> ChatSession:
        return await session_repo.create(
            db, user_id=user.id, title=title or "New Chat"
        )

    async def get_user_sessions(
        self, db: AsyncSession, user: User, *, offset: int = 0, limit: int = 20
    ) -> tuple[list[ChatSession], int]:
        sessions = await session_repo.get_user_sessions(
            db, user.id, offset=offset, limit=limit
        )
        total = await session_repo.count_user_sessions(db, user.id)
        return sessions, total

    async def get_session(
        self, db: AsyncSession, session_id: str, user: User
    ) -> ChatSession:
        session = await session_repo.get_with_messages(db, session_id)
        if not session:
            raise NotFoundError("Chat session")
        if session.user_id != user.id:
            raise AuthorizationError()
        return session

    async def update_session_title(
        self, db: AsyncSession, session_id: str, user: User, title: str
    ) -> ChatSession:
        session = await session_repo.get_by_id(db, session_id)
        if not session:
            raise NotFoundError("Chat session")
        if session.user_id != user.id:
            raise AuthorizationError()
        return await session_repo.update_title(db, session, title)

    async def delete_session(
        self, db: AsyncSession, session_id: str, user: User
    ) -> None:
        session = await session_repo.get_by_id(db, session_id)
        if not session:
            raise NotFoundError("Chat session")
        if session.user_id != user.id:
            raise AuthorizationError()
        await session_repo.soft_delete(db, session)

    async def send_message(
        self,
        db: AsyncSession,
        session_id: str,
        user: User,
        content: str,
        language: str = "en",
    ) -> tuple[ChatMessage, ChatMessage]:
        session = await session_repo.get_by_id(db, session_id)
        if not session or not session.is_active:
            raise NotFoundError("Chat session")
        if session.user_id != user.id:
            raise AuthorizationError()

        user_msg = await message_repo.create_message(
            db, session_id=session_id, role=MessageRole.USER, content=content
        )

        intent = await classify_intent(content, self.gemini)

        rag_context = None
        try:
            rag_context = await self.retriever.retrieve_and_build(
                db, content, category=intent
            )
        except Exception:
            logger.warning("RAG retrieval failed, proceeding without context", exc_info=True)

        history = await message_repo.get_recent_messages(db, session_id, limit=10)
        chat_history = self._format_history(history)
        system_prompt = get_system_prompt(language)

        ai_text = await self.gemini.generate_text(
            system_prompt=system_prompt,
            user_message=content,
            chat_history=chat_history,
            context=rag_context,
        )

        ai_msg = await message_repo.create_message(
            db,
            session_id=session_id,
            role=MessageRole.ASSISTANT,
            content=ai_text,
            message_metadata={
                "intent": intent,
                "model": settings.GEMINI_TEXT_MODEL,
                "rag_used": rag_context is not None,
            },
        )

        msg_count = await message_repo.count_messages(db, session_id)
        if msg_count <= 2:
            title = await self.gemini.generate_title(content)
            await session_repo.update_title(db, session, title)

        return user_msg, ai_msg

    async def send_message_stream(
        self,
        db: AsyncSession,
        session_id: str,
        user: User,
        content: str,
        language: str = "en",
    ) -> AsyncGenerator[str, None]:
        session = await session_repo.get_by_id(db, session_id)
        if not session or not session.is_active:
            raise NotFoundError("Chat session")
        if session.user_id != user.id:
            raise AuthorizationError()

        user_msg = await message_repo.create_message(
            db, session_id=session_id, role=MessageRole.USER, content=content
        )
        await db.commit()

        intent = await classify_intent(content, self.gemini)

        rag_context = None
        try:
            rag_context = await self.retriever.retrieve_and_build(
                db, content, category=intent
            )
        except Exception:
            logger.warning("RAG retrieval failed during stream, proceeding without context", exc_info=True)

        history = await message_repo.get_recent_messages(db, session_id, limit=10)
        chat_history = self._format_history(history)
        system_prompt = get_system_prompt(language)

        full_response = []
        async for chunk in self.gemini.generate_text_stream(
            system_prompt=system_prompt,
            user_message=content,
            chat_history=chat_history,
            context=rag_context,
        ):
            full_response.append(chunk)
            yield chunk

        ai_text = "".join(full_response)
        await message_repo.create_message(
            db,
            session_id=session_id,
            role=MessageRole.ASSISTANT,
            content=ai_text,
            message_metadata={
                "intent": intent,
                "model": settings.GEMINI_TEXT_MODEL,
                "rag_used": rag_context is not None,
            },
        )

        msg_count = await message_repo.count_messages(db, session_id)
        if msg_count <= 2:
            title = await self.gemini.generate_title(content)
            await session_repo.update_title(db, session, title)

        await db.commit()

    async def diagnose_image(
        self,
        db: AsyncSession,
        user: User,
        image_bytes: bytes,
        mime_type: str,
        image_url: str,
        additional_notes: str | None = None,
        language: str = "en",
    ) -> dict:
        from app.ai.prompts.disease_diagnosis import get_diagnosis_prompt

        session = await session_repo.create(
            db, user_id=user.id, title="Disease Diagnosis"
        )

        user_content = additional_notes or "Please analyze this image for disease signs."
        user_msg = await message_repo.create_message(
            db,
            session_id=session.id,
            role=MessageRole.USER,
            content=user_content,
            message_metadata={"image_url": image_url},
        )

        rag_context = None
        try:
            rag_context = await self.retriever.retrieve_and_build(
                db, user_content, category="disease_diagnosis"
            )
        except Exception:
            logger.warning("RAG retrieval failed during diagnosis", exc_info=True)

        diagnosis_prompt = get_diagnosis_prompt(language)
        diagnosis = await self.gemini.analyze_image(
            image_bytes=image_bytes,
            mime_type=mime_type,
            prompt=diagnosis_prompt,
            context=rag_context,
        )

        ai_msg = await message_repo.create_message(
            db,
            session_id=session.id,
            role=MessageRole.ASSISTANT,
            content=diagnosis,
            message_metadata={
                "intent": "disease_diagnosis",
                "model": settings.GEMINI_TEXT_MODEL,
                "rag_used": rag_context is not None,
                "image_diagnosis": True,
            },
        )

        title = await self.gemini.generate_title(user_content)
        await session_repo.update_title(db, session, title)

        return {
            "session_id": session.id,
            "user_message_id": user_msg.id,
            "ai_message_id": ai_msg.id,
            "diagnosis": diagnosis,
            "image_url": image_url,
            "intent": "disease_diagnosis",
            "rag_used": rag_context is not None,
        }

    async def update_feedback(
        self, db: AsyncSession, message_id: str, user: User, feedback: int
    ) -> ChatMessage:
        message = await message_repo.get_by_id(db, message_id)
        if not message:
            raise NotFoundError("Message")
        session = await session_repo.get_by_id(db, message.session_id)
        if not session or session.user_id != user.id:
            raise AuthorizationError()
        return await message_repo.update_feedback(db, message, feedback)

    def _format_history(self, messages: list[ChatMessage]) -> list[dict]:
        return [
            {"role": msg.role.value if msg.role != MessageRole.SYSTEM else "user", "content": msg.content}
            for msg in messages
        ]


chat_service = ChatService(gemini_client)
