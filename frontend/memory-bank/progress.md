# Progress — Golden Chicken Frontend

## What exists now (~145 Dart source files)

### Core (from Sprint 1)
- Design system: AppColors, AppTypography (bundled fonts), AppSpacing, AppRadius, AppTheme (light+dark)
- Networking: Dio ApiClient with Auth/Logging/Error interceptors, Failure hierarchy, NetworkInfo, ApiEndpoints
- DI: get_it with all externals, core services, and all features registered (auth, chat, health, production, market, tasks, profile, insights, live_ai)
- Routing: GoRouter with reactive auth-driven redirects, splash → language → auth → 4-tab shell + standalone routes for chat detail, flock overview, egg/chicken records, tasks, create task, edit profile, insights, live AI
- Localization: ARB EN/BN (45+ keys), LocaleCubit, ThemeCubit, `context.l10n` extension
- Shared widgets: AppButton, AppTextField, AppCard, AppLoading, AppErrorWidget, MainShell, AppDrawer

### Auth feature (Sprint 2)
- **Domain**: User entity, AuthRepository interface, 4 use cases
- **Data**: UserModel, AuthResponseModel, remote/local datasources, AuthRepositoryImpl
- **Presentation**: AuthBloc (5 events → 5 states), LoginScreen, SignupScreen, PasswordField widget

### Chat feature (Sprint 3)
- **Domain**: ChatMessage/ChatSession entities, ChatRepository, 3 use cases
- **Data**: Models, SSE-based remote datasource (chunked line parsing), ChatRepositoryImpl
- **Presentation**: ChatBloc (streaming lifecycle), ChatDetailScreen, MessageBubble, StreamingBubble

### Health Center (Sprint 3)
- **Domain**: HealthTab/HealthItem entities (severity/type enums), HealthRepository, 2 use cases
- **Data**: Models with JSON parsing, HealthRemoteDatasource, HealthRepositoryImpl
- **Presentation**: HealthBloc (tab selection, search, ask AI), HealthTabScreen (search, tab filter, 2-column grid), DiseaseCard, HealthTabFilter widgets

### Production (Sprint 3 + 6)
- **Domain**: FlockSummary/FarmAlert/FeedPlanItem/EggRecord/ChickenRecord/Shed entities, ProductionRepository, 4 use cases (incl. GetSheds)
- **Data**: Full models with JSON serialization, ShedModel, ProductionRemoteDatasource (incl. getSheds), ProductionRepositoryImpl
- **Presentation**: ProductionBloc (incl. ShedsRequested event), FlockOverviewScreen (stat cards, AI score, alerts, feed plan), EggRecordsScreen (shed picker, form), ChickenRecordsScreen (shed picker, form), ProductionStatCard, ShedPicker widgets

### Market Insights (Sprint 4)
- **Domain**: MarketPrice entity (product, price, unit, changePercent), MarketTip entity (message, confidence), PriceTrendPoint entity, MarketRepository interface, GetMarketPrices/GetPriceTrend use cases
- **Data**: MarketPriceModel/MarketTipModel/PriceTrendPointModel (JSON), MarketRemoteDatasource (prices, tip, trend with product/period params), MarketRepositoryImpl
- **Presentation**: MarketBloc (prices + parallel egg/meat trend loading, period toggle), MarketTabScreen (Dhaka region header, 3 price hero cards with ৳ currency and change %, period toggle Today/7d/30d, fl_chart trend chart, AI tip card with confidence), PriceHeroCard widget, PriceTrendChart widget (dual-line fl_chart with legend)

### Tasks (Sprint 4)
- **Domain**: FarmTask entity (type enum: feeding/cleaning/vaccination/inspection/other, status enum: pending/completed/overdue, recurrence enum: none/daily/weekly/custom), TaskRepository interface, GetTasks/CreateTask/CompleteTask use cases
- **Data**: FarmTaskModel (JSON with type/status/recurrence parsing, toJson for creation), TaskRemoteDatasource (GET/POST tasks, PATCH complete), TaskRepositoryImpl
- **Presentation**: TaskBloc (load tasks, complete task, create task with auto-refresh), TaskListScreen (overdue/today/upcoming/completed sections with counts, FAB to create, empty state "All caught up!"), CreateTaskScreen (title, type selector chips, date/time pickers, recurrence chips, notes, save), TaskCard widget (completion circle, type icon, due date, overdue badge, recurrence indicator), TaskTypeSelector widget

