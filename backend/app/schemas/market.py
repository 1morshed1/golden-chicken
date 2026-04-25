from datetime import datetime

from pydantic import BaseModel

from app.models.market import PriceSource, PriceTrend, ProductType


class MarketPriceResponse(BaseModel):
    id: str
    product_type: ProductType
    product_name: str
    unit: str
    market_name: str
    location: str
    price_bdt: float
    change_percent: float
    trend: PriceTrend
    source: PriceSource
    is_stale: bool
    fetched_at: datetime
    created_at: datetime

    model_config = {"from_attributes": True}


class MarketPriceListResponse(BaseModel):
    prices: list[MarketPriceResponse]
    last_updated: datetime | None
    data_warning: str | None = None


class PriceHistoryEntry(BaseModel):
    date: str
    price_bdt: float
    source: PriceSource

    model_config = {"from_attributes": True}


class PriceHistoryResponse(BaseModel):
    product_type: ProductType
    history: list[PriceHistoryEntry]
