from datetime import date, datetime

from pydantic import BaseModel, Field


class CreateEggRecordRequest(BaseModel):
    record_date: date
    total_eggs: int = Field(..., ge=0)
    broken_eggs: int = Field(0, ge=0)
    sold_eggs: int = Field(0, ge=0)
    egg_weight_avg_g: float | None = Field(None, gt=0)
    notes: str | None = None


class EggRecordResponse(BaseModel):
    id: str
    shed_id: str
    record_date: date
    total_eggs: int
    broken_eggs: int
    sold_eggs: int
    egg_weight_avg_g: float | None = None
    notes: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class EggSummary(BaseModel):
    avg_daily: float
    total: int
    trend: str


class EggRecordsListResponse(BaseModel):
    records: list[EggRecordResponse]
    summary: EggSummary


class CreateChickenRecordRequest(BaseModel):
    record_date: date
    total_birds: int = Field(..., ge=0)
    additions: int = Field(0, ge=0)
    mortality: int = Field(0, ge=0)
    mortality_cause: str | None = None
    avg_weight_g: float | None = Field(None, gt=0)
    feed_consumed_kg: float | None = Field(None, ge=0)
    notes: str | None = None


class ChickenRecordResponse(BaseModel):
    id: str
    shed_id: str
    record_date: date
    total_birds: int
    additions: int
    mortality: int
    mortality_cause: str | None = None
    avg_weight_g: float | None = None
    feed_consumed_kg: float | None = None
    notes: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class ChickenSummary(BaseModel):
    current_count: int
    total_mortality: int
    fcr: float | None = None


class ChickenRecordsListResponse(BaseModel):
    records: list[ChickenRecordResponse]
    summary: ChickenSummary


class TrendDataPoint(BaseModel):
    date: date
    value: float
    secondary: float | None = None


class TrendResponse(BaseModel):
    data_points: list[TrendDataPoint]
    trend_direction: str
    change_pct: float | None = None


class FeedTrendResponse(BaseModel):
    data_points: list[TrendDataPoint]
    avg_fcr: float | None = None


class FarmOverviewResponse(BaseModel):
    total_birds: int
    total_eggs_today: int
    mortality_rate_7d: float
    feed_efficiency: float | None = None
