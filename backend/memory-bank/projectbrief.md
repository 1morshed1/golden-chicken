# Golden Chicken Backend — Project Brief

## Purpose
Build the **Golden Chicken backend**: an API-first platform that powers a Flutter mobile app for Bangladeshi poultry farmers and stakeholders. The backend combines **farm management + production tracking + tasks/reminders + AI advisory (text/vision/voice) + data integrations** (weather, market prices) and an analytics/insights layer.

## Primary users
- Poultry farmers (layer/broiler)
- Farm managers/supervisors
- Veterinarians / livestock advisors
- Business owners / cooperative members
- Admins (limited; no Django-admin requirement)

## Core product capabilities (v1 target)
- **Auth & identity**: email/password + social login, JWT access/refresh with rotation, token revocation.
- **Farm domain**: farms → sheds/flocks, basic setup and management.
- **Production tracking**: daily egg records, bird counts/mortality, trends (7d/30d/90d) and overview rollups.
- **Tasks & reminders**: recurring tasks, overdue detection, “today” view.
- **AI advisory chat**:
  - Text advisory chat with streaming (SSE).
  - Vision-based poultry disease help via image upload.
  - “Health tabs” (prefilled disease prompts) → chat.
  - “Live AI” real-time voice + camera via WebSocket backed by Gemini Live API.
- **RAG knowledge base**: ingest poultry docs (PDF/OCR), embed into pgvector, retrieve+rerank for grounded answers.
- **Integrations**: weather (OpenWeatherMap), market price intelligence (scrapers/APIs).
- **Insights/analytics**: generate farm insights (production drop, mortality spikes, overdue tasks, weather alerts, market opportunities) and proposed actions.

## Non-goals / explicitly deferred
- Splitting into microservices (v1 is a **layered modular monolith**).
- Heavy admin UI (Flutter app is primary interface).
- Advanced observability stack (Prometheus/Grafana backlog).
- Push notifications, OTP, password reset (v1.1 backlog).

## Success criteria
- Stable, versioned API (`/api/v1`) with consistent response envelope and robust error handling.
- Secure auth implementation with revocation/rotation.
- AI features are safe, practical, bilingual-friendly, and cost-guardrailed.
- Local dev stack runs via Docker Compose (Postgres+pgvector, Redis, MinIO, workers).

## Source document
Derived from `GoldenChicken_Backend_Implementation_Plan.md` (April 2026).

