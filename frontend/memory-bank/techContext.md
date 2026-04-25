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

## Backend contract notes (from plan)
- Auth register uses `full_name`
- Market prices: list under `data` (not paginated)
- Live AI WebSocket: token passed as query parameter
- SSE endpoint for streaming chat responses

