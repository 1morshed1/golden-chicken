import os
from unittest.mock import AsyncMock

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import create_engine, text
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.models.base import Base

TEST_DATABASE_URL = os.environ.get(
    "TEST_DATABASE_URL",
    "postgresql+asyncpg://goldenchicken:goldenchicken@localhost:5432/goldenchicken_test",
)

SYNC_TEST_DATABASE_URL = TEST_DATABASE_URL.replace("+asyncpg", "+psycopg")

sync_engine = create_engine(SYNC_TEST_DATABASE_URL, echo=False)


@pytest.fixture(scope="session", autouse=True)
def setup_database():
    Base.metadata.create_all(sync_engine)
    yield
    Base.metadata.drop_all(sync_engine)
    sync_engine.dispose()


@pytest.fixture(autouse=True)
def clean_tables():
    yield
    with sync_engine.begin() as conn:
        table_names = list(Base.metadata.tables.keys())
        if table_names:
            conn.execute(text(f"TRUNCATE {', '.join(table_names)} CASCADE"))


@pytest.fixture
async def app(mock_redis):
    import app.core.database as db_module
    import app.core.redis as redis_module

    engine = create_async_engine(TEST_DATABASE_URL, echo=False, pool_size=5)
    session_factory = async_sessionmaker(engine, expire_on_commit=False)

    original_engine = db_module.engine
    original_factory = db_module.async_session_factory
    original_redis = redis_module.redis_client

    db_module.engine = engine
    db_module.async_session_factory = session_factory
    redis_module.redis_client = mock_redis

    from app.core.redis import get_redis
    from app.main import create_app

    application = create_app()

    async def override_get_redis():
        return mock_redis

    application.dependency_overrides[get_redis] = override_get_redis

    yield application

    await engine.dispose()

    db_module.engine = original_engine
    db_module.async_session_factory = original_factory
    redis_module.redis_client = original_redis


@pytest.fixture
async def client(app) -> AsyncClient:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest.fixture
async def auth_headers(client: AsyncClient) -> dict:
    resp = await client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Test Farmer",
            "email": "testfarmer@example.com",
            "password": "testpass1234",
        },
    )
    token = resp.json()["data"]["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
async def second_user_headers(client: AsyncClient) -> dict:
    resp = await client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Second User",
            "email": "second@example.com",
            "password": "testpass1234",
        },
    )
    token = resp.json()["data"]["access_token"]
    return {"Authorization": f"Bearer {token}"}
