# Active Context — Golden Chicken Frontend

## Current focus
Sprint 6 + API contract alignment complete. All frontend data contracts now match the running backend (devtunnel at dplss5n1-8000.inc1.devtunnels.ms). Changes span 20+ files: endpoint paths, field names, HTTP methods, envelope parsing, expanded enums, and new fields. All 18 tests pass, zero analysis errors.

**Next up: Sprint 7** — End-to-end integration testing, CI/CD, and launch readiness.

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
- **Audio services**: AudioRecorderService (PCM 16kHz mono via `record` package), AudioPlayerService (PCM 24kHz via `just_audio` with WAV header wrapping)
- **Camera service**: CameraFrameService captures JPEG at ≤1 FPS via `camera` package
- **Offline queue**: Hive-backed PendingMutation queue with auto-sync via connectivity_plus listener
- **Fonts bundled**: Plus Jakarta Sans + Hind Siliguri loaded from assets/fonts/ (removed google_fonts network dependency)
- **Shed picker**: Dynamic shed dropdown in egg/chicken record screens (fetches from API)

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
