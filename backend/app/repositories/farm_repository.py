from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.farm import Farm, Shed
from app.repositories.base import BaseRepository


class FarmRepository(BaseRepository[Farm]):
    def __init__(self):
        super().__init__(Farm)

    async def get_user_farms(self, db: AsyncSession, user_id: str) -> list[Farm]:
        stmt = (
            select(Farm)
            .where(Farm.user_id == user_id, Farm.is_active.is_(True))
            .options(selectinload(Farm.sheds))
            .order_by(Farm.created_at.desc())
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_farm_with_sheds(self, db: AsyncSession, farm_id: str) -> Farm | None:
        stmt = (
            select(Farm)
            .where(Farm.id == farm_id)
            .options(selectinload(Farm.sheds))
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def get_sheds_count(self, db: AsyncSession, farm_id: str) -> int:
        stmt = select(func.count()).select_from(Shed).where(
            Shed.farm_id == farm_id, Shed.is_active.is_(True)
        )
        result = await db.execute(stmt)
        return result.scalar_one()


class ShedRepository(BaseRepository[Shed]):
    def __init__(self):
        super().__init__(Shed)

    async def get_farm_sheds(self, db: AsyncSession, farm_id: str) -> list[Shed]:
        stmt = (
            select(Shed)
            .where(Shed.farm_id == farm_id, Shed.is_active.is_(True))
            .order_by(Shed.created_at.desc())
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())
