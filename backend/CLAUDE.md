# Claude Code Instructions — Golden Chicken Backend

## Prime directive
- **Read the Memory Bank first** before making plans or changes:
  - `memory-bank/projectbrief.md`
  - `memory-bank/productContext.md`
  - `memory-bank/systemPatterns.md`
  - `memory-bank/techContext.md`
  - `memory-bank/activeContext.md`
  - `memory-bank/progress.md`
- Keep changes aligned with the **implementation plan**: `GoldenChicken_Backend_Implementation_Plan.md`

## Project overview
- Backend for a Flutter app serving **Bangladeshi poultry farmers**
- Stack: **FastAPI + SQLAlchemy (async) + PostgreSQL (pgvector) + Redis + MinIO/S3 + Celery**
- AI: **Google Gemini** (text/vision) + **Gemini Live** (real-time voice/camera)
- Key features: auth, farms/sheds, production tracking, tasks, chat (SSE), live AI (WS), RAG, weather, market, insights

## Architecture & module boundaries (must follow)
- Pattern: **Layered modular monolith**
- Request flow: **API route → Service → Repository → DB**
- No business logic in route handlers beyond basic request parsing/validation.
- Place code in these buckets:
  - `app/api/v1/*`: HTTP/WebSocket endpoints and request/response wiring
  - `app/services/*`: business logic orchestration
  - `app/repositories/*`: DB access and queries
  - `app/models/*`: SQLAlchemy ORM models
  - `app/schemas/*`: Pydantic request/response models
  - `app/core/*`: config, db, redis, middleware, security, exceptions, dependencies
  - `app/ai/*`: Gemini clients, prompts, RAG, live session manager
  - `app/workers/*`: Celery app + tasks + schedules

## API conventions
- Base prefix: **`/api/v1`**
- Response envelope:
  - Success: `{ "status": "success", "data": ..., "meta": ... }`
  - Error: `{ "status": "error", "error": { "code": ..., "message": ..., "details": [...] } }`
- Streaming:
  - Chat streaming via **SSE** (`text/event-stream`)
  - Live AI via **WebSocket** (`/api/v1/live-ai/stream`)

## Auth & security requirements
- JWT access token (short-lived) + refresh token (long-lived)
- **Refresh rotation** with refresh token hash stored in DB (`user_sessions`)
- Logout revokes refresh token in DB and **blacklists access token JTI in Redis**
- Enforce role-based access using a dependency/helper (e.g. `require_role`)
- Never log secrets/tokens; redact sensitive fields.

## AI / safety / cost guardrails (do not violate)
- Responses must be **practical, step-based**, and bilingual-friendly (Bangla/English).
- Avoid unsafe medical advice:
  - No banned antibiotics/growth hormones.
  - Include withdrawal period warnings where relevant.
  - For outbreaks (e.g., Avian Influenza/Newcastle), recommend contacting local livestock office/vet.
- Live AI must enforce guardrails (planned env vars):
  - per-session max minutes, per-user daily minutes cap
  - concurrent session limit per user
  - global daily spend cap

## RAG expectations
- Ingestion supports **PDF + OCR**; store chunks + embeddings in Postgres/pgvector.
- Retrieval pipeline: vector search (top-k) → optional rerank → context builder.
- Prefer grounded answers when RAG context exists; otherwise clearly indicate uncertainty.

## Code quality standards
- Prefer **typed** Python, clear function boundaries, small modules.
- Use async for FastAPI request path; use sync DB sessions only inside Celery workers where planned.
- Centralize error handling via `app/core/exception_handlers.py`.
- Avoid heavy abstractions early; keep v1 maintainable and testable.

## Testing expectations
- Use `pytest` / `pytest-asyncio` for async services/routes.
- Critical paths to cover first: auth, chat flow (including SSE), production records, task flow.

## Local development expectations
- Docker Compose stack includes: app, postgres(pgvector), redis, minio, celery-worker, celery-beat.
- Prefer documenting runnable commands in `README` when adding/altering setup.

## Working style for Claude Code
- When asked to implement: start by locating existing code; **don’t create parallel frameworks**.
- Make small, reviewable commits only when the user explicitly asks.
- After significant changes, update `memory-bank/activeContext.md` + `memory-bank/progress.md`.

