from datetime import datetime

from pydantic import BaseModel, Field

from app.models.farm import FlockType, ShedStatus


class CreateFarmRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=150)
    location: str | None = Field(None, max_length=255)
    latitude: float | None = None
    longitude: float | None = None


class UpdateFarmRequest(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=150)
    location: str | None = Field(None, max_length=255)
    latitude: float | None = None
    longitude: float | None = None


class FarmResponse(BaseModel):
    id: str
    name: str
    location: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    is_active: bool
    sheds_count: int = 0
    created_at: datetime

    model_config = {"from_attributes": True}


class FarmDetailResponse(BaseModel):
    id: str
    name: str
    location: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    is_active: bool
    sheds: list["ShedResponse"] = []
    created_at: datetime

    model_config = {"from_attributes": True}


class CreateShedRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=120)
    flock_type: FlockType = FlockType.LAYER
    bird_count: int = Field(0, ge=0)
    bird_age_days: int | None = Field(None, ge=0)
    breed: str | None = Field(None, max_length=100)
    stocked_at: datetime | None = None


class UpdateShedRequest(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=120)
    flock_type: FlockType | None = None
    bird_count: int | None = Field(None, ge=0)
    bird_age_days: int | None = Field(None, ge=0)
    breed: str | None = Field(None, max_length=100)
    status: ShedStatus | None = None


class ShedResponse(BaseModel):
    id: str
    farm_id: str
    name: str
    flock_type: FlockType
    bird_count: int
    bird_age_days: int | None = None
    breed: str | None = None
    stocked_at: datetime | None = None
    status: ShedStatus
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}
