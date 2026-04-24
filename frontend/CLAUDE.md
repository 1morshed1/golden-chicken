# Claude Code Instructions — Golden Chicken (Frontend)

This repo is intended to become the **Flutter (Dart) mobile frontend** for *Golden Chicken* (Android & iOS). Right now the codebase may be mostly documentation; follow the Memory Bank as the source of truth for scope and decisions.

## Non-negotiable: Read Memory Bank first
Before planning or coding, read these files in order:
- `memory-bank/projectbrief.md`
- `memory-bank/productContext.md`
- `memory-bank/systemPatterns.md`
- `memory-bank/techContext.md`
- `memory-bank/activeContext.md`
- `memory-bank/progress.md`

If you discover new patterns/constraints while working, **update the Memory Bank** (especially `activeContext.md` + `progress.md`) as part of the same change set.

## Product summary (what we’re building)
- AI-first farm assistant for poultry farmers (Bangladesh-first)
- Core features: AI chat (streaming) + image diagnosis, Health Center, production tracking + trends, tasks, market insights, profile/preferences, and **Live AI** (voice + camera streaming via backend).
- UX priorities: **Bangla-first**, resilient under poor connectivity, explicit loading/error/streaming states.

## Architecture & conventions
### High-level pattern
- **Feature-first Clean Architecture**:
  - Presentation: screens/widgets + BLoC/Cubit
  - Domain: entities + use cases + repository interfaces (pure Dart)
  - Data: repository impls + remote/local datasources + models/DTOs
  - Core: theme/design tokens, router, DI, network client, utilities, shared widgets

### State management
- Use `flutter_bloc` across features.
- Prefer immutable states (planned: `freezed`) and explicit error modeling (planned: `Either<Failure, T>`).

### Routing
- Use `go_router` with guards:
  - onboarding/language selection
  - authentication
  - splash/bootstrap redirect
- Main shell uses **4 bottom tabs** (Chat, Health, Market, Profile).

### Networking
- HTTP: `dio` with interceptors (auth/logging/error/retry).
- Chat streaming: **SSE** (`Accept: text/event-stream`).
- Live AI: **WebSocket** (token passed as query parameter).

### Offline/caching
- Cache with `hive`; secure tokens with `flutter_secure_storage`.
- When implementing offline writes, queue mutations and sync on reconnect.

## Localization
- Must support **Bangla (`bn`) and English (`en`)**.
- ARB-based localization; typography differs by locale (BN: Hind Siliguri, EN: Plus Jakarta Sans).
- Currency formatting uses **৳ BDT**; some screens may need Bangla digits.

## Implementation workflow expectations
- Keep changes small and shippable. Prefer working in sprint-sized slices described in the plan and Memory Bank.
- For any feature work:
  - Add/update tests where practical (unit/widget/integration).
  - Provide loading/empty/error states.
  - Avoid directly calling APIs from UI; route through use cases/repositories.

## Commands (once Flutter scaffold exists)
If `pubspec.yaml` is present, these are the standard commands:
- Install deps: `flutter pub get`
- Generate code: `dart run build_runner build --delete-conflicting-outputs`
- Static analysis: `flutter analyze`
- Tests: `flutter test`

If the scaffold is not present yet, create it first (and align folder structure with `memory-bank/systemPatterns.md` / the implementation plan).

## Guardrails / known risks to resolve early
- **Auth mismatch**: UI shows phone-based login but backend may be email+password. Decide and document the mapping or update API expectations.
- **Live AI protocol**: confirm backend expectations for audio (PCM rate/format) and frame cadence; handle close code `4003` guardrail errors with user-friendly messaging.

