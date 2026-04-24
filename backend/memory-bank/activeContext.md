# Active Context — Current Work Focus

## Current state (as of 2026-04-24)
- **Sprint 1 scaffold is complete.** The full project structure, config, core infra, models, schemas, repositories, routers, and Alembic are in place.
- Docker Compose stack defined (Postgres+pgvector, Redis, MinIO, Celery worker + beat).

## What was just completed
- Project scaffold matching the implementation plan's folder structure.
- `app/config.py` with all settings (Pydantic BaseSettings).
- `app/core/*`: database, redis, storage, security (JWT + bcrypt), dependencies (auth), exceptions, exception handlers, middleware (CORS + request ID), pagination, constants.
- All 12 SQLAlchemy models: User, UserSession, Farm, Shed, EggRecord, ChickenRecord, FarmTask, ChatSession, ChatMessage, HealthTab, MarketPrice, FarmInsight, KnowledgeChunk, WeatherCache.
- Pydantic schemas: common (response envelope), auth, user, farm.
- Repositories: base (generic CRUD), user, farm + shed.
- FastAPI app factory (`app/main.py`) with lifespan, structlog, Sentry, middleware, exception handlers.
- API router with health check endpoints (`/api/v1/health`, `/api/v1/health/ready`).
- Alembic async migration setup.
- Celery app stub.
- Docker: `Dockerfile`, `Dockerfile.worker`, `docker-compose.yml`.

## Immediate next steps
1. **Copy `.env.example` → `.env`** and run `docker compose up` to validate the stack starts.
2. Run first Alembic migration: `alembic revision --autogenerate -m "initial_schema"` then `alembic upgrade head`.
3. Begin **Sprint 2**: auth service (register, login, refresh, logout), farm/shed CRUD endpoints, production record endpoints + trend service.

## Decisions currently in effect
- **Modular monolith** architecture for v1.
- **JWT access/refresh** with rotation and Redis blacklist.
- **SSE** for chat streaming and **WebSocket** for Live AI.
- **Bangla/English** language preference supported end-to-end.
- All models created upfront (not just Sprint 1 entities) so Alembic can generate the full initial migration.
