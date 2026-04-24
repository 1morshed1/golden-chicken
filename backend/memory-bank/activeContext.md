# Active Context — Current Work Focus

## Current state (as of 2026-04-24)
- **Sprint 1 scaffold: COMPLETE.**
- **Sprint 2 (Auth + Production Tracking): COMPLETE.**
- **Sprint 3 (AI Engine + Chat + Health Tabs): COMPLETE.**
- Docker Compose stack validated and running (all 6 services healthy).
- Initial Alembic migration applied. Health tabs seeded (6 diseases).

## What was just completed (Sprint 3)
- **Gemini client**: `app/ai/gemini_client.py` — text generation, streaming, image analysis, intent classification (Flash Lite), session title generation.
- **System prompts**: `app/ai/prompts/system_prompt.py` — EN + BN bilingual prompts with safety guardrails.
- **Intent classification**: `app/ai/intent.py` — two-stage (keyword match → Gemini Lite fallback), 9-category taxonomy.
- **Chat CRUD**: ChatSessionRepository + ChatMessageRepository + ChatService with full pipeline (save → classify → history → generate → persist → auto-title).
- **SSE streaming**: `POST /chat/sessions/{id}/messages/stream` — server-sent events for real-time AI response streaming.
- **Chat routes**: `app/api/v1/chat.py` — session CRUD, message send (sync + stream), message feedback.
- **Health tabs**: HealthTabRepository + routes (`GET /health-tabs`, `GET /health-tabs/{id}`, `POST /health-tabs/{id}/ask`) + seed script with 6 diseases (Newcastle, AI, Marek's, Coccidiosis, IB, Fowl Pox).
- **Infra fixes**: Docker context switched from Desktop to Engine, `.env` updated for container networking (postgres/redis/minio hostnames), `pydantic[email]` added, bcrypt pinned < 5.0 for passlib compat.

## What was just completed (post-Sprint 3)
- **Gemini API key** set and **end-to-end chat verified** — sync and SSE streaming both working.
- **Model switch**: Changed from preview models (gemini-3-flash-preview) to stable GA models (gemini-2.0-flash, gemini-2.0-flash-lite) to avoid 503 high-demand errors.
- **Streaming fix**: `generate_content_stream` needed `await` before `async for` (SDK API difference).
- **Intent classification** verified working — Bangla query correctly classified as `egg_production`.
- **Bilingual responses** verified — AI responds in Bangla when language=bn, with Bangladesh-specific context.
- **Knowledge base**: 10 comprehensive markdown documents created in `knowledge_base/raw/` covering diseases, vaccination, feed, biosecurity, weather, breeds, egg production, economics, medicines, and emergency first aid — all Bangladesh-specific.

## Immediate next steps
1. Begin **Sprint 4**: RAG ingestion pipeline (ingest knowledge base into pgvector), image diagnosis, task management CRUD.

## Decisions currently in effect
- **Modular monolith** architecture for v1.
- **JWT access/refresh** with rotation and Redis blacklist.
- **SSE** for chat streaming and **WebSocket** for Live AI.
- **Bangla/English** language preference supported end-to-end.
- All models created upfront so Alembic can generate the full initial migration.
- Rate limiting uses Redis sliding window counter per endpoint group.
- Docker `.env` uses container service names (postgres/redis/minio), not localhost.
