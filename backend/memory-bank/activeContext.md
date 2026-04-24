# Active Context — Current Work Focus

## Current state (as of Apr 2026)
- The repository contains an implementation plan document: `GoldenChicken_Backend_Implementation_Plan.md`.
- A full target architecture and module layout is defined in that plan (FastAPI + SQLAlchemy async + Postgres/pgvector + Redis + MinIO + Celery + Gemini AI).

## What we are doing now
- Establishing the **Memory Bank** documentation so future sessions can continue work reliably.

## Immediate next steps (once implementation begins)
- Scaffold backend to match the planned structure:
  - `app/main.py` app factory + lifespan
  - `app/config.py`, `app/core/*` (db/redis/security/deps/exceptions/middleware)
  - `app/models/*`, `app/schemas/*`, `app/repositories/*`, `app/services/*`
  - `app/api/v1/*` endpoints and router aggregation
  - `app/ai/*` (Gemini clients, prompts, RAG, live session manager)
  - `app/workers/*` Celery app and tasks
- Set up Docker Compose and local dependencies (Postgres pgvector, Redis, MinIO).
- Implement Sprint 1 deliverables first (foundation + farm domain + health checks + logging).

## Decisions currently in effect
- **Modular monolith** architecture for v1.
- **JWT access/refresh** with rotation and Redis blacklist.
- **SSE** for chat streaming and **WebSocket** for Live AI.
- **Bangla/English** language preference supported end-to-end.

## Open questions / watch-outs (to validate during implementation)
- Whether the actual repo already includes some scaffold/code differing from the plan (if so, reconcile rather than rewrite).
- Final choices for market data sources (API vs scraping reliability).
- OCR/system package availability for ingestion pipeline in target deployment.

