import enum

from sqlalchemy import Boolean, Integer, String
from sqlalchemy import Enum as SAEnum
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class DiseaseSeverity(str, enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class HealthTab(BaseModel):
    __tablename__ = "health_tabs"

    disease_name_en: Mapped[str] = mapped_column(String(200))
    disease_name_bn: Mapped[str] = mapped_column(String(200))
    severity: Mapped[DiseaseSeverity] = mapped_column(SAEnum(DiseaseSeverity))
    symptom_count: Mapped[int] = mapped_column(Integer)
    symptoms: Mapped[dict] = mapped_column(JSON)
    prefilled_prompt_en: Mapped[str] = mapped_column(String(500))
    prefilled_prompt_bn: Mapped[str] = mapped_column(String(500))
    category: Mapped[str] = mapped_column(String(100), index=True)
    icon: Mapped[str] = mapped_column(String(50), default="🦠")
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
