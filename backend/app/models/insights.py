import enum

from sqlalchemy import Boolean, ForeignKey, String, Text
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class InsightSeverity(str, enum.Enum):
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"


class FarmInsight(BaseModel):
    __tablename__ = "farm_insights"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    shed_id: Mapped[str | None] = mapped_column(ForeignKey("sheds.id"))
    insight_type: Mapped[str] = mapped_column(String(100))
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str] = mapped_column(Text)
    severity: Mapped[InsightSeverity] = mapped_column(SAEnum(InsightSeverity))
    proposed_action: Mapped[str | None] = mapped_column(Text)
    source: Mapped[str] = mapped_column(String(40))
    is_acknowledged: Mapped[bool] = mapped_column(Boolean, default=False)
    is_resolved: Mapped[bool] = mapped_column(Boolean, default=False)
