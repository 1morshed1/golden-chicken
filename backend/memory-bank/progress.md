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

- **Sprint 3 (AI Engine + Chat + Health Tabs) — COMPLETE** (as of 2026-04-24):
  - `app/ai/gemini_client.py` — GeminiClient (text, stream, vision, intent classification, title gen)
  - `app/ai/prompts/system_prompt.py` — EN + BN system prompts with safety guardrails
  - `app/ai/intent.py` — two-stage intent classification (keyword → Flash Lite), 9 categories
  - `app/schemas/chat.py` — session/message request/response schemas
  - `app/schemas/health.py` — health tab response + ask request schemas
  - `app/repositories/chat_repository.py` — ChatSession + ChatMessage repositories
  - `app/repositories/health_repository.py` — HealthTab repository
  - `app/services/chat_service.py` — full chat pipeline (save → classify → history → generate → persist → auto-title)
  - `app/api/v1/chat.py` — session CRUD, sync + SSE streaming message send, feedback
  - `app/api/v1/health_tabs.py` — list/get tabs, POST ask (creates session + sends prefilled prompt)
  - `app/utils/seed_health_tabs.py` — seed 6 diseases (Newcastle, AI, Marek's, Coccidiosis, IB, Fowl Pox)
  - Updated `app/api/router.py` with chat + health_tabs routers
  - Infra: Docker context fix, .env container networking, pydantic[email], bcrypt < 5 pin

## What's left to build (high-level)
- [x] Run Docker stack and validate
- [x] Generate initial Alembic migration
- [x] Auth service + endpoints (register, login, refresh, logout)
- [x] Farm/Shed CRUD endpoints
- [x] Production record endpoints + trend calculation
- [x] User profile CRUD + avatar upload
- [x] Rate limiting middleware
- [x] Chat subsystem (sessions/messages, SSE streaming, feedback, titles)
- [x] Gemini AI client wrapper + system prompts + intent classification
- [x] Health tabs seed + `/health/ask` integration
- [ ] Social auth (Google/Facebook — deferred, needs Firebase setup)
- [ ] RAG ingestion + vector search + reranking
- [ ] Image diagnosis endpoint + media pipeline
- [ ] Weather + market integrations
- [ ] Insights engine
- [ ] Celery tasks + schedules
- [ ] Live AI WebSocket gateway
- [ ] Tests + security hardening + deployment

- **Post-Sprint 3 validation** (as of 2026-04-24):
  - Gemini API key configured and end-to-end chat verified (sync + SSE streaming)
  - Switched from preview models to stable GA: gemini-2.0-flash, gemini-2.0-flash-lite, gemini-2.0-flash-live-001
  - Fixed streaming bug: `generate_content_stream` needs `await` before `async for`
  - Intent classification working (Bangla → egg_production correctly classified)
  - Bilingual AI responses working (EN + BN)
  - Knowledge base created: 10 documents in `knowledge_base/raw/` (diseases, vaccination, feed, biosecurity, weather, breeds, egg production, economics, medicines, emergency first aid)

## Current milestone snapshot
- **Sprint 1**: COMPLETE (scaffold + models + core infra + health checks)
- **Sprint 2**: COMPLETE (auth + production tracking + farm CRUD + rate limiting)
- **Sprint 3**: COMPLETE (AI engine + chat + SSE streaming + health tabs + knowledge base)
- **Sprint 4**: NEXT (RAG ingestion + image diagnosis + task management)
- Sprints 5–8 remain per the plan.

## Known issues / risks
- Market price scraping reliability and legal/terms constraints.
- AI safety and medical guidance must be carefully bounded.
- OCR dependency chain for RAG ingestion in production images.
- Live AI cost control must be enforced server-side.
- Social auth (Google/Facebook) deferred — needs Firebase project setup.
