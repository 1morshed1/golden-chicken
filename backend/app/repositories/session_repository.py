from datetime import datetime, timezone

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user_session import UserSession
from app.repositories.base import BaseRepository


class SessionRepository(BaseRepository[UserSession]):
    def __init__(self):
        super().__init__(UserSession)

    async def get_by_token_hash(
        self, db: AsyncSession, token_hash: str
    ) -> UserSession | None:
        stmt = select(UserSession).where(
            UserSession.refresh_token_hash == token_hash,
            UserSession.revoked.is_(False),
            UserSession.expires_at > datetime.now(timezone.utc),
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_jti(self, db: AsyncSession, jti: str) -> UserSession | None:
        stmt = select(UserSession).where(UserSession.jti == jti)
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def revoke(self, db: AsyncSession, session: UserSession) -> None:
        session.revoked = True
        await db.flush()

    async def revoke_all_for_user(self, db: AsyncSession, user_id: str) -> int:
        stmt = (
            update(UserSession)
            .where(
                UserSession.user_id == user_id,
                UserSession.revoked.is_(False),
            )
            .values(revoked=True)
        )
        result = await db.execute(stmt)
        await db.flush()
        return result.rowcount
