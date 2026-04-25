# Active Context — Golden Chicken Frontend

## Current focus
This repository currently contains a **Flutter frontend implementation plan** (`GoldenChicken_Flutter_Implementation_Plan.md`) and a **Figma export** (`Figma.pdf`). The next step is to translate the plan and design into an actual Flutter codebase and incrementally implement features in sprints.

The **UI/UX source of truth is `Figma.pdf`**, with the implementation plan providing architecture, dependencies, and backend-contract details.

## Most important decisions already made
- **Feature-first Clean Architecture**
- **BLoC** for state management (plus global Auth/Locale/Theme)
- **GoRouter** with onboarding/auth guards and a 4-tab shell
- **Dio** networking with interceptors
- **SSE** for chat streaming and **WebSocket** for Live AI
- **Hive + secure storage** for caching and tokens
- **Bangla/English localization** via ARB + locale-aware typography
- **Design system tokens** (colors/typography/spacing/radius) centralized in `core/constants/` and wired into `ThemeData` (light + dark)
- **Figma-backed screen content**: splash/language selection, phone/password auth, Golden AI home/chat, Live AI states, Flock Overview, Health Center, Market Insights, Profile, and drawer navigation

## Immediate next steps (implementation order)
- Create Flutter project scaffold with planned folder structure (`lib/core`, `lib/features`, `assets`, `test`)
- Implement core foundations:
  - theme + design tokens
  - router + guards + shell/bottom nav
  - DI container
  - Dio client + interceptors + base failure types
  - localization (ARB, locale switching)
- Build Sprint 1 deliverable: app shell navigating between the 4 main tabs with placeholder screens and shared widgets.
- Ensure navigation matches Figma/plan: **4 bottom tabs** (Chat/Health/Market/Profile) plus a **left drawer** that links to Home, Flock Overview, Health Center, Market Insights, Profile, Settings, Help & Support, and Logout.
- Preserve Figma’s visible UX states during implementation: Golden AI online/processing, Live AI Assistant Live, AI Listening, AI Speaking, and Camera Off.

## Known open questions / risks to resolve early
- **Auth UI vs backend**: UI indicates phone-based auth, but plan notes backend is email+password; decide mapping or align API.
- **Live AI**: audio formats (PCM 16kHz record, PCM 24kHz playback), frame cadence (≤ ~1 FPS JPEG), and backend expectations must be verified; handle backend guardrail close code **4003** with user-friendly messages.
- **Offline queues**: define which mutations must be queued and conflict resolution strategy.