### Profile (Sprint 5)
- **Domain**: UserProfile entity (loyaltyPoints, loyaltyTier, pointsToNextTier), ProfileRepository, GetProfile/UpdateProfile use cases
- **Data**: UserProfileModel (JSON), ProfileRemoteDatasource (GET/PATCH /users/me), ProfileRepositoryImpl
- **Presentation**: ProfileBloc (load + update), ProfileTabScreen (avatar with edit icon, loyalty card with gradient/tier badge/points, preferences: language toggle via LocaleCubit, dark mode via ThemeCubit, notifications, data/history, logout), EditProfileScreen (name/phone/location form)

### Insights (Sprint 5)
- **Domain**: FarmInsight entity (severity enum: critical/warning/info, action, isAcknowledged), InsightsRepository, GetInsights/AcknowledgeInsight use cases
- **Data**: FarmInsightModel (JSON with severity parsing), InsightsRemoteDatasource (GET /insights, PATCH /insights/{id}/acknowledge), InsightsRepositoryImpl
- **Presentation**: InsightsBloc (load + acknowledge with auto-refresh), InsightsScreen (active/acknowledged sections, pull-to-refresh, empty state), InsightCard widget (severity-colored left border, severity icon, action badge, acknowledge button)

### Live AI (Sprint 5 + 6)
- **Domain**: LiveAiMessage entity (type enum: sessionStarted/audio/inputTranscript/outputTranscript/turnComplete/warning/error), LiveSessionStatus enum (idle/connecting/listening/aiSpeaking/error), LiveAiRepository interface (connect/sendAudio/sendVideoFrame/sendText/endSession/disconnect)
- **Data**: LiveAiWebSocketDatasource (WebSocket connect with token, JSON message parsing, send payloads), LiveAiRepositoryImpl (base64 audio encoding, delegates to WS datasource)
- **Presentation**: LiveAiBloc (session lifecycle state machine with AudioRecorderService/AudioPlayerService/CameraFrameService, token from FlutterSecureStorage, mic permission check, audio stream piping, camera toggle, audio playback queue), LiveAiScreen (dark theme, camera preview toggle, status icons/hints, BlocConsumer with error snackbar), LiveTranscriptOverlay widget (input/output transcript bubbles), LiveAiControls widget (mic/stop button with glow shadow, status label)

### Core Services (Sprint 6)
- **AudioRecorderService**: PCM 16kHz mono recording via `record` package, streams audio chunks
- **AudioPlayerService**: PCM 24kHz playback via `just_audio`, WAV header wrapping, queue-based chunk playback
- **CameraFrameService**: JPEG frame capture at ≤1 FPS via `camera` package, back camera preference, base64 encoding
- **OfflineMutationQueue**: Hive-backed queue for failed writes, auto-sync on connectivity change via connectivity_plus, supports POST/PATCH/PUT

### Onboarding
- SplashScreen (brand splash → auth check → redirect), LanguageSelectionScreen (EN/BN cards)

### Fonts (Sprint 6)
- Plus Jakarta Sans (Regular/Medium/SemiBold/Bold) bundled in assets/fonts/
- Hind Siliguri (Regular/Medium/SemiBold/Bold) bundled in assets/fonts/
- AppTypography uses local fontFamily references instead of google_fonts network calls

### Tests (Sprint 6)
- AuthBloc: 6 tests (login success/failure, logout, token check valid/invalid)
- ProductionBloc: 5 tests (initial state, sheds load, flock overview, egg record add)
- TaskBloc: 5 tests (load, error, complete+refresh, create+refresh)
- OfflineMutationQueue: 1 test (serialization roundtrip)
- **Total: 17 tests, all passing**

## Sprint completion status
- **Sprint 1**: ✅ COMPLETE
- **Sprint 2**: ✅ COMPLETE — Full onboarding → auth → home flow
- **Sprint 3**: ✅ COMPLETE — Chat (SSE streaming) + Health Center + Production
- **Sprint 4**: ✅ COMPLETE — Market Insights (fl_chart) + Tasks (CRUD + recurrence)
- **Sprint 5**: ✅ COMPLETE — Profile (loyalty card, preferences, edit) + Insights (severity cards, acknowledge) + Live AI (WebSocket state machine, transcript overlay)
- **Sprint 6**: ✅ COMPLETE — Live AI audio/camera services, offline mutation queue, bundled fonts, shed picker, unit tests (17 passing)
- **Sprint 7**: Not started

## Known issues / watch-outs
- Phone→email mapping: UI collects phone, maps to `{phone}@goldenchicken.ai` for backend
- Live AI protocol details need confirmation (audio/video formats, close codes)
- Live AI: handle close code 4003 (guardrail) with user-friendly message
- StreamAudioSource is experimental in just_audio
- Offline queue: non-network errors cause mutation discard (may need dead-letter handling)
- google_fonts package still in pubspec but no longer imported (can be removed)
- Tip banners and AI message bubble on home are static placeholder content
