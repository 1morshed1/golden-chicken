# Active Context — Current Work Focus

## Current state (as of 2026-04-24)
- **Sprint 1 scaffold: COMPLETE.**
- **Sprint 2 (Auth + Production Tracking): COMPLETE.**
- Docker Compose stack defined (Postgres+pgvector, Redis, MinIO, Celery worker + beat).

## What was just completed (Sprint 2)
- **Auth system**: AuthService (register, login, refresh token rotation, logout with Redis JTI blacklist) + SessionRepository + auth API routes (`/api/v1/auth/register|login|refresh|logout`).
- **User profile**: UserService (update profile, avatar upload to S3/MinIO) + user API routes (`/api/v1/users/me`, `/api/v1/users/me/avatar`).
- **Farm & Shed CRUD**: FarmService with ownership checks + farm API routes (`/api/v1/farms` CRUD, `/api/v1/farms/{id}/sheds` CRUD, `/api/v1/sheds/{id}` update/delete). Soft delete for DELETE ops.
- **Production tracking**: ProductionService with egg/chicken record CRUD, date-range queries, trend calculation (7d/30d/90d), farm overview. Production API routes (`/api/v1/sheds/{id}/eggs|chickens`, `/api/v1/sheds/{id}/trends/eggs|mortality|feed`, `/api/v1/farms/{id}/trends/overview`).
- **Rate limiting**: Redis-based rate limiter middleware (auth: 10/min/IP, default: 60/min/user, AI: 20/min/user).
- **Production schemas**: Full Pydantic schemas for egg records, chicken records, trends, and farm overview.

## Immediate next steps
1. **Validate Docker stack** and run initial Alembic migration.
2. Begin **Sprint 3**: Gemini AI client wrapper, system prompts, intent classification, chat session CRUD, SSE streaming, health tabs.

## Decisions currently in effect
- **Modular monolith** architecture for v1.
- **JWT access/refresh** with rotation and Redis blacklist.
- **SSE** for chat streaming and **WebSocket** for Live AI.
- **Bangla/English** language preference supported end-to-end.
- All models created upfront so Alembic can generate the full initial migration.
- Rate limiting uses Redis sliding window counter per endpoint group.
