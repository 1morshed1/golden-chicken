# Active Context — Golden Chicken Frontend

## Current focus
Sprint 4 is complete. The app now has Market Insights (price hero cards, fl_chart trend charts, period toggle, AI tips), Tasks (task list with overdue/today/upcoming/completed sections, create task with type selector and recurrence picker), and all data screens are functional.

**Next up: Sprint 5** — Profile (avatar, loyalty points, preferences, edit profile), Insights (farm insight cards, action checklist), and Live AI (audio/video streaming via WebSocket, transcript overlay, session lifecycle).

## Most important decisions already made
- **Feature-first Clean Architecture** across all features (auth, chat, health, production, market, tasks)
- **AuthBloc** is global, drives router redirects via ValueNotifier
- **Phone→email mapping**: UI shows phone, maps to `{phone}@goldenchicken.ai` for backend
- **Either<Failure, T>** for all repository returns, DioException mapped to typed Failures
- **SSE streaming** for chat; WebSocket planned for Live AI
- **fl_chart** for trend graphs (market prices, will extend to production)
- **Task recurrence** modeled as enum (none/daily/weekly/custom)
- **Market trend** fetches egg and meat trends in parallel after prices load

## Immediate next steps (Sprint 5)
1. Profile screen: avatar, name, phone, location, loyalty points card
2. Edit profile screen with form
3. ProfileBloc with user data from API
4. Language toggle and dark mode toggle (wired to existing LocaleCubit/ThemeCubit)
5. Farm insights screen: insight cards with severity, action items
6. InsightsBloc
7. Live AI screen: camera preview, mic button, transcript overlay
8. AudioRecorderService (PCM 16kHz), AudioPlayerService (PCM 24kHz)
9. CameraFrameService (JPEG ≤1 FPS)
10. LiveAIWebSocketDatasource + LiveAIBloc (session lifecycle, state machine)

## Known open questions / risks
- Live AI: confirm backend WebSocket message protocol (audio/video frame formats)
- Live AI: handle close code 4003 (guardrail) with user-friendly message
- Shed selection: still hardcoded to 'default' in production records
- Offline queues not yet implemented
- Fonts loaded via google_fonts (network) — bundle for production
