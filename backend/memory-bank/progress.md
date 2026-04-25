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
  - `app/repositories/session_repository.py` — UserSession CRUD
  - `app/services/auth_service.py` — register, login, refresh (rotation), logout (Redis blacklist)
  - `app/api/v1/auth.py` — POST register/login/refresh/logout
  - `app/services/user_service.py` — update profile, avatar upload
  - `app/api/v1/users.py` — GET/PUT /users/me, PUT /users/me/avatar
  - `app/services/farm_service.py` — full CRUD with ownership, soft delete
  - `app/api/v1/farms.py` — farm + shed CRUD endpoints
  - Production schemas, repository, service, routes (egg/chicken records, trends, overview)
  - `app/core/rate_limit.py` — Redis sliding window rate limiter

- **Sprint 3 (AI Engine + Chat + Health Tabs) — COMPLETE** (as of 2026-04-24):
  - `app/ai/gemini_client.py` — GeminiClient (text, stream, vision, intent, title)
  - `app/ai/prompts/system_prompt.py` — EN + BN bilingual prompts with safety guardrails
  - `app/ai/intent.py` — two-stage intent classification (keyword → Flash Lite)
  - Chat schemas, repositories, service (full pipeline with SSE streaming)
  - Health tabs schemas, repository, routes + seed script (6 diseases)

- **Sprint 4 (RAG + Image Diagnosis + Tasks) — COMPLETE** (as of 2026-04-25):
  - `app/ai/rag/embedder.py` — BAAI/bge-m3 embedding wrapper
  - `app/ai/rag/reranker.py` — BAAI/bge-reranker-v2-m3 cross-encoder wrapper
  - `app/ai/rag/retriever.py` — vector search → rerank → context builder
  - `app/ai/rag/ingestion.py` — markdown/text/PDF+OCR ingestion, chunking, auto-category
  - `app/repositories/knowledge_repository.py` — pgvector cosine search
  - Updated `app/services/chat_service.py` — RAG integrated into chat pipeline
  - `app/utils/ingest_knowledge.py` — CLI ingestion script
  - `app/ai/prompts/disease_diagnosis.py` — bilingual diagnosis prompts
  - `app/api/v1/diagnosis.py` — POST /diagnosis (image → S3 → Gemini Vision + RAG)
  - Task schemas, repository, service, routes (full CRUD + recurring + overdue + today)

- **Sprint 5 (Weather + Market + Insights) — COMPLETE** (as of 2026-04-25):
  - `app/schemas/weather.py` — WeatherResponse, CurrentWeather, ForecastDay, WeatherAlert, PoultryWeatherAdvisory
  - `app/services/weather_service.py` — OpenWeatherMap integration, Redis cache (1hr), 12 BD regions, heat/cold/humidity advisories
  - `app/api/v1/weather.py` — GET /weather (lat/lon | region | profile), GET /weather/regions
  - `app/schemas/market.py` — MarketPriceResponse, PriceHistoryEntry/Response, MarketPriceListResponse
  - `app/repositories/market_repository.py` — latest prices (subquery), history, stale marking
  - `app/services/market_service.py` — latest prices with 48hr stale warning, history
  - `app/api/v1/market.py` — GET /market/prices, GET /market/prices/{type}/history
  - `app/workers/db.py` — sync session factory for Celery workers
  - `app/workers/tasks/market_scraper.py` — DAM + TCB scrapers, 3 retries, trend calc, stale fallback
  - `app/schemas/insights.py` — InsightResponse, InsightsSummary, InsightsListResponse, InsightAction
  - `app/repositories/insights_repository.py` — filtered queries, severity counts, acknowledge/resolve
  - `app/services/insights_service.py` — production analysis (egg drop 10/20%, mortality 2/5%), overdue tasks, daily generation
  - `app/api/v1/insights.py` — GET /insights, GET /insights/actions, POST acknowledge/resolve/generate
  - `app/workers/tasks/weather_refresh.py` — refreshes all BD region weather caches
  - `app/workers/tasks/insights_generator.py` — generates daily insights for all users
  - Updated `app/workers/celery_app.py` — Beat schedule: market 2x/day, weather every 2hrs, insights 6:30AM
  - Updated `app/api/router.py` — weather, market, insights routers added

## What's left to build (high-level)
- [x] Run Docker stack and validate
- [x] Generate initial Alembic migration
- [x] Auth service + endpoints
- [x] Farm/Shed CRUD endpoints
- [x] Production record endpoints + trends
- [x] User profile CRUD + avatar upload
- [x] Rate limiting middleware
- [x] Chat subsystem (sessions/messages, SSE, feedback, titles)
- [x] Gemini AI client + system prompts + intent classification
- [x] Health tabs seed + /health/ask
- [x] RAG ingestion + vector search + reranking
- [x] Image diagnosis endpoint + media pipeline
- [x] Task management CRUD + recurring + overdue + today
- [x] Weather integration (OpenWeatherMap + Redis cache + poultry advisories)
- [x] Market price service + scrapers (DAM/TCB) + stale-data strategy
- [x] Insights engine (production analysis + task compliance + daily generation)
- [x] Celery Beat schedule (market, weather, insights)
- [x] Sync DB session for Celery workers
- [ ] Social auth (Google/Facebook — deferred, needs Firebase setup)
- [ ] Live AI WebSocket gateway
- [ ] Tests + security hardening + deployment

## Current milestone snapshot
- **Sprint 1**: COMPLETE (scaffold + models + core infra + health checks)
- **Sprint 2**: COMPLETE (auth + production tracking + farm CRUD + rate limiting)
- **Sprint 3**: COMPLETE (AI engine + chat + SSE streaming + health tabs + knowledge base)
- **Sprint 4**: COMPLETE (RAG pipeline + image diagnosis + task management)
- **Sprint 5**: COMPLETE (weather + market + insights + Celery Beat)
- **Sprint 6**: NEXT (Live AI WebSocket gateway)
- Sprints 7–8 remain per the plan.

## Known issues / risks
- Market price scraping reliability — DAM/TCB HTML may change without notice; stale-data strategy mitigates.
- AI safety and medical guidance must be carefully bounded.
- OCR dependency chain for RAG ingestion (tesseract + poppler).
- Live AI cost control must be enforced server-side.
- Social auth (Google/Facebook) deferred — needs Firebase project setup.
- RAG models (bge-m3, bge-reranker-v2-m3) require ~1-2GB memory.
- Knowledge base ingestion needs to be run after Alembic migration.
- Insights engine currently rule-based; weather/market cross-analysis is basic.
