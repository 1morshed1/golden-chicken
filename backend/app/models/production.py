from datetime import date

from sqlalchemy import Date, Float, ForeignKey, Integer, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import BaseModel


class EggRecord(BaseModel):
    __tablename__ = "egg_records"

    shed_id: Mapped[str] = mapped_column(ForeignKey("sheds.id"), index=True)
    record_date: Mapped[date] = mapped_column(Date, index=True)
    total_eggs: Mapped[int] = mapped_column(Integer)
    broken_eggs: Mapped[int] = mapped_column(Integer, default=0)
    sold_eggs: Mapped[int] = mapped_column(Integer, default=0)
    egg_weight_avg_g: Mapped[float | None] = mapped_column(Float)
    notes: Mapped[str | None] = mapped_column(Text)

    shed = relationship("Shed", back_populates="egg_records")


class ChickenRecord(BaseModel):
    __tablename__ = "chicken_records"

    shed_id: Mapped[str] = mapped_column(ForeignKey("sheds.id"), index=True)
    record_date: Mapped[date] = mapped_column(Date, index=True)
    total_birds: Mapped[int] = mapped_column(Integer)
    additions: Mapped[int] = mapped_column(Integer, default=0)
    mortality: Mapped[int] = mapped_column(Integer, default=0)
    mortality_cause: Mapped[str | None] = mapped_column(Text)
    avg_weight_g: Mapped[float | None] = mapped_column(Float)
    feed_consumed_kg: Mapped[float | None] = mapped_column(Float)
    notes: Mapped[str | None] = mapped_column(Text)

    shed = relationship("Shed", back_populates="chicken_records")
