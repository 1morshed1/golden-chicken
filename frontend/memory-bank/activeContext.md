# Active Context — Golden Chicken Frontend

## Current focus
This repository currently contains a **frontend implementation plan** document. The next step is to translate the plan into an actual Flutter codebase and incrementally implement features in sprints.

## Most important decisions already made
- **Feature-first Clean Architecture**
- **BLoC** for state management (plus global Auth/Locale/Theme)
- **GoRouter** with onboarding/auth guards and a 4-tab shell
- **Dio** networking with interceptors
- **SSE** for chat streaming and **WebSocket** for Live AI
- **Hive + secure storage** for caching and tokens
- **Bangla/English localization** via ARB + locale-aware typography

## Immediate next steps (implementation order)
- Create Flutter project scaffold with planned folder structure (`lib/core`, `lib/features`, `assets`, `test`)
- Implement core foundations:
  - theme + design tokens
  - router + guards + shell/bottom nav
  - DI container
  - Dio client + interceptors + base failure types
  - localization (ARB, locale switching)
- Build Sprint 1 deliverable: app shell navigating between the 4 main tabs with placeholder screens and shared widgets.

## Known open questions / risks to resolve early
- **Auth UI vs backend**: UI indicates phone-based auth, but plan notes backend is email+password; decide mapping or align API.
- **Live AI**: audio formats (PCM 16kHz record, PCM 24kHz playback) and backend expectations must be verified.
- **Offline queues**: define which mutations must be queued and conflict resolution strategy.

