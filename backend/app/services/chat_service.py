from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.gemini_client import GeminiClient, gemini_client
from app.ai.intent import classify_intent
from app.ai.prompts.system_prompt import get_system_prompt
from app.config import settings
from app.core.exceptions import AuthorizationError, NotFoundError
from app.models.chat import ChatMessage, ChatSession, MessageRole
from app.models.user import User
from app.repositories.chat_repository import ChatMessageRepository, ChatSessionRepository


session_repo = ChatSessionRepository()
message_repo = ChatMessageRepository()


class ChatService:
    def __init__(self, gemini: GeminiClient):
        self.gemini = gemini

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
        history = await message_repo.get_recent_messages(db, session_id, limit=10)
        chat_history = self._format_history(history)
        system_prompt = get_system_prompt(language)

        ai_text = await self.gemini.generate_text(
            system_prompt=system_prompt,
            user_message=content,
            chat_history=chat_history,
        )

        ai_msg = await message_repo.create_message(
            db,
            session_id=session_id,
            role=MessageRole.ASSISTANT,
            content=ai_text,
            message_metadata={
                "intent": intent,
                "model": settings.GEMINI_TEXT_MODEL,
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
        history = await message_repo.get_recent_messages(db, session_id, limit=10)
        chat_history = self._format_history(history)
        system_prompt = get_system_prompt(language)

        full_response = []
        async for chunk in self.gemini.generate_text_stream(
            system_prompt=system_prompt,
            user_message=content,
            chat_history=chat_history,
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
            },
        )

        msg_count = await message_repo.count_messages(db, session_id)
        if msg_count <= 2:
            title = await self.gemini.generate_title(content)
            await session_repo.update_title(db, session, title)

        await db.commit()

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
