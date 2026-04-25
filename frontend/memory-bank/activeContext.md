# Active Context — Golden Chicken Frontend

## Current focus
Sprint 1 is complete. The Flutter project has a working scaffold with 4-tab navigation shell, design system, networking layer, DI, routing with guards, localization (EN/BN), and shared widgets.

**Next up: Sprint 2** — Onboarding + Auth + Home (full implementation with BLoCs, actual API integration, token storage).

## Most important decisions already made
- **Feature-first Clean Architecture**
- **BLoC** for state management (plus global Auth/Locale/Theme)
- **GoRouter** with onboarding/auth guards and a 4-tab shell
- **Dio** networking with interceptors
- **SSE** for chat streaming and **WebSocket** for Live AI
- **google_fonts** package for locale-aware typography (PlusJakartaSans for EN, HindSiliguri for BN)
- **Hive + secure storage** for caching and tokens
- **Bangla/English localization** via ARB + locale-aware typography
- **Design system tokens** (colors/typography/spacing/radius) centralized in `core/constants/` and wired into `ThemeData` (light + dark)

## Immediate next steps (Sprint 2)
1. Implement AuthBloc with login/register use cases
2. Wire login/signup screens to actual API via repository pattern
3. Token storage (access + refresh) in FlutterSecureStorage
4. Route guard integration with real auth state
5. Splash screen with proper bootstrap logic (check token validity)
6. Home screen: AI chat card, quick action buttons, drawer navigation
7. HomeBloc with flock summary data

## Known open questions / risks to resolve early
- **Auth UI vs backend**: UI indicates phone-based auth, but plan notes backend is email+password; decide mapping or align API.
- **Live AI**: audio formats (PCM 16kHz record, PCM 24kHz playback), frame cadence (≤ ~1 FPS JPEG), and backend expectations must be verified; handle backend guardrail close code **4003** with user-friendly messages.
- **Offline queues**: define which mutations must be queued and conflict resolution strategy.
