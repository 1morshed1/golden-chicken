import enum
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, String
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class ProductType(str, enum.Enum):
    EGG = "egg"
    BROILER_MEAT = "broiler_meat"
    LAYER_MEAT = "layer_meat"
    FEED = "feed"
    CHICK = "chick"


class PriceTrend(str, enum.Enum):
    UP = "up"
    DOWN = "down"
    STABLE = "stable"


class PriceSource(str, enum.Enum):
    SCRAPED_DAM = "scraped_dam"
    SCRAPED_TCB = "scraped_tcb"
    MANUAL = "manual"


class MarketPrice(BaseModel):
    __tablename__ = "market_prices"

    product_type: Mapped[ProductType] = mapped_column(SAEnum(ProductType))
    product_name: Mapped[str] = mapped_column(String(200))
    unit: Mapped[str] = mapped_column(String(50))
    market_name: Mapped[str] = mapped_column(String(200))
    location: Mapped[str] = mapped_column(String(200))
    price_bdt: Mapped[float] = mapped_column(Float)
    change_percent: Mapped[float] = mapped_column(Float, default=0.0)
    trend: Mapped[PriceTrend] = mapped_column(SAEnum(PriceTrend), default=PriceTrend.STABLE)
    source: Mapped[PriceSource] = mapped_column(SAEnum(PriceSource))
    is_stale: Mapped[bool] = mapped_column(Boolean, default=False)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
