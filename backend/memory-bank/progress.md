# Progress — Golden Chicken Backend

## What exists
- **Backend implementation plan** documenting:
  - Architecture (FastAPI layered modular monolith)
  - Full tech stack and dependencies
  - Intended folder structure
  - Database/ERD outline and model examples
  - Auth approach (JWT rotation + revocation)
  - API endpoints (v1)
  - Gemini AI integration (text/vision/live)
  - RAG pipeline (ingest → embed → retrieve → rerank → context)
  - Deployment plan (Docker Compose, CI/CD) and milestones
- **Memory Bank** created under `memory-bank/` (this folder).

## What’s left to build (high-level)
- Project scaffold matching the planned structure.
- Database models + Alembic migrations for core entities.
- Auth endpoints and session/token mechanics.
- Farm/shed CRUD, production record endpoints, trends service.
- Chat subsystem (sessions/messages, SSE streaming, feedback, titles).
- Health tabs seed + `/health/ask` integration.
- RAG ingestion + vector search + reranking.
- Image diagnosis endpoint and media pipeline (S3/MinIO).
- Weather + market integrations with caching and stale-data handling.
- Insights engine and endpoints.
- Celery tasks + schedules (scraping, reminders, cleanup, indexing).
- Live AI WebSocket gateway to Gemini Live API with guardrails.
- Tests (unit + integration), security hardening, deployment.

## Current milestone snapshot (from the plan)
- Sprint roadmap defined through **Sprint 8** (deployment & launch).
- v1.1 backlog includes multi-replica fan-out, Prometheus/Grafana, FCM, OTP/reset, sensor integrations, veterinary collaboration.

## Known issues / risks
- Market price scraping reliability and legal/terms constraints.
- AI safety and medical guidance must be carefully bounded (withdrawal periods, vet escalation).
- OCR dependency chain for RAG ingestion (tesseract + poppler) in production images.
- Live AI cost control (daily caps/spend caps) must be enforced server-side.

