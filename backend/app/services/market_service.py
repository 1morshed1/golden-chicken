from datetime import datetime, timedelta, timezone

from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.models.market import ProductType
from app.repositories.market_repository import MarketPriceRepository

market_repo = MarketPriceRepository()

STALE_WARNING_HOURS = 48


class MarketService:
    async def get_latest_prices(
        self,
        db: AsyncSession,
        *,
        product_type: str | None = None,
        region: str | None = None,
    ) -> dict:
        pt = ProductType(product_type) if product_type else None
        prices = await market_repo.get_latest_prices(
            db, product_type=pt, location=region
        )
        last_updated = await market_repo.get_last_updated(db)

        data_warning = None
        if last_updated:
            hours_since = (datetime.now(timezone.utc) - last_updated).total_seconds() / 3600
            if hours_since > STALE_WARNING_HOURS:
                data_warning = (
                    f"Market data is {int(hours_since)} hours old. "
                    "Prices may not reflect current market conditions."
                )

        return {
            "prices": prices,
            "last_updated": last_updated,
            "data_warning": data_warning,
        }

    async def get_price_history(
        self,
        db: AsyncSession,
        product_type: str,
        days: int = 30,
    ) -> dict:
        pt = ProductType(product_type)
        history = await market_repo.get_price_history(db, pt, days=days)
        return {
            "product_type": pt,
            "history": [
                {
                    "date": p.fetched_at.strftime("%Y-%m-%d"),
                    "price_bdt": p.price_bdt,
                    "source": p.source,
                }
                for p in history
            ],
        }


market_service = MarketService()
