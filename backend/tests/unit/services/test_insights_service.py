from datetime import date, timedelta
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.exceptions import AuthorizationError, NotFoundError
from app.models.farm import FlockType, Shed
from app.models.insights import InsightSeverity
from app.services.insights_service import InsightsService


@pytest.fixture
def insights_svc():
    return InsightsService()


@pytest.fixture
def mock_db():
    return AsyncMock()


def _make_egg_records(count, base_eggs=250, latest_eggs=None):
    records = []
    for i in range(count):
        r = MagicMock()
        r.total_eggs = base_eggs if i > 0 else (latest_eggs if latest_eggs is not None else base_eggs)
        r.record_date = date.today() - timedelta(days=count - 1 - i)
        records.append(r)
    return records


def _make_shed(name="Shed A", flock_type=FlockType.LAYER, shed_id="shed-1"):
    shed = MagicMock(spec=Shed)
    shed.id = shed_id
    shed.name = name
    shed.flock_type = flock_type
    shed.is_active = True
    return shed


class TestEggProductionInsights:
    @patch("app.services.insights_service.egg_repo")
    async def test_critical_egg_drop(self, mock_egg_repo, insights_svc, mock_db):
        records = _make_egg_records(5, base_eggs=250, latest_eggs=180)
        mock_egg_repo.get_by_shed_and_date_range = AsyncMock(return_value=records)
        shed = _make_shed()

        insights = await insights_svc._check_egg_production(mock_db, "user-1", shed)
        assert len(insights) == 1
        assert insights[0].severity == InsightSeverity.CRITICAL

    @patch("app.services.insights_service.egg_repo")
    async def test_warning_egg_drop(self, mock_egg_repo, insights_svc, mock_db):
        records = _make_egg_records(5, base_eggs=250, latest_eggs=200)
        mock_egg_repo.get_by_shed_and_date_range = AsyncMock(return_value=records)
        shed = _make_shed()

        insights = await insights_svc._check_egg_production(mock_db, "user-1", shed)
        assert len(insights) == 1
        assert insights[0].severity == InsightSeverity.WARNING

    @patch("app.services.insights_service.egg_repo")
    async def test_stable_production_no_insight(self, mock_egg_repo, insights_svc, mock_db):
        records = _make_egg_records(5, base_eggs=250, latest_eggs=248)
        mock_egg_repo.get_by_shed_and_date_range = AsyncMock(return_value=records)
        shed = _make_shed()

        insights = await insights_svc._check_egg_production(mock_db, "user-1", shed)
        assert len(insights) == 0

    @patch("app.services.insights_service.egg_repo")
    async def test_too_few_records(self, mock_egg_repo, insights_svc, mock_db):
        records = _make_egg_records(2, base_eggs=250)
        mock_egg_repo.get_by_shed_and_date_range = AsyncMock(return_value=records)
        shed = _make_shed()

        insights = await insights_svc._check_egg_production(mock_db, "user-1", shed)
        assert len(insights) == 0


class TestMortalityInsights:
    @patch("app.services.insights_service.chicken_repo")
    async def test_critical_mortality(self, mock_chicken_repo, insights_svc, mock_db):
        record = MagicMock()
        record.total_birds = 500
        record.mortality = 30
        mock_chicken_repo.get_by_shed_and_date = AsyncMock(return_value=record)
        shed = _make_shed()

        insights = await insights_svc._check_mortality(mock_db, "user-1", shed)
        assert len(insights) == 1
        assert insights[0].severity == InsightSeverity.CRITICAL
        assert "veterinarian" in insights[0].proposed_action.lower()

    @patch("app.services.insights_service.chicken_repo")
    async def test_warning_mortality(self, mock_chicken_repo, insights_svc, mock_db):
        record = MagicMock()
        record.total_birds = 500
        record.mortality = 15
        mock_chicken_repo.get_by_shed_and_date = AsyncMock(return_value=record)
        shed = _make_shed()

        insights = await insights_svc._check_mortality(mock_db, "user-1", shed)
        assert len(insights) == 1
        assert insights[0].severity == InsightSeverity.WARNING

    @patch("app.services.insights_service.chicken_repo")
    async def test_low_mortality_no_insight(self, mock_chicken_repo, insights_svc, mock_db):
        record = MagicMock()
        record.total_birds = 500
        record.mortality = 5
        mock_chicken_repo.get_by_shed_and_date = AsyncMock(return_value=record)
        shed = _make_shed()

        insights = await insights_svc._check_mortality(mock_db, "user-1", shed)
        assert len(insights) == 0

    @patch("app.services.insights_service.chicken_repo")
    async def test_no_record_no_insight(self, mock_chicken_repo, insights_svc, mock_db):
        mock_chicken_repo.get_by_shed_and_date = AsyncMock(return_value=None)
        shed = _make_shed()

        insights = await insights_svc._check_mortality(mock_db, "user-1", shed)
        assert len(insights) == 0


class TestOverdueTaskInsights:
    @patch("app.services.insights_service.task_repo")
    async def test_overdue_vaccination_critical(self, mock_task_repo, insights_svc, mock_db):
        task = MagicMock()
        task.task_type = MagicMock()
        task.task_type.value = "vaccination"
        task.title = "Newcastle vaccine"
        mock_task_repo.get_overdue_tasks = AsyncMock(return_value=[task])

        insights = await insights_svc._check_overdue_tasks(mock_db, "user-1")
        assert len(insights) == 1
        assert insights[0].severity == InsightSeverity.CRITICAL

    @patch("app.services.insights_service.task_repo")
    async def test_many_overdue_non_vaccination(self, mock_task_repo, insights_svc, mock_db):
        tasks = []
        for i in range(4):
            t = MagicMock()
            t.task_type = MagicMock()
            t.task_type.value = "feeding"
            t.title = f"Task {i}"
            tasks.append(t)
        mock_task_repo.get_overdue_tasks = AsyncMock(return_value=tasks)

        insights = await insights_svc._check_overdue_tasks(mock_db, "user-1")
        assert len(insights) == 1
        assert insights[0].severity == InsightSeverity.WARNING

    @patch("app.services.insights_service.task_repo")
    async def test_no_overdue(self, mock_task_repo, insights_svc, mock_db):
        mock_task_repo.get_overdue_tasks = AsyncMock(return_value=[])
        insights = await insights_svc._check_overdue_tasks(mock_db, "user-1")
        assert len(insights) == 0


class TestAcknowledgeResolve:
    @patch("app.services.insights_service.insight_repo")
    async def test_acknowledge_not_found(self, mock_repo, insights_svc, mock_db):
        mock_repo.get_by_id = AsyncMock(return_value=None)
        user = MagicMock()
        user.id = "user-1"
        with pytest.raises(NotFoundError):
            await insights_svc.acknowledge_insight(mock_db, "bad-id", user)

    @patch("app.services.insights_service.insight_repo")
    async def test_acknowledge_wrong_user(self, mock_repo, insights_svc, mock_db):
        insight = MagicMock()
        insight.user_id = "other-user"
        mock_repo.get_by_id = AsyncMock(return_value=insight)
        user = MagicMock()
        user.id = "user-1"
        with pytest.raises(AuthorizationError):
            await insights_svc.acknowledge_insight(mock_db, "insight-1", user)
