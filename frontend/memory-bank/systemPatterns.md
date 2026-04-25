# System Patterns — Golden Chicken Frontend

## Architecture
**Feature-first Clean Architecture** with four layers:
- **Presentation**: screens, widgets, BLoC/Cubit, view state
- **Domain**: entities, use cases, repository interfaces (pure Dart)
- **Data**: repository implementations, remote/local datasources, DTOs/models
- **Core/Shared**: theme, networking, DI, router, utilities, shared widgets

## Core data flow
User action → BLoC event → use case → repository → datasource (API/local) → BLoC state → UI rebuild

## State management
- **BLoC/Cubit** per feature; global blocs for **Auth**, **Locale**, **Theme**
- Prefer immutable state (plan calls out `freezed`) and value equality (`equatable`)
- Error handling via `Either<Failure, T>` style domain results

## Navigation
- Declarative routing with **GoRouter**
- Guards:
  - **Onboarding guard** (language selected)
  - **Auth guard** (token/session)
  - **Splash routing** (bootstrap then redirect)
- Main shell uses **bottom navigation (4 tabs)** aligned to designs: Chat, Health, Market, Profile
- Figma also shows a left drawer from the Golden AI home with Home, Flock Overview, Health Center, Market Insights, Profile, Settings, Help & Support, and Logout

## Networking & integration patterns
- HTTP via **Dio** with interceptors (auth, logging, error, retry)
- **Chat streaming** via **SSE** (`Accept: text/event-stream`)
- **Live AI** via **WebSocket** through backend (token as query param)
- **Live AI message protocol** (from plan):
  - Client → server frames: `audio` (base64 PCM), `video_frame` (base64 JPEG), `text`, `end_session`
  - Server → client frames: `session_started`, `audio` (AI speech chunks), `input_transcript`, `output_transcript`, `turn_complete`, `warning`, `error`
- **Guardrails**: handle WebSocket close code **4003** and map known error codes (daily limit, spend cap, concurrent session, timeout) to friendly UI states

## Offline/caching
- Local cache with **Hive** (feature data with TTLs); secure tokens in **secure storage**
- Queue offline mutations (e.g., records) for later sync when online
- Suggested TTLs (from plan): Health tabs (24h), Market prices (30m), chat sessions (recent history), profile (refresh on login), farm/shed data (refresh on app foreground)

## Design system patterns
- Centralized constants for **colors/typography/spacing/radius/assets/strings**
- Shared widgets: buttons, text fields, cards, loading/error widgets, nav bar, badges/indicators
- Figma surfaces to match first: splash, language selection, login, signup, Golden AI home/chat, Live AI states, Flock Overview, Health Center, Market Insights, Profile
- Use design-state widgets for AI/Live AI status rather than ad hoc text: online, processing, assistant live, listening, speaking, camera off

