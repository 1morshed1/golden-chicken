# Active Context — Current Work Focus

## Current state (as of 2026-04-25)
- **Sprint 1 scaffold: COMPLETE.**
- **Sprint 2 (Auth + Production Tracking): COMPLETE.**
- **Sprint 3 (AI Engine + Chat + Health Tabs): COMPLETE.**
- **Sprint 4 (RAG + Image Diagnosis + Tasks): COMPLETE.**
- **Sprint 5 (Weather + Market + Insights): COMPLETE.**
- Docker Compose stack validated and running (all 6 services healthy).
- Initial Alembic migration applied. Health tabs seeded (6 diseases).

## What was just completed (Sprint 5)
- **Weather Service**: `app/services/weather_service.py` — OpenWeatherMap integration with Redis caching (1hr TTL), 12 Bangladesh regions mapped, poultry-specific heat/cold/humidity stress advisories.
- **Weather Schemas**: `app/schemas/weather.py` — WeatherResponse, CurrentWeather, ForecastDay, WeatherAlert, PoultryWeatherAdvisory.
- **Weather Routes**: `app/api/v1/weather.py` — GET /weather (lat/lon, region name, or user profile fallback), GET /weather/regions.
- **Market Schemas**: `app/schemas/market.py` — MarketPriceResponse, MarketPriceListResponse, PriceHistoryEntry/Response.
- **Market Repository**: `app/repositories/market_repository.py` — latest price query (subquery for most recent per product/market), history, stale marking, upsert.
- **Market Service**: `app/services/market_service.py` — get latest prices with stale-data warning (48hr threshold), price history.
- **Market Routes**: `app/api/v1/market.py` — GET /market/prices (product_type/region filters), GET /market/prices/{product_type}/history.
- **Market Scrapers**: `app/workers/tasks/market_scraper.py` — DAM + TCB scrapers as Celery tasks with 3 retries, trend calculation (up/down/stable), stale marking on total failure.
- **Insights Schemas**: `app/schemas/insights.py` — InsightResponse, InsightsSummary, InsightsListResponse, InsightAction.
- **Insights Repository**: `app/repositories/insights_repository.py` — filtered queries, severity counts, unresolved actions, acknowledge/resolve.
- **Insights Service**: `app/services/insights_service.py` — production analysis (egg drop warning/critical at 10%/20%, mortality spike at 2%/5%), overdue task detection (vaccination prioritized as critical), daily insight generation across all user sheds.
- **Insights Routes**: `app/api/v1/insights.py` — GET /insights (severity/shed filter), GET /insights/actions, POST /insights/{id}/acknowledge, POST /insights/{id}/resolve, POST /insights/generate.
- **Celery Beat Schedule**: Market scraping 2x/day (8AM, 6PM), weather refresh every 2hrs, daily insight generation at 6:30AM (all Asia/Dhaka).
- **Sync DB Session**: `app/workers/db.py` — sync session factory for Celery workers using psycopg driver.
- **Weather Refresh Task**: `app/workers/tasks/weather_refresh.py` — refreshes all BD region caches.
- **Insights Generator Task**: `app/workers/tasks/insights_generator.py` — generates daily insights for all active users.
- **Router Update**: Added weather, market, insights routers.

## Immediate next steps
1. Begin **Sprint 6**: Live AI WebSocket gateway (Gemini Live), real-time audio/video forwarding, function calling tools, guardrails.

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
