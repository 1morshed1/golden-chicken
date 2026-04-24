# Project Brief — Golden Chicken (Frontend)

## What we’re building
**Golden Chicken** is a mobile app frontend for poultry farmers (Bangladesh-first) that combines:
- **AI chat** for farm guidance (text + image diagnosis, streaming responses)
- **Health Center** (diseases/vaccines/emergency/diagnosis) with “Ask AI” entry points
- **Production tracking** (eggs, chickens) with trends/graphs
- **Tasks/routine planner** (today, overdue, recurring)
- **Market insights** (live prices, trends, AI market tips)
- **Profile & preferences** (language, dark mode, notifications, data export, loyalty points)
- **Live AI** (real-time voice + camera session streaming through backend to Gemini Live)

## Primary users
- Poultry farmers and farm managers using Android/iOS

## Key experience goals
- **Bangla-first UX** with optional English (EN/BN switch)
- **Fast, clear, offline-tolerant** for farm environments
- **Trustworthy AI guidance** with visible states (loading/streaming/listening/speaking) and robust error handling

## Non-goals (for v1 scope control)
- Admin dashboards or web experiences
- Heavy on-device ML (AI is cloud-backed via backend)

## Constraints & assumptions
- **Mobile**: Android & iOS.
- **AI**: Live AI is mediated via backend WebSocket; chat uses SSE streaming.
- **Security**: auth tokens stored securely; network layer uses interceptors.

## Success criteria (v1)
- Users can complete onboarding (language) → auth → reach home shell.
- Users can chat with AI (streaming) and upload images for diagnosis.
- Users can view health/market/production data with caching and usable empty/error states.
- Live AI session connects, streams mic/camera, shows transcript, and handles guardrails cleanly.

