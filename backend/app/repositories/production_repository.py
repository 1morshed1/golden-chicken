from datetime import date

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.production import ChickenRecord, EggRecord
from app.repositories.base import BaseRepository


class EggRecordRepository(BaseRepository[EggRecord]):
    def __init__(self):
        super().__init__(EggRecord)

    async def get_by_shed_and_date_range(
        self,
        db: AsyncSession,
        shed_id: str,
        date_from: date | None = None,
        date_to: date | None = None,
    ) -> list[EggRecord]:
        stmt = select(EggRecord).where(EggRecord.shed_id == shed_id)
        if date_from:
            stmt = stmt.where(EggRecord.record_date >= date_from)
        if date_to:
            stmt = stmt.where(EggRecord.record_date <= date_to)
        stmt = stmt.order_by(EggRecord.record_date.desc())
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_by_shed_and_date(
        self, db: AsyncSession, shed_id: str, record_date: date
    ) -> EggRecord | None:
        stmt = select(EggRecord).where(
            EggRecord.shed_id == shed_id,
            EggRecord.record_date == record_date,
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()


class ChickenRecordRepository(BaseRepository[ChickenRecord]):
    def __init__(self):
        super().__init__(ChickenRecord)

    async def get_by_shed_and_date_range(
        self,
        db: AsyncSession,
        shed_id: str,
        date_from: date | None = None,
        date_to: date | None = None,
    ) -> list[ChickenRecord]:
        stmt = select(ChickenRecord).where(ChickenRecord.shed_id == shed_id)
        if date_from:
            stmt = stmt.where(ChickenRecord.record_date >= date_from)
        if date_to:
            stmt = stmt.where(ChickenRecord.record_date <= date_to)
        stmt = stmt.order_by(ChickenRecord.record_date.desc())
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_by_shed_and_date(
        self, db: AsyncSession, shed_id: str, record_date: date
    ) -> ChickenRecord | None:
        stmt = select(ChickenRecord).where(
            ChickenRecord.shed_id == shed_id,
            ChickenRecord.record_date == record_date,
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()
