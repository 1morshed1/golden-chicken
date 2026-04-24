import enum
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import BaseModel


class FlockType(str, enum.Enum):
    LAYER = "layer"
    BROILER = "broiler"
    MIXED = "mixed"


class ShedStatus(str, enum.Enum):
    ACTIVE = "active"
    PREPARING = "preparing"
    RESTING = "resting"
    INACTIVE = "inactive"


class Farm(BaseModel):
    __tablename__ = "farms"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    name: Mapped[str] = mapped_column(String(150))
    location: Mapped[str | None] = mapped_column(String(255))
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    user = relationship("User", back_populates="farms")
    sheds = relationship("Shed", back_populates="farm", lazy="selectin")


class Shed(BaseModel):
    __tablename__ = "sheds"

    farm_id: Mapped[str] = mapped_column(ForeignKey("farms.id"), index=True)
    name: Mapped[str] = mapped_column(String(120))
    flock_type: Mapped[FlockType] = mapped_column(SAEnum(FlockType), default=FlockType.LAYER)
    bird_count: Mapped[int] = mapped_column(Integer, default=0)
    bird_age_days: Mapped[int | None] = mapped_column(Integer)
    breed: Mapped[str | None] = mapped_column(String(100))
    stocked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    status: Mapped[ShedStatus] = mapped_column(SAEnum(ShedStatus), default=ShedStatus.ACTIVE)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    farm = relationship("Farm", back_populates="sheds")
    egg_records = relationship("EggRecord", back_populates="shed", lazy="dynamic")
    chicken_records = relationship("ChickenRecord", back_populates="shed", lazy="dynamic")
    tasks = relationship("FarmTask", back_populates="shed", lazy="dynamic")
