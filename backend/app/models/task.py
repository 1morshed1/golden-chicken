import enum
from datetime import date, datetime, time

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Integer, String, Text, Time
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import BaseModel


class TaskType(str, enum.Enum):
    FEEDING = "feeding"
    VACCINATION = "vaccination"
    MEDICINE = "medicine"
    CLEANING = "cleaning"
    EXAMINATION = "examination"
    SHED_CHECK = "shed_check"
    EGG_COLLECTION = "egg_collection"
    WATER_CHECK = "water_check"
    BIOSECURITY = "biosecurity"
    OTHER = "other"


class RecurrenceType(str, enum.Enum):
    NONE = "none"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    CUSTOM = "custom"


class FarmTask(BaseModel):
    __tablename__ = "farm_tasks"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    shed_id: Mapped[str | None] = mapped_column(ForeignKey("sheds.id"))
    task_type: Mapped[TaskType] = mapped_column(SAEnum(TaskType))
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(Text)
    due_date: Mapped[date] = mapped_column(Date, index=True)
    due_time: Mapped[time | None] = mapped_column(Time)
    recurrence: Mapped[RecurrenceType] = mapped_column(
        SAEnum(RecurrenceType), default=RecurrenceType.NONE
    )
    priority: Mapped[int] = mapped_column(Integer, default=5)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    user = relationship("User", back_populates="tasks")
    shed = relationship("Shed", back_populates="tasks")
