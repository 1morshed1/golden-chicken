from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.chat import ChatMessage, ChatSession, MessageRole
from app.repositories.base import BaseRepository


class ChatSessionRepository(BaseRepository[ChatSession]):
    def __init__(self):
        super().__init__(ChatSession)

    async def get_user_sessions(
        self, db: AsyncSession, user_id: str, *, offset: int = 0, limit: int = 20
    ) -> list[ChatSession]:
        stmt = (
            select(ChatSession)
            .where(ChatSession.user_id == user_id, ChatSession.is_active == True)
            .order_by(ChatSession.updated_at.desc())
            .offset(offset)
            .limit(limit)
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def count_user_sessions(self, db: AsyncSession, user_id: str) -> int:
        stmt = (
            select(func.count())
            .select_from(ChatSession)
            .where(ChatSession.user_id == user_id, ChatSession.is_active == True)
        )
        result = await db.execute(stmt)
        return result.scalar_one()

    async def get_with_messages(
        self, db: AsyncSession, session_id: str
    ) -> ChatSession | None:
        stmt = (
            select(ChatSession)
            .options(selectinload(ChatSession.messages))
            .where(ChatSession.id == session_id)
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def update_title(
        self, db: AsyncSession, session: ChatSession, title: str
    ) -> ChatSession:
        session.title = title
        await db.flush()
        await db.refresh(session)
        return session


class ChatMessageRepository(BaseRepository[ChatMessage]):
    def __init__(self):
        super().__init__(ChatMessage)

    async def get_session_messages(
        self, db: AsyncSession, session_id: str, *, limit: int = 50
    ) -> list[ChatMessage]:
        stmt = (
            select(ChatMessage)
            .where(ChatMessage.session_id == session_id)
            .order_by(ChatMessage.created_at.asc())
            .limit(limit)
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_recent_messages(
        self, db: AsyncSession, session_id: str, *, limit: int = 10
    ) -> list[ChatMessage]:
        stmt = (
            select(ChatMessage)
            .where(ChatMessage.session_id == session_id)
            .order_by(ChatMessage.created_at.desc())
            .limit(limit)
        )
        result = await db.execute(stmt)
        return list(reversed(result.scalars().all()))

    async def count_messages(self, db: AsyncSession, session_id: str) -> int:
        stmt = (
            select(func.count())
            .select_from(ChatMessage)
            .where(ChatMessage.session_id == session_id)
        )
        result = await db.execute(stmt)
        return result.scalar_one()

    async def create_message(
        self,
        db: AsyncSession,
        *,
        session_id: str,
        role: MessageRole,
        content: str,
        image_url: str | None = None,
        message_metadata: dict | None = None,
    ) -> ChatMessage:
        return await self.create(
            db,
            session_id=session_id,
            role=role,
            content=content,
            image_url=image_url,
            message_metadata=message_metadata,
        )

    async def update_feedback(
        self, db: AsyncSession, message: ChatMessage, feedback: int
    ) -> ChatMessage:
        message.feedback = feedback
        await db.flush()
        await db.refresh(message)
        return message
