from datetime import date, datetime, time

from pydantic import BaseModel, Field

from app.models.task import RecurrenceType, TaskType


class TaskCreate(BaseModel):
    shed_id: str | None = None
    task_type: TaskType
    title: str = Field(min_length=1, max_length=255)
    description: str | None = None
    due_date: date
    due_time: time | None = None
    recurrence: RecurrenceType = RecurrenceType.NONE
    priority: int = Field(default=5, ge=1, le=10)


class TaskUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=255)
    description: str | None = None
    due_date: date | None = None
    due_time: time | None = None
    task_type: TaskType | None = None
    recurrence: RecurrenceType | None = None
    priority: int | None = Field(default=None, ge=1, le=10)
    shed_id: str | None = None


class TaskResponse(BaseModel):
    id: str
    user_id: str
    shed_id: str | None
    task_type: TaskType
    title: str
    description: str | None
    due_date: date
    due_time: time | None
    recurrence: RecurrenceType
    priority: int
    is_completed: bool
    completed_at: datetime | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class TodaySummary(BaseModel):
    tasks: list[TaskResponse]
    completed_count: int
    pending_count: int
