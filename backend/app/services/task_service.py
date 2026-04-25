from datetime import date

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthorizationError, NotFoundError
from app.models.task import FarmTask
from app.models.user import User
from app.repositories.task_repository import TaskRepository
from app.schemas.task import TaskCreate, TaskUpdate

task_repo = TaskRepository()


class TaskService:
    async def create_task(
        self, db: AsyncSession, user: User, data: TaskCreate
    ) -> FarmTask:
        return await task_repo.create(
            db,
            user_id=user.id,
            shed_id=data.shed_id,
            task_type=data.task_type,
            title=data.title,
            description=data.description,
            due_date=data.due_date,
            due_time=data.due_time,
            recurrence=data.recurrence,
            priority=data.priority,
        )

    async def get_tasks(
        self,
        db: AsyncSession,
        user: User,
        *,
        status: str | None = None,
        target_date: date | None = None,
        shed_id: str | None = None,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[FarmTask], int]:
        tasks = await task_repo.get_user_tasks(
            db, user.id,
            status=status, target_date=target_date,
            shed_id=shed_id, offset=offset, limit=limit,
        )
        total = await task_repo.count_user_tasks(
            db, user.id,
            status=status, target_date=target_date,
            shed_id=shed_id,
        )
        return tasks, total

    async def get_task(
        self, db: AsyncSession, task_id: str, user: User
    ) -> FarmTask:
        task = await task_repo.get_by_id(db, task_id)
        if not task:
            raise NotFoundError("Task")
        if task.user_id != user.id:
            raise AuthorizationError()
        return task

    async def update_task(
        self, db: AsyncSession, task_id: str, user: User, data: TaskUpdate
    ) -> FarmTask:
        task = await self.get_task(db, task_id, user)
        update_data = data.model_dump(exclude_unset=True)
        return await task_repo.update(db, task, **update_data)

    async def complete_task(
        self, db: AsyncSession, task_id: str, user: User
    ) -> FarmTask:
        task = await self.get_task(db, task_id, user)
        completed = await task_repo.complete_task(db, task)

        if task.recurrence.value != "none":
            await task_repo.generate_next_recurring(db, task)

        return completed

    async def delete_task(
        self, db: AsyncSession, task_id: str, user: User
    ) -> None:
        task = await self.get_task(db, task_id, user)
        await task_repo.delete(db, task)

    async def get_overdue_tasks(
        self, db: AsyncSession, user: User
    ) -> tuple[list[FarmTask], int]:
        tasks = await task_repo.get_overdue_tasks(db, user.id)
        return tasks, len(tasks)

    async def get_today_tasks(
        self, db: AsyncSession, user: User
    ) -> dict:
        tasks = await task_repo.get_today_tasks(db, user.id)
        completed = sum(1 for t in tasks if t.is_completed)
        pending = len(tasks) - completed
        return {
            "tasks": tasks,
            "completed_count": completed,
            "pending_count": pending,
        }


task_service = TaskService()
