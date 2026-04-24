# System Patterns — Golden Chicken Backend

## Architecture pattern
- **Layered modular monolith (v1)** designed to be split later.
- Request path: **Router → Controller/Route → Service → Repository → DB**
- External integrations via dedicated services (AI, weather, market).

## Major building blocks
- **API**: FastAPI, versioned routes under `/api/v1`, OpenAPI docs.
- **Domain**: users, farms/sheds/flocks, production records, tasks/reminders, chat, health tabs, insights.
- **AI subsystem**:
  - Gemini text/vision client wrapper.
  - Intent classification: **keywords → Gemini Lite fallback**.
  - System prompts (EN/BN) + safety rules.
  - Chat orchestration pipeline: upload image (optional) → save user msg → classify intent → RAG → enrich with live data (weather/market/flock) → generate response → safety filter → persist response.
  - Live AI: **FastAPI WebSocket ↔ Gemini Live WebSocket** with session manager.
- **RAG**:
  - Knowledge ingestion pipeline (PDF + OCR).
  - Embedding to pgvector, HNSW index.
  - Optional reranker (cross-encoder) before final context build.
- **Async/background jobs**: Celery workers + Celery beat schedules for market scraping, weather refresh, indexing, reminders, cleanup.

## Data patterns
- **PostgreSQL + pgvector** as system-of-record plus vector store.
- **Redis** for:
  - cache (weather responses, etc.)
  - Celery broker
  - pub/sub (future)
  - token revocation/blacklist by JTI
- **Object storage** (S3/MinIO) for user images and documents.
- **Soft delete** for destructive actions (e.g., farms/sheds deletion returns 204).

## API conventions
- **Prefix**: `/api/v1/`
- **Response envelope**:
  - success: `{ "status": "success", "data": ..., "meta": ... }`
  - error: `{ "status": "error", "error": { "code": ..., "message": ..., "details": [...] } }`
- **Streaming**:
  - SSE endpoint for chat streaming (`text/event-stream`).
  - WebSocket protocol for Live AI (audio/video/text messages, transcripts, errors).
- **Rate limiting** by endpoint group (auth/chat/ai streaming/etc.).

## Auth patterns
- JWT **access token** (short-lived) + **refresh token** (long-lived).
- Refresh token **rotation** with hashed storage in `user_sessions`.
- Logout:
  - revoke refresh token in DB
  - blacklist access token JTI in Redis
- Role-based access helper (e.g. `require_role(...)`).

## Safety/guardrails patterns (AI)
- Prompt-level safety rules: avoid unsafe meds, require vet escalation for serious outbreaks.
- Live AI guardrails: session max minutes, daily cap per user, concurrency cap, global spend cap.
- “Grounding first”: use RAG context when applicable; prefer data-backed recommendations.

