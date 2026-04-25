# Active Context — Golden Chicken Frontend

## Current focus
Sprint 5 is complete. The app now has Profile (avatar, loyalty card, preferences with language/theme toggles, edit profile), Insights (insight cards with severity-colored borders, acknowledge flow, active/acknowledged sections), and Live AI (WebSocket-based session with state machine, transcript overlay, mic/stop controls).

**Next up: Sprint 6** — Polish, offline support, and production readiness (audio/camera services for Live AI, offline queues, font bundling, shed picker).

## Most important decisions already made
- **Feature-first Clean Architecture** across all features (auth, chat, health, production, market, tasks, profile, insights, live_ai)
- **AuthBloc** is global, drives router redirects via ValueNotifier
- **Phone→email mapping**: UI shows phone, maps to `{phone}@goldenchicken.ai` for backend
- **Either<Failure, T>** for all repository returns, DioException mapped to typed Failures
- **SSE streaming** for chat; **WebSocket** for Live AI (web_socket_channel)
- **fl_chart** for trend graphs (market prices, will extend to production)
- **Task recurrence** modeled as enum (none/daily/weekly/custom)
- **Market trend** fetches egg and meat trends in parallel after prices load
- **Live AI state machine**: idle → connecting → listening → aiSpeaking → error
- **Profile loyalty card**: gradient background with tier badge and points-to-next-tier

## Immediate next steps (Sprint 6)
1. AudioRecorderService (PCM 16kHz) and AudioPlayerService (PCM 24kHz) for Live AI
2. CameraFrameService (JPEG ≤1 FPS) for Live AI video frames
3. Offline write queues (hive-backed mutation queue, sync on reconnect)
4. Bundle fonts for production (remove google_fonts network dependency)
5. Shed picker in production record screens (replace hardcoded 'default')
6. Integration tests for critical flows

## Known open questions / risks
- Live AI: audio recording/playback services not yet implemented (need platform channel or plugin)
- Live AI: camera frame capture not yet implemented
- Live AI: handle close code 4003 (guardrail) with user-friendly message
- Shed selection: still hardcoded to 'default' in production records
- Offline queues not yet implemented
- Fonts loaded via google_fonts (network) — bundle for production
