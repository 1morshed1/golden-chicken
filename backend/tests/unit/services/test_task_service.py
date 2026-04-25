from datetime import date, timedelta
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.exceptions import AuthorizationError, NotFoundError
from app.models.task import FarmTask, RecurrenceType
from app.services.task_service import TaskService


@pytest.fixture
def task_svc():
    return TaskService()


@pytest.fixture
def mock_db():
    return AsyncMock()


@pytest.fixture
def mock_user():
    user = MagicMock()
    user.id = "user-1"
    return user


def _make_task(
    task_id="task-1",
    user_id="user-1",
    is_completed=False,
    due_date=None,
    recurrence=RecurrenceType.NONE,
    priority="medium",
):
    task = MagicMock(spec=FarmTask)
    task.id = task_id
    task.user_id = user_id
    task.is_completed = is_completed
    task.due_date = due_date or date.today()
    task.recurrence = recurrence
    task.priority = priority
    task.title = "Test Task"
    task.task_type = "feeding"
    task.description = None
    task.due_time = None
    task.shed_id = None
    return task


class TestGetTask:
    @patch("app.services.task_service.task_repo")
    async def test_task_not_found(self, mock_repo, task_svc, mock_db, mock_user):
        mock_repo.get_by_id = AsyncMock(return_value=None)
        with pytest.raises(NotFoundError):
            await task_svc.get_task(mock_db, "nonexistent", mock_user)

    @patch("app.services.task_service.task_repo")
    async def test_task_wrong_owner(self, mock_repo, task_svc, mock_db, mock_user):
        task = _make_task(user_id="other-user")
        mock_repo.get_by_id = AsyncMock(return_value=task)
        with pytest.raises(AuthorizationError):
            await task_svc.get_task(mock_db, "task-1", mock_user)

    @patch("app.services.task_service.task_repo")
    async def test_get_task_success(self, mock_repo, task_svc, mock_db, mock_user):
        task = _make_task()
        mock_repo.get_by_id = AsyncMock(return_value=task)
        result = await task_svc.get_task(mock_db, "task-1", mock_user)
        assert result == task


class TestCompleteTask:
    @patch("app.services.task_service.task_repo")
    async def test_complete_non_recurring(self, mock_repo, task_svc, mock_db, mock_user):
        task = _make_task(recurrence=RecurrenceType.NONE)
        mock_repo.get_by_id = AsyncMock(return_value=task)
        mock_repo.complete_task = AsyncMock(return_value=task)

        result = await task_svc.complete_task(mock_db, "task-1", mock_user)
        mock_repo.complete_task.assert_called_once()
        mock_repo.generate_next_recurring.assert_not_called()

    @patch("app.services.task_service.task_repo")
    async def test_complete_daily_recurring_generates_next(
        self, mock_repo, task_svc, mock_db, mock_user
    ):
        task = _make_task(recurrence=RecurrenceType.DAILY)
        mock_repo.get_by_id = AsyncMock(return_value=task)
        mock_repo.complete_task = AsyncMock(return_value=task)
        mock_repo.generate_next_recurring = AsyncMock()

        await task_svc.complete_task(mock_db, "task-1", mock_user)
        mock_repo.generate_next_recurring.assert_called_once_with(mock_db, task)

    @patch("app.services.task_service.task_repo")
    async def test_complete_weekly_recurring_generates_next(
        self, mock_repo, task_svc, mock_db, mock_user
    ):
        task = _make_task(recurrence=RecurrenceType.WEEKLY)
        mock_repo.get_by_id = AsyncMock(return_value=task)
        mock_repo.complete_task = AsyncMock(return_value=task)
        mock_repo.generate_next_recurring = AsyncMock()

        await task_svc.complete_task(mock_db, "task-1", mock_user)
        mock_repo.generate_next_recurring.assert_called_once()


class TestTodayTasks:
    @patch("app.services.task_service.task_repo")
    async def test_today_view_counts(self, mock_repo, task_svc, mock_db, mock_user):
        tasks = [
            _make_task(is_completed=False),
            _make_task(is_completed=False, task_id="task-2"),
            _make_task(is_completed=True, task_id="task-3"),
        ]
        mock_repo.get_today_tasks = AsyncMock(return_value=tasks)

        result = await task_svc.get_today_tasks(mock_db, mock_user)
        assert result["completed_count"] == 1
        assert result["pending_count"] == 2
        assert len(result["tasks"]) == 3

    @patch("app.services.task_service.task_repo")
    async def test_today_empty(self, mock_repo, task_svc, mock_db, mock_user):
        mock_repo.get_today_tasks = AsyncMock(return_value=[])
        result = await task_svc.get_today_tasks(mock_db, mock_user)
        assert result["completed_count"] == 0
        assert result["pending_count"] == 0


class TestOverdueTasks:
    @patch("app.services.task_service.task_repo")
    async def test_overdue_tasks_returned(self, mock_repo, task_svc, mock_db, mock_user):
        overdue = [
            _make_task(due_date=date.today() - timedelta(days=3)),
            _make_task(due_date=date.today() - timedelta(days=1), task_id="task-2"),
        ]
        mock_repo.get_overdue_tasks = AsyncMock(return_value=overdue)
        tasks, count = await task_svc.get_overdue_tasks(mock_db, mock_user)
        assert count == 2


class TestDeleteTask:
    @patch("app.services.task_service.task_repo")
    async def test_delete_own_task(self, mock_repo, task_svc, mock_db, mock_user):
        task = _make_task()
        mock_repo.get_by_id = AsyncMock(return_value=task)
        mock_repo.delete = AsyncMock()
        await task_svc.delete_task(mock_db, "task-1", mock_user)
        mock_repo.delete.assert_called_once()

    @patch("app.services.task_service.task_repo")
    async def test_delete_other_users_task_fails(self, mock_repo, task_svc, mock_db, mock_user):
        task = _make_task(user_id="other-user")
        mock_repo.get_by_id = AsyncMock(return_value=task)
        with pytest.raises(AuthorizationError):
            await task_svc.delete_task(mock_db, "task-1", mock_user)
