from pydantic import BaseModel, EmailStr, Field

from app.models.user import LanguagePreference, UserRole


class RegisterRequest(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=200)
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    role: UserRole = UserRole.FARMER
    language_pref: LanguagePreference = LanguagePreference.EN


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class SocialLoginRequest(BaseModel):
    provider: str = Field(..., pattern="^(google|facebook)$")
    id_token: str


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: "UserBrief"


class UserBrief(BaseModel):
    id: str
    email: str
    full_name: str
    role: UserRole
    language_pref: LanguagePreference

    model_config = {"from_attributes": True}
