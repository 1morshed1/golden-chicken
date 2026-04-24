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

## Networking & integration patterns
- HTTP via **Dio** with interceptors (auth, logging, error, retry)
- **Chat streaming** via **SSE** (`Accept: text/event-stream`)
- **Live AI** via **WebSocket** through backend (token as query param)

## Offline/caching
- Local cache with **Hive** (feature data with TTLs); secure tokens in **secure storage**
- Queue offline mutations (e.g., records) for later sync when online

## Design system patterns
- Centralized constants for **colors/typography/spacing/radius/assets/strings**
- Shared widgets: buttons, text fields, cards, loading/error widgets, nav bar, badges/indicators

