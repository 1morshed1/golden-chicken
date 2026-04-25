# Progress — Golden Chicken Frontend

## What exists now (103 Dart source files)

### Core (from Sprint 1)
- Design system: AppColors, AppTypography (google_fonts), AppSpacing, AppRadius, AppTheme (light+dark)
- Networking: Dio ApiClient with Auth/Logging/Error interceptors, Failure hierarchy, NetworkInfo, ApiEndpoints
- DI: get_it with all externals, core services, auth, chat, health, and production features fully registered
- Routing: GoRouter with reactive auth-driven redirects, splash → language → auth → 4-tab shell + standalone routes for chat detail, flock overview, egg records, chicken records
- Localization: ARB EN/BN (45+ keys), LocaleCubit, ThemeCubit, `context.l10n` extension
- Shared widgets: AppButton, AppTextField, AppCard, AppLoading, AppErrorWidget, MainShell, AppDrawer

### Auth feature (Sprint 2)
- **Domain**: User entity, AuthRepository interface, LoginUseCase, RegisterUseCase, LogoutUseCase, RefreshTokenUseCase
- **Data**: UserModel (JSON), AuthResponseModel, AuthRemoteDatasource (Dio — login/register/refresh/logout/getUser), AuthLocalDatasource (SecureStorage — tokens + cached user), AuthRepositoryImpl (Either error handling, DioException mapping)
- **Presentation**: AuthBloc (CheckAuth/Login/Register/Logout/Refresh events → Initial/Loading/Authenticated/Unauthenticated/Error states), LoginScreen (form validation, phone→email mapping, BLoC-driven loading/error), SignupScreen (same), PasswordField widget (visibility toggle)

### Home/Chat tab (Sprint 2)
- Full home screen: orange AppBar with user name + loyalty badge + notifications, Golden AI status card (online indicator), tip banners (Water Check, Biosec), AI message bubble, quick action chips (Bangla prompts), LIVE AI gradient button, chat input bar (camera + text + send), left navigation drawer

### Chat feature (Sprint 3)
- **Domain**: ChatMessage entity (role, content, imageUrl, streaming flag), ChatSession entity, ChatRepository interface, CreateNewChat/GetChatHistory/SendMessage use cases
- **Data**: ChatMessageModel/ChatSessionModel (JSON), ChatRemoteDatasource (SSE streaming via Dio ResponseType.stream, chunked line parsing, event:done detection), ChatRepositoryImpl
- **Presentation**: ChatBloc (session creation, message history, SSE streaming with token accumulation, error recovery), ChatDetailScreen (message list, streaming bubble, input bar with send), MessageBubble widget (user/AI styling), StreamingBubble widget (animated dots + live text)
- Quick action chips and chat input bar on home screen navigate to ChatDetailScreen with prompt

### Health Center (Sprint 3)
- **Domain**: HealthTab entity (type enum: diseases/vaccines/emergency/diagnosis), HealthItem entity (severity enum: critical/high/medium/low, symptom count), HealthRepository interface, GetHealthTabs/AskHealthQuestion use cases
- **Data**: HealthTabModel/HealthItemModel (JSON with severity/type parsing), HealthRemoteDatasource (GET /health-tabs, POST /health-tabs/{id}/ask), HealthRepositoryImpl
- **Presentation**: HealthBloc (tab loading, tab selection, search filtering, ask AI → session creation), HealthTabScreen (search bar, horizontal tab filter, 2-column disease grid), DiseaseCard widget (severity color-coded left border, icon, name, severity badge, symptom count, Ask AI button), HealthTabFilter widget

### Production (Sprint 3)
- **Domain**: FlockSummary entity (totalBirds, alertCount, avgAgeDays, aiScore, alerts, feedPlan), FarmAlert entity, FeedPlanItem entity, EggRecord entity (totalEggs, brokenEggs, goodEggs computed), ChickenRecord entity (mortality, culled, sold), ProductionRepository interface, GetFlockOverview/AddEggRecord/AddChickenRecord use cases
- **Data**: FlockSummaryModel/FarmAlertModel/FeedPlanItemModel/EggRecordModel/ChickenRecordModel (JSON), ProductionRemoteDatasource, ProductionRepositoryImpl
- **Presentation**: ProductionBloc (flock overview, egg record add, chicken record add with auto-refresh), FlockOverviewScreen (stat cards row, AI score badge, alert cards, feed plan list, pull-to-refresh), EggRecordsScreen (date picker, total/broken eggs form, save with BLoC), ChickenRecordsScreen (date picker, mortality/culled/sold form, save with BLoC), ProductionStatCard widget

### Other tab placeholders
- MarketTabScreen, ProfileTabScreen (placeholder content)

### Onboarding
- SplashScreen (brand splash → auth check → redirect), LanguageSelectionScreen (EN/BN cards)

## Sprint completion status
- **Sprint 1**: ✅ COMPLETE
- **Sprint 2**: ✅ COMPLETE — Full onboarding → auth → home flow
- **Sprint 3**: ✅ COMPLETE — Chat (SSE streaming) + Health Center + Production
- **Sprint 4**: Not started (Trends/Charts + Tasks + Market)
- **Sprint 5**: Not started
- **Sprint 6–7**: Not started

## Known issues / watch-outs
- Phone→email mapping: UI collects phone, maps to `{phone}@goldenchicken.ai` for backend. Decide if backend should accept phone directly.
- Live AI protocol details need confirmation (audio/video formats, close codes)
- Cache TTLs and offline queues not yet implemented
- Fonts loaded via google_fonts (network) — bundle for production
- Tip banners and AI message bubble are static placeholder content
- Shed ID is hardcoded to 'default' in record screens — need shed picker
