from datetime import date, timedelta
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.exceptions import AuthorizationError, ConflictError, NotFoundError
from app.services.production_service import ProductionService


@pytest.fixture
def prod_svc():
    return ProductionService()


@pytest.fixture
def mock_db():
    return AsyncMock()


@pytest.fixture
def mock_user():
    user = MagicMock()
    user.id = "user-1"
    return user


@pytest.fixture
def mock_shed():
    shed = MagicMock()
    shed.id = "shed-1"
    shed.farm_id = "farm-1"
    shed.is_active = True
    shed.bird_count = 500
    return shed


@pytest.fixture
def mock_farm(mock_user):
    farm = MagicMock()
    farm.id = "farm-1"
    farm.user_id = mock_user.id
    farm.is_active = True
    return farm


class TestTrendCalculation:
    def test_trend_up(self, prod_svc):
        values = [100, 100, 100, 120, 130, 140]
        direction, change = prod_svc._calc_trend(values)
        assert direction == "up"
        assert change > 0

    def test_trend_down(self, prod_svc):
        values = [140, 130, 120, 100, 100, 100]
        direction, change = prod_svc._calc_trend(values)
        assert direction == "down"
        assert change < 0

    def test_trend_stable(self, prod_svc):
        values = [100, 101, 100, 99, 100, 101]
        direction, change = prod_svc._calc_trend(values)
        assert direction == "stable"

    def test_trend_single_value(self, prod_svc):
        direction, change = prod_svc._calc_trend([100])
        assert direction == "stable"
        assert change is None

    def test_trend_empty(self, prod_svc):
        direction, change = prod_svc._calc_trend([])
        assert direction == "stable"


class TestEggSummary:
    def test_empty_records(self, prod_svc):
        summary = prod_svc._compute_egg_summary([])
        assert summary.avg_daily == 0
        assert summary.total == 0
        assert summary.trend == "stable"

    def test_single_record(self, prod_svc):
        record = MagicMock()
        record.total_eggs = 250
        record.record_date = date.today()
        summary = prod_svc._compute_egg_summary([record])
        assert summary.total == 250
        assert summary.avg_daily == 250.0

    def test_multiple_records(self, prod_svc):
        records = []
        for i in range(7):
            r = MagicMock()
            r.total_eggs = 200 + i * 10
            r.record_date = date.today() - timedelta(days=6 - i)
            records.append(r)
        summary = prod_svc._compute_egg_summary(records)
        assert summary.total == sum(r.total_eggs for r in records)
        assert summary.avg_daily > 0


class TestChickenSummary:
    def test_empty_records(self, prod_svc):
        summary = prod_svc._compute_chicken_summary([])
        assert summary.current_count == 0
        assert summary.total_mortality == 0

    def test_mortality_accumulation(self, prod_svc):
        records = []
        for i in range(5):
            r = MagicMock()
            r.total_birds = 500 - i * 2
            r.mortality = 2
            r.feed_consumed_kg = 50.0
            r.avg_weight_g = 1000 + i * 50
            r.record_date = date.today() - timedelta(days=4 - i)
            records.append(r)
        summary = prod_svc._compute_chicken_summary(records)
        assert summary.total_mortality == 10
        assert summary.current_count == 492


class TestVerifyShedAccess:
    @patch("app.services.production_service.shed_repo")
    @patch("app.services.production_service.farm_repo")
    async def test_shed_not_found(self, mock_farm_repo, mock_shed_repo, prod_svc, mock_db, mock_user):
        mock_shed_repo.get_by_id = AsyncMock(return_value=None)
        with pytest.raises(NotFoundError):
            await prod_svc._verify_shed_access(mock_db, "bad-shed", mock_user)

    @patch("app.services.production_service.shed_repo")
    @patch("app.services.production_service.farm_repo")
    async def test_shed_wrong_owner(
        self, mock_farm_repo, mock_shed_repo, prod_svc, mock_db, mock_user, mock_shed, mock_farm
    ):
        mock_shed_repo.get_by_id = AsyncMock(return_value=mock_shed)
        mock_farm.user_id = "other-user"
        mock_farm_repo.get_by_id = AsyncMock(return_value=mock_farm)
        with pytest.raises(AuthorizationError):
            await prod_svc._verify_shed_access(mock_db, "shed-1", mock_user)

    @patch("app.services.production_service.shed_repo")
    @patch("app.services.production_service.farm_repo")
    async def test_shed_access_ok(
        self, mock_farm_repo, mock_shed_repo, prod_svc, mock_db, mock_user, mock_shed, mock_farm
    ):
        mock_shed_repo.get_by_id = AsyncMock(return_value=mock_shed)
        mock_farm_repo.get_by_id = AsyncMock(return_value=mock_farm)
        result = await prod_svc._verify_shed_access(mock_db, "shed-1", mock_user)
        assert result == mock_shed


class TestCreateEggRecord:
    @patch("app.services.production_service.egg_repo")
    @patch("app.services.production_service.shed_repo")
    @patch("app.services.production_service.farm_repo")
    async def test_duplicate_date_raises_conflict(
        self, mock_farm_repo, mock_shed_repo, mock_egg_repo,
        prod_svc, mock_db, mock_user, mock_shed, mock_farm,
    ):
        mock_shed_repo.get_by_id = AsyncMock(return_value=mock_shed)
        mock_farm_repo.get_by_id = AsyncMock(return_value=mock_farm)
        mock_egg_repo.get_by_shed_and_date = AsyncMock(return_value=MagicMock())
        with pytest.raises(ConflictError, match="Egg record already exists"):
            await prod_svc.create_egg_record(
                mock_db, "shed-1", mock_user, record_date=date.today(), total_eggs=100
            )
