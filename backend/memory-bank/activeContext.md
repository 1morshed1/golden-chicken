# Active Context — Current Work Focus

## Current state (as of 2026-04-25)
- **Sprint 1 scaffold: COMPLETE.**
- **Sprint 2 (Auth + Production Tracking): COMPLETE.**
- **Sprint 3 (AI Engine + Chat + Health Tabs): COMPLETE.**
- **Sprint 4 (RAG + Image Diagnosis + Tasks): COMPLETE.**
- **Sprint 5 (Weather + Market + Insights): COMPLETE.**
- **Sprint 6 (Live AI WebSocket Gateway): COMPLETE.**
- **Sprint 7 (Testing, Security & Polish): COMPLETE.**
- Docker Compose stack validated and running (all 6 services healthy).
- Initial Alembic migration applied. Health tabs seeded (6 diseases).

## What was just completed (Post-Sprint 7 — Testing & Bug Fixes)
- **Test infrastructure overhaul**: Separated root `tests/conftest.py` (mock_redis only) from `tests/integration/conftest.py` (DB-dependent fixtures). Fixed pytest-asyncio 1.3.0 event loop conflicts by using sync engine for DDL/cleanup and fresh async engine per test.
- **Bug fix**: `app/workers/tasks/cleanup.py` had broken import (`sync_session_factory` → `task_db_session`). The daily data retention Celery task would have crashed at runtime.
- **Test data fix**: `test_warning_egg_drop` had data that didn't actually trigger the -10% threshold (-9.8% instead). Fixed to -16.7%.
- **bcrypt version**: Downgraded from 5.0.0 to 4.x for passlib 1.7.4 compatibility.
- **Full test suite**: 103 tests passing (89 unit + 14 integration).

## What was completed (Sprint 7)
- **Test Infrastructure**: `tests/conftest.py` — async test DB (goldenchicken_test), mock Redis, httpx AsyncClient, auth_headers fixtures. Subdirectory structure with `__init__.py` for unit/integration/factories/fixtures.
- **Auth Tests**: `tests/unit/services/test_auth_service.py` — 10 tests: password hashing, JWT create/decode/expired/invalid, register success/duplicate, login success/wrong password/nonexistent/inactive, logout blacklist, refresh rotation/revoked.
- **Auth Integration Tests**: `tests/integration/test_auth_api.py` — 12 tests: register success/duplicate/short password/invalid email/with role, login success/wrong password/nonexistent, refresh success/invalid, logout success/no token, protected endpoint access.
- **Production Tests**: `tests/unit/services/test_production_service.py` — 13 tests: trend calculation (up/down/stable/single/empty), egg summary (empty/single/multiple), chicken summary (empty/mortality), shed access (not found/wrong owner/ok), duplicate date conflict.
- **Task Tests**: `tests/unit/services/test_task_service.py` — 10 tests: get task (not found/wrong owner/success), complete (non-recurring/daily/weekly generates next), today view (counts/empty), overdue tasks, delete (own/other user).
- **AI Intent Tests**: `tests/unit/ai/test_intent.py` — 12 tests: keyword classification (disease EN/BN, feeding, vaccination, egg, broiler, weather, market, biosecurity), LLM fallback (ambiguous/unknown/valid).
- **Prompt Injection Tests**: `tests/unit/ai/test_safety.py` — 14 tests: clean input, ignore instructions, you are now, system:, act as, pretend, jailbreak, bangla passes, mixed case, normal "ignore", do not tell, reveal prompt.
- **Weather Tests**: `tests/unit/services/test_weather_service.py` — 7 tests: critical/warning heat, cold stress, high humidity, normal conditions, threshold boundaries.
- **Insights Tests**: `tests/unit/services/test_insights_service.py` — 12 tests: egg production (critical/warning/stable/few records), mortality (critical/warning/low/none), overdue tasks (vaccination critical/many non-vaccination/none), acknowledge/resolve (not found/wrong user).
- **Market Tests**: `tests/unit/services/test_market_service.py` — 5 tests: fresh data no warning, stale data warning, no data, boundary 48hrs, product type filter.
- **Prompt Injection Safety Guard**: `app/ai/safety.py` — 13 regex patterns covering ignore/override/pretend/jailbreak/reveal/system/act-as. Wired into chat service (`send_message`, `send_message_stream`) and Live AI WebSocket (text messages).
- **Data Retention Cleanup**: `app/workers/tasks/cleanup.py` — Celery task: removes expired+revoked sessions, hard-deletes soft-deleted users after 30 days. Scheduled at 3:00 AM daily via Celery Beat.

## Immediate next steps
1. **Sprint 8 (Deployment & Launch): DEFERRED** — user chose to defer until later.
2. Social auth (Google/Facebook) also deferred — needs Firebase setup.

## Decisions currently in effect
- **Modular monolith** architecture for v1.
- **JWT access/refresh** with rotation and Redis blacklist.
- **SSE** for chat streaming and **WebSocket** for Live AI.
- **Bangla/English** language preference supported end-to-end.
- All models created upfront so Alembic can generate the full initial migration.
- Rate limiting uses Redis sliding window counter per endpoint group.
- Docker `.env` uses container service names (postgres/redis/minio), not localhost.
- RAG retrieval fails gracefully — chat continues without context if embedding/rerank fails.
- Image diagnosis creates a chat session for follow-up conversation.
- Recurring tasks auto-generate the next occurrence on completion.
- Weather data cached in Redis with 1hr TTL; proactively refreshed every 2hrs for BD regions.
- Market prices use stale-data degradation strategy: serve last-known-good with warnings.
- Celery Beat runs in Asia/Dhaka timezone for farmer-relevant schedules.
- Insights generation is rule-based (production thresholds + task compliance); weather/market insights planned.
- Live AI uses single-replica in-process session dict; multi-replica fan-out deferred to v1.1.
- WS handler uses short-lived DB sessions per tool call, not Depends(get_db).
- Live AI guardrails enforced server-side via Redis counters with 24hr TTL.
- Session max minutes capped to min(config max, user remaining daily minutes).
- Prompt injection guard applied to all user text input (chat + Live AI text messages).
- Test DB uses separate `goldenchicken_test` database with per-test TRUNCATE cleanup (sync engine).
- Unit tests run without Docker (mock-only); integration tests need postgres + redis containers.
- Root `tests/conftest.py` has only `mock_redis`; DB fixtures live in `tests/integration/conftest.py`.
- Data retention: expired sessions cleaned, soft-deleted users purged after 30 days.
