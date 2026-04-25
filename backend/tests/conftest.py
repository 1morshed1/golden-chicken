from unittest.mock import AsyncMock

import pytest


@pytest.fixture
def mock_redis():
    redis = AsyncMock()
    redis.get = AsyncMock(return_value=None)
    redis.set = AsyncMock()
    redis.setex = AsyncMock()
    redis.incr = AsyncMock(return_value=1)
    redis.expire = AsyncMock()
    redis.delete = AsyncMock()
    redis.incrbyfloat = AsyncMock()
    redis.decr = AsyncMock(return_value=0)
    return redis
