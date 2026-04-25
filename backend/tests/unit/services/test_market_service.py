from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.services.market_service import MarketService


@pytest.fixture
def market_svc():
    return MarketService()


@pytest.fixture
def mock_db():
    return AsyncMock()


class TestStaleDataWarning:
    @patch("app.services.market_service.market_repo")
    async def test_fresh_data_no_warning(self, mock_repo, market_svc, mock_db):
        mock_repo.get_latest_prices = AsyncMock(return_value=[])
        mock_repo.get_last_updated = AsyncMock(
            return_value=datetime.now(timezone.utc) - timedelta(hours=1)
        )
        result = await market_svc.get_latest_prices(mock_db)
        assert result["data_warning"] is None

    @patch("app.services.market_service.market_repo")
    async def test_stale_data_has_warning(self, mock_repo, market_svc, mock_db):
        mock_repo.get_latest_prices = AsyncMock(return_value=[])
        mock_repo.get_last_updated = AsyncMock(
            return_value=datetime.now(timezone.utc) - timedelta(hours=72)
        )
        result = await market_svc.get_latest_prices(mock_db)
        assert result["data_warning"] is not None
        assert "72 hours old" in result["data_warning"]

    @patch("app.services.market_service.market_repo")
    async def test_no_data_at_all(self, mock_repo, market_svc, mock_db):
        mock_repo.get_latest_prices = AsyncMock(return_value=[])
        mock_repo.get_last_updated = AsyncMock(return_value=None)
        result = await market_svc.get_latest_prices(mock_db)
        assert result["data_warning"] is None
        assert result["prices"] == []

    @patch("app.services.market_service.market_repo")
    async def test_boundary_48_hours_no_warning(self, mock_repo, market_svc, mock_db):
        mock_repo.get_latest_prices = AsyncMock(return_value=[])
        mock_repo.get_last_updated = AsyncMock(
            return_value=datetime.now(timezone.utc) - timedelta(hours=47)
        )
        result = await market_svc.get_latest_prices(mock_db)
        assert result["data_warning"] is None

    @patch("app.services.market_service.market_repo")
    async def test_product_type_filter(self, mock_repo, market_svc, mock_db):
        mock_repo.get_latest_prices = AsyncMock(return_value=[])
        mock_repo.get_last_updated = AsyncMock(return_value=None)
        await market_svc.get_latest_prices(mock_db, product_type="egg")
        call_args = mock_repo.get_latest_prices.call_args
        assert call_args.kwargs.get("product_type") is not None
