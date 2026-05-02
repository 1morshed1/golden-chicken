# Tech Context — Golden Chicken Frontend

## Platform
- **Flutter** (3.24+) / **Dart** (3.5+)
- Targets: **Android & iOS**

## Key dependencies (planned)
### Architecture & state
- `flutter_bloc`, `equatable`
- DI: `get_it`, `injectable`, `injectable_generator`
- FP/error modeling: `dartz`
- Immutables/codegen: `freezed`, `freezed_annotation`, `build_runner`
- Linting: `very_good_analysis`

### Routing
- `go_router`

### Networking
- `dio`
- `retrofit`, `retrofit_generator`
- `json_annotation`, `json_serializable`
- `connectivity_plus`

### Storage
- `shared_preferences` (prefs like locale)
- `hive`, `hive_flutter` (cache, offline queue)
- `flutter_secure_storage` (tokens)

### UI
- `flutter_svg`, `cached_network_image`
- `shimmer`, `lottie`, `flutter_animate`
- Charts: `fl_chart`

### Camera/audio (Live AI)
- `camera`
- `image_picker`, `image_cropper`
- WebSocket: `web_socket_channel`
- Recording: `record` (or `flutter_sound`)
- Playback: `just_audio`
- Permissions: `permission_handler`

### Localization
- `flutter_localizations` (SDK)
- `intl` (dates/numbers/currency)

### Firebase (optional / planned)
- `firebase_core`, `firebase_auth`, `firebase_analytics`, `firebase_crashlytics`

## Testing (planned)
- Unit/widget/integration: `flutter_test`, `bloc_test`, `mocktail` (or `mockito` + codegen)
- Golden/screenshot regression: `golden_toolkit`

## Agent/tooling support
- **Context7 MCP** is available for fetching current docs for libraries, frameworks, SDKs, APIs, CLIs, and cloud services.
- **Playwright** may be used for browser/UI automation, visual checks, and end-to-end verification when a runnable app target exists.

## Environments / flavors (planned)
- `dev`, `staging`, `production` with different base URLs and logging levels

## Backend contract notes (from plan + testing)
- Auth register uses `full_name`
- Market prices: list under `data` (not paginated)
- Live AI WebSocket: token passed as query parameter
- SSE endpoint for streaming chat responses (`POST /chat/sessions/{id}/messages/stream`)
- GET messages endpoint: `GET /chat/sessions/{id}/messages` (added during device testing)
- Health Ask AI: `POST /health-tabs/{id}/ask` creates a chat session + sends AI response, returns session_id
- Gemini models: `gemini-2.5-flash` (text), `gemini-2.5-flash-lite` (intent/titles), `gemini-2.5-flash-live-001` (Live AI)
- Chat history role mapping: Gemini requires `"model"` not `"assistant"` for AI messages
- ChatSession.messages relationship uses `lazy="dynamic"` — cannot use `selectinload`; query messages via `ChatMessageRepository.get_session_messages` instead
- Backend RAG uses BAAI/bge-m3 embedding model — first request cold starts (~165s), subsequent ~15s

## Physical device testing setup
- Device: Samsung SM-M405F (device ID: R58M67M7FWD)
- Backend: Dockerized (`docker compose up`), accessed via devtunnel
- Devtunnel URL: `https://dplss5n1-8000.inc1.devtunnels.ms/`
- Frontend base URL: `https://dplss5n1-8000.inc1.devtunnels.ms/api/v1`
- WS base URL: `wss://dplss5n1-8000.inc1.devtunnels.ms`
- Known issue: devtunnel intermittently drops connections; mitigated with retry + short idle timeout

