# Progress — Golden Chicken Frontend

## What exists now
- **Flutter project scaffold** fully set up with feature-first Clean Architecture folder structure
- **Design system**: AppColors (orange brand palette, semantic colors, dark mode), AppTypography (locale-aware via google_fonts — PlusJakartaSans for EN, HindSiliguri for BN), AppSpacing, AppRadius, AppTheme (light + dark ThemeData)
- **Networking**: Dio ApiClient with Auth/Logging/Error interceptors, Failure types hierarchy, NetworkInfo (connectivity_plus), ApiEndpoints
- **DI**: get_it service locator registering SharedPreferences, FlutterSecureStorage, Connectivity, NetworkInfo, ApiClient, Dio
- **Routing**: GoRouter with splash → language selection → auth → main shell flow, auth/onboarding guards, 4-tab ShellRoute (Chat/Health/Market/Profile), RouteNames constants
- **Localization**: ARB files for EN + BN (45+ keys), LocaleCubit with persistence, ThemeCubit with persistence, convenience `context.l10n` extension, l10n.yaml config
- **Shared widgets**: AppButton (primary/secondary/text + loading), AppTextField (label/hint/prefix/suffix/validation), AppCard, AppLoading, AppErrorWidget (with retry), MainShell (bottom nav bar)
- **Feature screens**: SplashScreen (orange brand, auto-redirect), LanguageSelectionScreen (EN/BN cards), LoginScreen (+880 phone auth), SignupScreen, and 4 placeholder tab screens (Chat, Health, Market, Profile)
- **Static analysis**: 0 issues with very_good_analysis
- **Tests**: smoke test passing

## Sprint completion status
- **Sprint 1**: ✅ COMPLETE — App shell with 4-tab navigation, design system, networking, DI, routing, localization, shared widgets
- **Sprint 2**: Not started (Onboarding + Auth + Home — full implementation with BLoCs, actual API integration)
- **Sprint 3**: Not started
- **Sprint 4**: Not started
- **Sprint 5**: Not started
- **Sprint 6–7**: Not started

## Design coverage captured from `Figma.pdf`
- Splash / brand: "Golden Chicken", "Poultry_AI Assistant"
- Language selection: English and Bangla choices
- Auth: Welcome Back, Sign In, Create Account, phone number (`+880`) and password fields
- Golden AI home/chat: online status, Water Check and Biosec tips, quick prompts, chat input, LIVE AI entry point
- Live AI states: AI Assistant Live, AI Listening, AI Speaking, Camera Off, processing state
- Flock Overview: total birds, alerts, average age, AI score, weather/temperature alerts, today's feed plan
- Health Center: disease/vaccine/emergency/diagnosis tabs, severity badges, symptom counts, Ask AI actions
- Market Insights: Dhaka live prices, egg/meat/feed costs, 7-day trend, AI confidence tip
- Profile: user identity, location, loyalty points, preferences, dark mode, notifications, data/history, account/help/about/logout

## Known issues / watch-outs
- Phone-login UI vs backend email/password alignment
- Live AI protocol details need confirmation (audio/video chunk formats, rate limits, close codes like **4003**)
- Cache TTLs and offline queue rules should be implemented consistently per feature (plan suggests: Health 24h, Market 30m, etc.)
- Fonts are loaded via google_fonts package (network download) — for production, bundle font files directly
