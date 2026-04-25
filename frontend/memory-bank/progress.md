# Progress — Golden Chicken Frontend

## What exists now (130 Dart source files)

### Core (from Sprint 1)
- Design system: AppColors, AppTypography (google_fonts), AppSpacing, AppRadius, AppTheme (light+dark)
- Networking: Dio ApiClient with Auth/Logging/Error interceptors, Failure hierarchy, NetworkInfo, ApiEndpoints
- DI: get_it with all externals, core services, and all features registered (auth, chat, health, production, market, tasks)
- Routing: GoRouter with reactive auth-driven redirects, splash → language → auth → 4-tab shell + standalone routes for chat detail, flock overview, egg/chicken records, tasks, create task
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

### Production (Sprint 3)
- **Domain**: FlockSummary/FarmAlert/FeedPlanItem/EggRecord/ChickenRecord entities, ProductionRepository, 3 use cases
- **Data**: Full models with JSON serialization, ProductionRemoteDatasource, ProductionRepositoryImpl
- **Presentation**: ProductionBloc, FlockOverviewScreen (stat cards, AI score, alerts, feed plan), EggRecordsScreen, ChickenRecordsScreen, ProductionStatCard widget

### Market Insights (Sprint 4)
- **Domain**: MarketPrice entity (product, price, unit, changePercent), MarketTip entity (message, confidence), PriceTrendPoint entity, MarketRepository interface, GetMarketPrices/GetPriceTrend use cases
- **Data**: MarketPriceModel/MarketTipModel/PriceTrendPointModel (JSON), MarketRemoteDatasource (prices, tip, trend with product/period params), MarketRepositoryImpl
- **Presentation**: MarketBloc (prices + parallel egg/meat trend loading, period toggle), MarketTabScreen (Dhaka region header, 3 price hero cards with ৳ currency and change %, period toggle Today/7d/30d, fl_chart trend chart, AI tip card with confidence), PriceHeroCard widget, PriceTrendChart widget (dual-line fl_chart with legend)

### Tasks (Sprint 4)
- **Domain**: FarmTask entity (type enum: feeding/cleaning/vaccination/inspection/other, status enum: pending/completed/overdue, recurrence enum: none/daily/weekly/custom), TaskRepository interface, GetTasks/CreateTask/CompleteTask use cases
- **Data**: FarmTaskModel (JSON with type/status/recurrence parsing, toJson for creation), TaskRemoteDatasource (GET/POST tasks, PATCH complete), TaskRepositoryImpl
- **Presentation**: TaskBloc (load tasks, complete task, create task with auto-refresh), TaskListScreen (overdue/today/upcoming/completed sections with counts, FAB to create, empty state "All caught up!"), CreateTaskScreen (title, type selector chips, date/time pickers, recurrence chips, notes, save), TaskCard widget (completion circle, type icon, due date, overdue badge, recurrence indicator), TaskTypeSelector widget

### Other tab placeholders
- ProfileTabScreen (placeholder content)

### Onboarding
- SplashScreen (brand splash → auth check → redirect), LanguageSelectionScreen (EN/BN cards)

## Sprint completion status
- **Sprint 1**: ✅ COMPLETE
- **Sprint 2**: ✅ COMPLETE — Full onboarding → auth → home flow
- **Sprint 3**: ✅ COMPLETE — Chat (SSE streaming) + Health Center + Production
- **Sprint 4**: ✅ COMPLETE — Market Insights (fl_chart) + Tasks (CRUD + recurrence)
- **Sprint 5**: Not started (Profile + Insights + Live AI)
- **Sprint 6–7**: Not started

## Known issues / watch-outs
- Phone→email mapping: UI collects phone, maps to `{phone}@goldenchicken.ai` for backend
- Live AI protocol details need confirmation (audio/video formats, close codes)
- Cache TTLs and offline queues not yet implemented
- Fonts loaded via google_fonts (network) — bundle for production
- Shed ID is hardcoded to 'default' in record screens — need shed picker
- Tip banners and AI message bubble on home are static placeholder content
