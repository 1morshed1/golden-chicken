from datetime import datetime

from pydantic import BaseModel, EmailStr, Field

from app.models.user import LanguagePreference, UserRole


class UserResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str
    phone: str | None = None
    location: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    role: UserRole
    language_pref: LanguagePreference
    loyalty_points: int
    loyalty_tier: str
    avatar_url: str | None = None
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class UpdateProfileRequest(BaseModel):
    full_name: str | None = Field(None, min_length=2, max_length=200)
    phone: str | None = Field(None, max_length=20)
    location: str | None = Field(None, max_length=255)
    latitude: float | None = None
    longitude: float | None = None
    language_pref: LanguagePreference | None = None
