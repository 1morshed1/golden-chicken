from datetime import datetime, timedelta, timezone

from sqlalchemy import and_, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.market import MarketPrice, PriceSource, ProductType
from app.repositories.base import BaseRepository


class MarketPriceRepository(BaseRepository[MarketPrice]):
    def __init__(self):
        super().__init__(MarketPrice)

    async def get_latest_prices(
        self,
        db: AsyncSession,
        *,
        product_type: ProductType | None = None,
        location: str | None = None,
        limit: int = 50,
    ) -> list[MarketPrice]:
        subq = (
            select(
                MarketPrice.product_type,
                MarketPrice.market_name,
                func.max(MarketPrice.fetched_at).label("latest"),
            )
            .group_by(MarketPrice.product_type, MarketPrice.market_name)
            .subquery()
        )

        stmt = (
            select(MarketPrice)
            .join(
                subq,
                and_(
                    MarketPrice.product_type == subq.c.product_type,
                    MarketPrice.market_name == subq.c.market_name,
                    MarketPrice.fetched_at == subq.c.latest,
                ),
            )
            .order_by(MarketPrice.product_type, MarketPrice.market_name)
            .limit(limit)
        )

        if product_type:
            stmt = stmt.where(MarketPrice.product_type == product_type)
        if location:
            stmt = stmt.where(MarketPrice.location.ilike(f"%{location}%"))

        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_price_history(
        self,
        db: AsyncSession,
        product_type: ProductType,
        days: int = 30,
    ) -> list[MarketPrice]:
        since = datetime.now(timezone.utc) - timedelta(days=days)
        stmt = (
            select(MarketPrice)
            .where(
                and_(
                    MarketPrice.product_type == product_type,
                    MarketPrice.fetched_at >= since,
                )
            )
            .order_by(MarketPrice.fetched_at)
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_last_updated(self, db: AsyncSession) -> datetime | None:
        stmt = select(func.max(MarketPrice.fetched_at))
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    async def mark_all_stale(self, db: AsyncSession) -> None:
        stmt = (
            update(MarketPrice)
            .where(MarketPrice.is_stale == False)
            .values(is_stale=True)
        )
        await db.execute(stmt)
        await db.flush()

    async def upsert_price(
        self, db: AsyncSession, **kwargs
    ) -> MarketPrice:
        return await self.create(db, **kwargs)

    async def get_previous_price(
        self,
        db: AsyncSession,
        product_type: ProductType,
        market_name: str,
        before: datetime,
    ) -> MarketPrice | None:
        stmt = (
            select(MarketPrice)
            .where(
                and_(
                    MarketPrice.product_type == product_type,
                    MarketPrice.market_name == market_name,
                    MarketPrice.fetched_at < before,
                )
            )
            .order_by(MarketPrice.fetched_at.desc())
            .limit(1)
        )
        result = await db.execute(stmt)
        return result.scalar_one_or_none()
