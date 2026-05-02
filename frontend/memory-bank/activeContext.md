# Active Context — Golden Chicken Frontend

## Current focus
Sprint 7 in progress. Market Insights and Flock Overview API mismatches fixed and validated with seeded data. Physical device testing ongoing (Samsung SM-M405F via devtunnel). Backend is Dockerized and accessed via devtunnel (`dplss5n1-8000.inc1.devtunnels.ms`).

## Most important decisions already made
- **Feature-first Clean Architecture** across all features (auth, chat, health, production, market, tasks, profile, insights, live_ai)
- **AuthBloc** is global, drives router redirects via ValueNotifier
- **Phone→email mapping**: UI shows phone, maps to `{phone}@goldenchicken.ai` for backend
- **Either<Failure, T>** for all repository returns, DioException mapped to typed Failures
- **SSE streaming** for chat; **WebSocket** for Live AI (web_socket_channel)
- **fl_chart** for trend graphs (market prices, will extend to production)
- **Task recurrence** modeled as enum (none/daily/weekly/custom)
- **Market trend** fetches egg and broiler_meat trends in parallel after prices load; period string (7d/30d/today) converted to `days` int for backend
- **Market API alignment**: Backend wraps prices in `{data: {prices: [...]}}` and history in `{data: {history: [...]}}` with `price_bdt` field — frontend datasource updated to match
- **Flock Overview**: No dedicated backend endpoint; frontend aggregates from `GET /farms` + `GET /farms/{id}/sheds` client-side (total birds, avg age, alerts from shed status, estimated feed plan)
- **Backend seeded data**: 30 days of realistic market prices (scraped from DAM/TCB/Numbeo: egg ~৳12/pc, broiler ~৳180/kg, layer ~৳270/kg, feed ~৳55/kg, chick ~৳40/pc) + 1 farm with 4 sheds (1,650 birds total)
- **Live AI state machine**: idle → connecting → listening → aiSpeaking → error
- **Profile loyalty card**: gradient background with tier badge and points-to-next-tier
- **Audio services**: AudioRecorderService (PCM 16kHz mono via `record` package), AudioPlayerService (PCM 24kHz via `just_audio` with WAV header wrapping)
- **Camera service**: CameraFrameService captures JPEG at ≤1 FPS via `camera` package
- **Offline queue**: Hive-backed PendingMutation queue with auto-sync via connectivity_plus listener
- **Fonts bundled**: Plus Jakarta Sans + Hind Siliguri loaded from assets/fonts/ (removed google_fonts network dependency)
- **Shed picker**: Dynamic shed dropdown in egg/chicken record screens (fetches from API)
- **Chat session creation retry**: 3 attempts with backoff + shorter 15s timeout to handle flaky tunnel/network

## Recent fixes (physical device testing session, 2026-05-02)
### Frontend — API alignment fixes
- **Market datasource**: Fixed response parsing — backend wraps in `{data: {prices: [...]}}` and `{data: {history: []}}`, not `{data: [...]}` directly. Changed `price` → `price_bdt` in PriceTrendPointModel. Converted period string to `days` int query param. Changed product `meat` → `broiler_meat`.
- **Market bloc**: Parallelized egg + broiler_meat trend fetches with `Future.wait`
- **Market repository**: Added generic catch blocks so JSON parsing errors emit error state instead of leaving bloc stuck on MarketLoading
- **Flock Overview datasource**: Rewrote `getFlockOverview()` — backend has no flock overview endpoint, so it now fetches farms list + sheds per farm and aggregates client-side
- **Production repository**: Added generic catch blocks for parsing errors

### Frontend — earlier fixes
- **Base URL**: Changed from localhost to devtunnel HTTPS URL for physical device access
- **API client timeouts**: Increased to 15s connect / 60s receive; added IOHttpClientAdapter with 5s idle timeout to prevent stale TCP connections through tunnel
- **Chat race condition**: Initial prompt from home tab was silently dropped because `ChatMessageSent` was dispatched before `ChatSessionStarted` finished. Fixed by passing `initialPrompt` through `ChatSessionStarted` event.
- **Session creation retry**: Added 3-attempt retry with backoff in `ChatRemoteDatasourceImpl.createSession()` for timeout resilience

### Backend (changes made in `/backend/`)
- **Gemini models**: Updated from deprecated names to `gemini-2.5-flash`, `gemini-2.5-flash-lite`, `gemini-2.5-flash-live-001`
- **Chat history role mapping**: Fixed `_format_history` to map `ASSISTANT` → `"model"` for Gemini API compatibility
- **GET messages endpoint**: Added `GET /chat/sessions/{id}/messages` to `chat.py` — needed for Health Center Ask AI flow and loading existing chat sessions. Uses `get_session_messages` (direct query) instead of `get_with_messages` (which fails because `ChatSession.messages` uses `lazy="dynamic"` incompatible with `selectinload`)

### Backend — seeded demo data
- **Market prices**: 150 rows — 30 days × 5 products (egg, broiler_meat, layer_meat, feed, chick) with realistic BDT prices scraped from DAM/TCB/Numbeo sources
- **Farm + sheds**: 1 farm ("Savar Poultry Farm") with 4 sheds: Layers (500 birds, 120d, Hy-Line Brown), Broilers (800 birds, 28d, Cobb 500), Broilers Batch 2 (350 birds, 42d, Ross 308), Preparing (empty)
- **Important**: Seeded data must be linked to the correct authenticated user ID (`2f30ea8d-...`) — `GET /farms` filters by user

## Immediate next steps (Sprint 7)
1. End-to-end integration testing (with emulators)
2. CI/CD pipeline setup (GitHub Actions)
3. App signing and flavor configuration (dev/staging/production)
4. Performance profiling and optimization
5. Accessibility audit (screen reader, contrast)
6. Final design polish pass against Figma.pdf

## Known open questions / risks
- Live AI: handle close code 4003 (guardrail) with user-friendly message
- Live AI: confirm backend audio format expectations (PCM 16kHz recording, 24kHz playback assumed)
- Live AI: camera frame JPEG quality/compression tuning for bandwidth
- StreamAudioSource is experimental in just_audio — may need alternative if removed
- Offline queue: retry strategy for 4xx errors vs 5xx (currently discards on non-network errors)
- google_fonts package kept in pubspec as optional fallback but no longer imported
- Devtunnel intermittently drops requests/responses — not an issue on real server deployment
- First RAG request after backend cold start takes ~165s (embedding model load); subsequent ~15s
