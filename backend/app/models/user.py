import enum

from sqlalchemy import Boolean, Integer, String
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import BaseModel


class UserRole(str, enum.Enum):
    FARMER = "farmer"
    FARM_MANAGER = "farm_manager"
    VETERINARIAN = "veterinarian"
    BUSINESS_OWNER = "business_owner"
    COOPERATIVE_MEMBER = "cooperative_member"
    ADMIN = "admin"


class LanguagePreference(str, enum.Enum):
    EN = "en"
    BN = "bn"


class User(BaseModel):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str | None] = mapped_column(String(255))
    full_name: Mapped[str] = mapped_column(String(200))
    phone: Mapped[str | None] = mapped_column(String(20))
    location: Mapped[str | None] = mapped_column(String(255))
    latitude: Mapped[float | None] = mapped_column()
    longitude: Mapped[float | None] = mapped_column()
    role: Mapped[UserRole] = mapped_column(SAEnum(UserRole), default=UserRole.FARMER)
    language_pref: Mapped[LanguagePreference] = mapped_column(
        SAEnum(LanguagePreference), default=LanguagePreference.EN
    )
    loyalty_points: Mapped[int] = mapped_column(Integer, default=0)
    loyalty_tier: Mapped[str] = mapped_column(String(20), default="bronze")
    avatar_url: Mapped[str | None] = mapped_column(String(500))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    google_id: Mapped[str | None] = mapped_column(String(255), unique=True)
    facebook_id: Mapped[str | None] = mapped_column(String(255), unique=True)

    farms = relationship("Farm", back_populates="user", lazy="selectin")
    chat_sessions = relationship("ChatSession", back_populates="user", lazy="dynamic")
    tasks = relationship("FarmTask", back_populates="user", lazy="dynamic")
    sessions = relationship("UserSession", back_populates="user", lazy="dynamic")
