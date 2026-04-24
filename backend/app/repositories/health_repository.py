from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.health import HealthTab
from app.repositories.base import BaseRepository


class HealthTabRepository(BaseRepository[HealthTab]):
    def __init__(self):
        super().__init__(HealthTab)

    async def get_active_tabs(
        self, db: AsyncSession, *, category: str | None = None
    ) -> list[HealthTab]:
        stmt = (
            select(HealthTab)
            .where(HealthTab.is_active == True)
            .order_by(HealthTab.sort_order.asc())
        )
        if category:
            stmt = stmt.where(HealthTab.category == category)
        result = await db.execute(stmt)
        return list(result.scalars().all())
