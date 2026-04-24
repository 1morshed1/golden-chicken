# Progress — Golden Chicken Backend

## What exists
- **Implementation plan** (`GoldenChicken_Backend_Implementation_Plan.md`).
- **Memory Bank** (`memory-bank/`).
- **Sprint 1 scaffold — COMPLETE** (as of 2026-04-24):
  - Project config: `pyproject.toml`, `requirements.txt`, `requirements-dev.txt`, `.env.example`, `.gitignore`
  - Docker: `Dockerfile`, `Dockerfile.worker`, `docker-compose.yml`
  - App config: `app/config.py` (Pydantic BaseSettings with all env vars)
  - Core infra: `app/core/` — database, redis, storage, security, dependencies, exceptions, exception handlers, middleware, pagination, constants
  - Models (12): User, UserSession, Farm, Shed, EggRecord, ChickenRecord, FarmTask, ChatSession, ChatMessage, HealthTab, MarketPrice, FarmInsight, KnowledgeChunk, WeatherCache
  - Schemas: common (response envelope), auth, user, farm
  - Repositories: base (generic CRUD), user, farm, shed
  - App factory, API router, health check endpoints, Alembic, Celery stub

- **Sprint 2 (Auth + Production Tracking) — COMPLETE** (as of 2026-04-24):
  - `app/repositories/session_repository.py` — UserSession CRUD (create, get by hash/JTI, revoke, revoke all)
  - `app/services/auth_service.py` — register, login, refresh (with rotation), logout (Redis JTI blacklist)
  - `app/api/v1/auth.py` — POST register (201), login, refresh, logout
  - `app/services/user_service.py` — update profile, avatar upload to S3
  - `app/api/v1/users.py` — GET/PUT /users/me, PUT /users/me/avatar
  - `app/services/farm_service.py` — full CRUD with ownership checks, soft delete
  - `app/api/v1/farms.py` — GET/POST /farms, GET/PUT/DELETE /farms/{id}, POST/GET /farms/{id}/sheds, PUT/DELETE /sheds/{id}
  - `app/schemas/production.py` — egg/chicken record schemas, trend schemas, farm overview
  - `app/repositories/production_repository.py` — egg/chicken record CRUD + date-range queries
  - `app/services/production_service.py` — record CRUD, trend calc (7d/30d/90d), farm overview
  - `app/api/v1/production.py` — POST/GET eggs & chickens, trends (eggs/mortality/feed), farm overview
  - `app/core/rate_limit.py` — Redis sliding window rate limiter (auth: 10/min, default: 60/min, AI: 20/min)
  - Updated `app/core/middleware.py` with rate limit middleware
  - Updated `app/api/router.py` with all new routers

## What's left to build (high-level)
- [ ] Run Docker stack and validate
- [ ] Generate initial Alembic migration
- [x] Auth service + endpoints (register, login, refresh, logout)
- [x] Farm/Shed CRUD endpoints
- [x] Production record endpoints + trend calculation
- [x] User profile CRUD + avatar upload
- [x] Rate limiting middleware
- [ ] Social auth (Google/Facebook — deferred, needs Firebase setup)
- [ ] Chat subsystem (sessions/messages, SSE streaming, feedback, titles)
- [ ] Gemini AI client wrapper + system prompts + intent classification
- [ ] Health tabs seed + `/health/ask` integration
- [ ] RAG ingestion + vector search + reranking
- [ ] Image diagnosis endpoint + media pipeline
- [ ] Weather + market integrations
- [ ] Insights engine
- [ ] Celery tasks + schedules
- [ ] Live AI WebSocket gateway
- [ ] Tests + security hardening + deployment

## Current milestone snapshot
- **Sprint 1**: COMPLETE (scaffold + models + core infra + health checks)
- **Sprint 2**: COMPLETE (auth + production tracking + farm CRUD + rate limiting)
- **Sprint 3**: NEXT (AI engine + chat + health tabs)
- Sprints 4–8 remain per the plan.

## Known issues / risks
- Market price scraping reliability and legal/terms constraints.
- AI safety and medical guidance must be carefully bounded.
- OCR dependency chain for RAG ingestion in production images.
- Live AI cost control must be enforced server-side.
- Social auth (Google/Facebook) deferred — needs Firebase project setup.
