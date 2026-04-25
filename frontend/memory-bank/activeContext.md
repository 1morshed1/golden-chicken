# Active Context — Golden Chicken Frontend

## Current focus
Sprint 3 is complete. The app now has full Chat (SSE streaming), Health Center (disease grid with tab filters), and Production (Flock Overview, egg/chicken record entry) features.

**Next up: Sprint 4** — Trends/Charts (egg production, mortality, market price trends with fl_chart), Tasks (task list, create/edit, recurring tasks), and Market Insights (live prices, AI tips, trend charts).

## Most important decisions already made
- **Feature-first Clean Architecture** fully demonstrated across auth, chat, health, and production
- **AuthBloc** is global, drives router redirects via ValueNotifier
- **Phone→email mapping**: UI shows phone, maps to `{phone}@goldenchicken.ai` for backend email+password auth
- **Either<Failure, T>** for all repository returns, DioException mapped to typed Failures
- **Token rotation**: access+refresh stored in SecureStorage, refresh triggers token rotation
- **Drawer navigation** provides access to all screens beyond the 4 bottom tabs
- **SSE streaming** for chat via Dio ResponseType.stream with chunked line parsing
- **Health tabs** use `/health-tabs` API prefix; "Ask AI" creates a chat session from health context
- **Production** uses `default` shed ID placeholder until shed selection is implemented

## Immediate next steps (Sprint 4)
1. fl_chart trend graphs for egg production and mortality
2. Market Insights screen: price hero cards, period toggle, trend chart, AI tips
3. MarketBloc with live prices from API
4. Task list screen: today, overdue, upcoming sections
5. TaskBloc with CRUD operations
6. Create/edit task form with recurring task support
7. Wire trend graphs into Flock Overview and Market screens

## Known open questions / risks
- Shed selection: currently hardcoded to 'default' — need shed picker for multi-shed farms
- Market prices API: confirm response shape matches `data` list format
- Task recurrence: define recurrence patterns (daily, weekly, custom)
- Offline queues: egg/chicken records should queue mutations when offline
- fl_chart: confirm version compatibility with current Flutter SDK
