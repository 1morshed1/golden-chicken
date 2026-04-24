from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    def __init__(self):
        super().__init__(User)

    async def get_by_email(self, db: AsyncSession, email: str) -> User | None:
        stmt = select(User).where(User.email == email)
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_google_id(self, db: AsyncSession, google_id: str) -> User | None:
        stmt = select(User).where(User.google_id == google_id)
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_facebook_id(self, db: AsyncSession, facebook_id: str) -> User | None:
        stmt = select(User).where(User.facebook_id == facebook_id)
        result = await db.execute(stmt)
        return result.scalar_one_or_none()
