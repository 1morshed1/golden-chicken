from datetime import date, datetime, timedelta, timezone

from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.task import FarmTask, RecurrenceType
from app.repositories.base import BaseRepository


class TaskRepository(BaseRepository[FarmTask]):
    def __init__(self):
        super().__init__(FarmTask)

    async def get_user_tasks(
        self,
        db: AsyncSession,
        user_id: str,
        *,
        status: str | None = None,
        target_date: date | None = None,
        shed_id: str | None = None,
        offset: int = 0,
        limit: int = 20,
    ) -> list[FarmTask]:
        stmt = select(FarmTask).where(FarmTask.user_id == user_id)

        if status == "completed":
            stmt = stmt.where(FarmTask.is_completed == True)
        elif status == "pending":
            stmt = stmt.where(FarmTask.is_completed == False)
        elif status == "overdue":
            stmt = stmt.where(
                and_(
                    FarmTask.is_completed == False,
                    FarmTask.due_date < date.today(),
                )
            )

        if target_date:
            stmt = stmt.where(FarmTask.due_date == target_date)
        if shed_id:
            stmt = stmt.where(FarmTask.shed_id == shed_id)

        stmt = stmt.order_by(FarmTask.due_date, FarmTask.priority).offset(offset).limit(limit)
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def count_user_tasks(
        self,
        db: AsyncSession,
        user_id: str,
        *,
        status: str | None = None,
        target_date: date | None = None,
        shed_id: str | None = None,
    ) -> int:
        stmt = select(func.count()).select_from(FarmTask).where(FarmTask.user_id == user_id)

        if status == "completed":
            stmt = stmt.where(FarmTask.is_completed == True)
        elif status == "pending":
            stmt = stmt.where(FarmTask.is_completed == False)
        elif status == "overdue":
            stmt = stmt.where(
                and_(
                    FarmTask.is_completed == False,
                    FarmTask.due_date < date.today(),
                )
            )

        if target_date:
            stmt = stmt.where(FarmTask.due_date == target_date)
        if shed_id:
            stmt = stmt.where(FarmTask.shed_id == shed_id)

        result = await db.execute(stmt)
        return result.scalar_one()

    async def get_overdue_tasks(
        self, db: AsyncSession, user_id: str
    ) -> list[FarmTask]:
        stmt = (
            select(FarmTask)
            .where(
                and_(
                    FarmTask.user_id == user_id,
                    FarmTask.is_completed == False,
                    FarmTask.due_date < date.today(),
                )
            )
            .order_by(FarmTask.due_date, FarmTask.priority)
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def get_today_tasks(
        self, db: AsyncSession, user_id: str
    ) -> list[FarmTask]:
        today = date.today()
        stmt = (
            select(FarmTask)
            .where(
                and_(
                    FarmTask.user_id == user_id,
                    FarmTask.due_date == today,
                )
            )
            .order_by(FarmTask.priority, FarmTask.due_time)
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def complete_task(
        self, db: AsyncSession, task: FarmTask
    ) -> FarmTask:
        task.is_completed = True
        task.completed_at = datetime.now(timezone.utc)
        await db.flush()
        await db.refresh(task)
        return task

    async def generate_next_recurring(
        self, db: AsyncSession, task: FarmTask
    ) -> FarmTask | None:
        if task.recurrence == RecurrenceType.NONE:
            return None

        if task.recurrence == RecurrenceType.DAILY:
            next_date = task.due_date + timedelta(days=1)
        elif task.recurrence == RecurrenceType.WEEKLY:
            next_date = task.due_date + timedelta(weeks=1)
        elif task.recurrence == RecurrenceType.MONTHLY:
            month = task.due_date.month % 12 + 1
            year = task.due_date.year + (1 if month == 1 else 0)
            try:
                next_date = task.due_date.replace(year=year, month=month)
            except ValueError:
                next_date = task.due_date.replace(year=year, month=month + 1, day=1) - timedelta(days=1)
        else:
            return None

        return await self.create(
            db,
            user_id=task.user_id,
            shed_id=task.shed_id,
            task_type=task.task_type,
            title=task.title,
            description=task.description,
            due_date=next_date,
            due_time=task.due_time,
            recurrence=task.recurrence,
            priority=task.priority,
        )
