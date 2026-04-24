# Golden Chicken — Flutter Frontend Implementation Plan

**Version:** 1.0
**Platform:** Flutter (Dart)
**Target:** Android & iOS
**Date:** April 2026
**AI Model (Live AI):** Gemini 3.1 Flash Live Preview

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Project Structure & Folder Organization](#2-project-structure--folder-organization)
3. [Tech Stack & Dependencies](#3-tech-stack--dependencies)
4. [Design System & Theming](#4-design-system--theming)
5. [Navigation & Routing](#5-navigation--routing)
6. [State Management Strategy](#6-state-management-strategy)
7. [Localization (Bangla & English)](#7-localization-bangla--english)
8. [Screen-by-Screen Implementation Guide](#8-screen-by-screen-implementation-guide)
9. [Shared Components & Widgets](#9-shared-components--widgets)
10. [API Integration Layer](#10-api-integration-layer)
11. [Image Upload & Camera Integration](#11-image-upload--camera-integration)
12. [Voice Input Integration](#12-voice-input-integration)
13. [Real-time & Live AI Feature](#13-real-time--live-ai-feature)
14. [Offline & Caching Strategy](#14-offline--caching-strategy)
15. [Error Handling & Loading States](#15-error-handling--loading-states)
16. [Testing Strategy](#16-testing-strategy)
17. [Performance Optimization](#17-performance-optimization)
18. [Accessibility](#18-accessibility)
19. [Build, CI/CD & Deployment](#19-build-cicd--deployment)
20. [Sprint Breakdown & Milestones](#20-sprint-breakdown--milestones)

---

## 1. Architecture Overview

### 1.1 Pattern: Feature-First Clean Architecture

```
┌─────────────────────────────────────────────────┐
│                  Presentation                    │
│   Screens • Widgets • BLoC/Cubit • ViewModels   │
├─────────────────────────────────────────────────┤
│                    Domain                        │
│   Entities • Use Cases • Repository Interfaces   │
├─────────────────────────────────────────────────┤
│                     Data                         │
│   Repositories Impl • Data Sources • DTOs/Models │
├─────────────────────────────────────────────────┤
│                   Core / Shared                  │
│   Theme • Networking • DI • Utils • Widgets      │
└─────────────────────────────────────────────────┘
```

### 1.2 Data Flow

```
User Action → BLoC Event → Use Case → Repository → Data Source (API/Local)
                                         ↓
                              BLoC State → UI Rebuild
```

### 1.3 Rationale

- **Separation of Concerns:** UI never talks to APIs directly.
- **Testability:** Domain layer has zero Flutter dependencies — pure Dart.
- **Scalability:** New features drop in as new feature modules.
- **Team Parallelism:** Developers work on features simultaneously.

---

## 2. Project Structure & Folder Organization

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   ├── app_assets.dart
│   │   ├── app_strings.dart
│   │   └── api_endpoints.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData (light + dark)
│   │   ├── color_scheme.dart
│   │   └── text_theme.dart
│   │
│   ├── network/
│   │   ├── api_client.dart            # Dio instance, interceptors
│   │   ├── api_interceptors.dart      # Auth, logging, error interceptors
│   │   ├── api_exceptions.dart
│   │   └── network_info.dart
│   │
│   ├── di/
│   │   └── injection_container.dart   # get_it service locator
│   │
│   ├── router/
│   │   ├── app_router.dart            # GoRouter configuration
│   │   ├── route_names.dart
│   │   └── route_guards.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   ├── currency_formatter.dart    # ৳ BDT formatting
│   │   ├── extensions.dart
│   │   └── logger.dart
│   │
│   ├── l10n/
│   │   ├── app_en.arb
│   │   ├── app_bn.arb
│   │   └── l10n.dart
│   │
│   └── widgets/                       # Shared widgets
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_card.dart
│       ├── app_loading.dart           # Shimmer + spinner
│       ├── app_error_widget.dart
│       ├── bottom_nav_bar.dart        # 5-tab navigation
│       ├── app_drawer.dart            # Sidebar drawer
│       ├── status_badge.dart          # "High", "Critical", etc.
│       ├── price_change_indicator.dart # ↑4.2% / ↓2.6%
│       ├── trend_chart.dart           # Simple line chart widget
│       └── severity_indicator.dart    # Disease severity badges
│
├── features/
│   │
│   ├── splash/
│   │   └── presentation/
│   │       └── splash_screen.dart
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── language_selection_screen.dart
│   │       └── widgets/
│   │           └── language_option_card.dart
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── auth_response_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── social_login_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       └── widgets/
│   │           ├── social_login_buttons.dart
│   │           └── password_field.dart
│   │
│   ├── home/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── flock_summary_model.dart
│   │   │   │   └── alert_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── home_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── home_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── flock_summary.dart
│   │   │   │   └── farm_alert.dart
│   │   │   ├── repositories/
│   │   │   │   └── home_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_home_data.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── home_bloc.dart
│   │       │   ├── home_event.dart
│   │       │   └── home_state.dart
│   │       ├── home_screen.dart
│   │       └── widgets/
│   │           ├── ai_chat_card.dart
│   │           ├── flock_overview_card.dart
│   │           ├── alert_banner.dart
│   │           ├── quick_action_grid.dart
│   │           └── today_feed_plan_card.dart
│   │
│   ├── chat/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── chat_message_model.dart
│   │   │   │   └── chat_session_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── chat_remote_datasource.dart
│   │   │   │   └── chat_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── chat_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── chat_message.dart
│   │   │   │   └── chat_session.dart
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_message.dart
│   │   │       ├── get_chat_history.dart
│   │   │       ├── create_new_chat.dart
│   │   │       └── upload_image_for_diagnosis.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── chat_bloc.dart
│   │       │   ├── chat_event.dart
│   │       │   └── chat_state.dart
│   │       ├── chat_screen.dart
│   │       └── widgets/
│   │           ├── ai_message_bubble.dart
│   │           ├── user_message_bubble.dart
│   │           ├── chat_input_bar.dart
│   │           ├── quick_action_chips.dart
│   │           ├── typing_indicator.dart
│   │           └── image_preview_bubble.dart
│   │
│   ├── health_center/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── health_tab_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── health_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── health_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── health_tab.dart
│   │   │   ├── repositories/
│   │   │   │   └── health_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_health_tabs.dart
│   │   │       └── ask_health_question.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── health_bloc.dart
│   │       │   ├── health_event.dart
│   │       │   └── health_state.dart
│   │       ├── health_center_screen.dart
│   │       └── widgets/
│   │           ├── disease_card.dart
│   │           ├── severity_badge.dart
│   │           └── tab_filter_row.dart
│   │
│   ├── production/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── egg_record_model.dart
│   │   │   │   ├── chicken_record_model.dart
│   │   │   │   └── trend_data_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── production_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── production_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── egg_record.dart
│   │   │   │   ├── chicken_record.dart
│   │   │   │   └── trend_data.dart
│   │   │   ├── repositories/
│   │   │   │   └── production_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_egg_record.dart
│   │   │       ├── add_chicken_record.dart
│   │   │       ├── get_egg_trends.dart
│   │   │       └── get_flock_overview.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── production_bloc.dart
│   │       │   ├── production_event.dart
│   │       │   └── production_state.dart
│   │       ├── flock_overview_screen.dart
│   │       ├── egg_records_screen.dart
│   │       ├── chicken_records_screen.dart
│   │       ├── trend_graph_screen.dart
│   │       └── widgets/
│   │           ├── egg_entry_form.dart
│   │           ├── chicken_entry_form.dart
│   │           ├── production_stat_card.dart
│   │           ├── trend_line_chart.dart
│   │           └── record_list_tile.dart
│   │
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── farm_task_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── task_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── task_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── farm_task.dart
│   │   │   ├── repositories/
│   │   │   │   └── task_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_today_tasks.dart
│   │   │       ├── create_task.dart
│   │   │       ├── complete_task.dart
│   │   │       └── get_overdue_tasks.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── task_bloc.dart
│   │       │   ├── task_event.dart
│   │       │   └── task_state.dart
│   │       ├── task_list_screen.dart
│   │       ├── create_task_screen.dart
│   │       └── widgets/
│   │           ├── task_card.dart
│   │           ├── task_type_selector.dart
│   │           ├── recurrence_picker.dart
│   │           └── overdue_badge.dart
│   │
│   ├── market/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── market_price_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── market_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── market_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── market_price.dart
│   │   │   ├── repositories/
│   │   │   │   └── market_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_market_prices.dart
│   │   │       └── get_price_history.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── market_bloc.dart
│   │       │   ├── market_event.dart
│   │       │   └── market_state.dart
│   │       ├── market_insights_screen.dart
│   │       └── widgets/
│   │           ├── price_hero_card.dart
│   │           ├── price_trend_chart.dart
│   │           ├── ai_market_tip_card.dart
│   │           └── price_period_toggle.dart
│   │
│   ├── insights/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── farm_insight_model.dart
│   │   │   │   └── proposed_action_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── insights_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── insights_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── farm_insight.dart
│   │   │   │   └── proposed_action.dart
│   │   │   ├── repositories/
│   │   │   │   └── insights_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_insights.dart
│   │   │       └── acknowledge_insight.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── insights_bloc.dart
│   │       │   ├── insights_event.dart
│   │       │   └── insights_state.dart
│   │       ├── insights_screen.dart
│   │       └── widgets/
│   │           ├── insight_card.dart
│   │           └── action_checklist.dart
│   │
│   ├── profile/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── profile_bloc.dart
│   │       │   ├── profile_event.dart
│   │       │   └── profile_state.dart
│   │       ├── profile_screen.dart
│   │       ├── edit_profile_screen.dart
│   │       └── widgets/
│   │           ├── loyalty_points_card.dart
│   │           ├── preferences_section.dart
│   │           └── language_toggle.dart
│   │
│   └── live_ai/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── live_ai_websocket_datasource.dart
│       │   └── repositories/
│       │       └── live_ai_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── live_message.dart
│       │   ├── repositories/
│       │   │   └── live_ai_repository.dart
│       │   └── usecases/
│       │       ├── start_live_session.dart
│       │       ├── send_audio_chunk.dart
│       │       ├── send_video_frame.dart
│       │       └── end_live_session.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── live_ai_bloc.dart
│           │   ├── live_ai_event.dart
│           │   └── live_ai_state.dart
│           ├── live_ai_screen.dart
│           ├── services/
│           │   ├── audio_recorder_service.dart
│           │   ├── audio_player_service.dart
│           │   └── camera_frame_service.dart
│           └── widgets/
│               ├── camera_preview_overlay.dart
│               ├── voice_waveform.dart
│               ├── live_transcript_overlay.dart
│               └── live_ai_controls.dart
│
├── assets/
│   ├── images/
│   │   ├── splash_chicken.png
│   │   ├── golden_chicken_logo.png
│   │   └── onboarding/
│   ├── icons/
│   │   ├── nav_chat.svg
│   │   ├── nav_health.svg
│   │   ├── nav_market.svg
│   │   ├── nav_profile.svg
│   │   ├── ic_egg.svg
│   │   ├── ic_chicken.svg
│   │   ├── ic_feed.svg
│   │   ├── ic_vaccine.svg
│   │   ├── ic_camera.svg
│   │   ├── ic_mic.svg
│   │   ├── ic_send.svg
│   │   └── ...
│   ├── lottie/
│   │   ├── splash_animation.json
│   │   ├── typing_indicator.json
│   │   └── voice_waveform.json
│   └── fonts/
│       ├── HindSiliguri-Regular.ttf
│       ├── HindSiliguri-Medium.ttf
│       ├── HindSiliguri-Bold.ttf
│       ├── PlusJakartaSans-Regular.ttf
│       ├── PlusJakartaSans-Medium.ttf
│       ├── PlusJakartaSans-SemiBold.ttf
│       └── PlusJakartaSans-Bold.ttf
│
└── test/
    ├── unit/
    ├── widget/
    └── integration/
```

---

## 3. Tech Stack & Dependencies

### 3.1 Core

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.24+ | Cross-platform UI |
| Dart | 3.5+ | Language |

### 3.2 Dependencies (pubspec.yaml)

**State Management & Architecture**

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | BLoC/Cubit state management |
| `equatable` | Value equality for states & events |
| `get_it` | Service locator DI |
| `injectable` + `injectable_generator` | Code-gen DI registration |
| `dartz` | Functional programming (Either) |

**Navigation**

| Package | Purpose |
|---------|---------|
| `go_router` | Declarative routing, deep links, guards |

**Networking**

| Package | Purpose |
|---------|---------|
| `dio` | HTTP client with interceptors |
| `retrofit` + `retrofit_generator` | Type-safe API generation |
| `json_annotation` + `json_serializable` | JSON serialization |
| `connectivity_plus` | Network detection |

**Local Storage**

| Package | Purpose |
|---------|---------|
| `shared_preferences` | Key-value (language pref, tokens) |
| `hive` + `hive_flutter` | Structured local DB (cache) |
| `flutter_secure_storage` | Encrypted token storage |

**UI & Design**

| Package | Purpose |
|---------|---------|
| `flutter_svg` | SVG icons |
| `cached_network_image` | Image caching |
| `shimmer` | Loading skeleton animations |
| `lottie` | Lottie animations |
| `flutter_animate` | Widget animations |
| `fl_chart` | Trend graphs and charts |

**Camera & Media**

| Package | Purpose |
|---------|---------|
| `camera` | Live camera preview for Live AI |
| `image_picker` | Gallery/camera selection |
| `image_cropper` | Crop before upload |

**Voice & Audio (Gemini 3.1 Flash Live)**

| Package | Purpose |
|---------|---------|
| `web_socket_channel` | WebSocket for Live AI |
| `record` (or `flutter_sound`) | Raw PCM 16kHz recording |
| `just_audio` | PCM 24kHz playback |
| `permission_handler` | Runtime permissions |

**Localization**

| Package | Purpose |
|---------|---------|
| `flutter_localizations` (SDK) | Material l10n |
| `intl` | Date, number, currency formatting |

**Firebase**

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase init |
| `firebase_auth` | Social login |
| `firebase_analytics` | Usage tracking |
| `firebase_crashlytics` | Crash reporting |

**Utilities**

| Package | Purpose |
|---------|---------|
| `url_launcher` | External links |
| `package_info_plus` | App version display |
| `logger` | Debug logging |
| `freezed` + `freezed_annotation` | Immutable data classes |
| `build_runner` | Code generation |

### 3.3 Dev Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_test` | Widget testing |
| `bloc_test` | BLoC testing |
| `mockito` + `build_runner` | Mock generation |
| `mocktail` | Lightweight mocking |
| `very_good_analysis` | Lint rules |
| `golden_toolkit` | Screenshot testing |

---

## 4. Design System & Theming

### 4.1 Color Palette (from Figma)

```dart
// core/constants/app_colors.dart

class AppColors {
  // Primary Orange (brand color — buttons, headers, active states)
  static const Color primary = Color(0xFFFF6B00);         // Golden Chicken orange
  static const Color primaryLight = Color(0xFFFF8C33);
  static const Color primaryDark = Color(0xFFE55D00);

  // Secondary / Dark (nav bar, headers)
  static const Color secondary = Color(0xFF1A1A2E);       // Dark navy
  static const Color secondaryLight = Color(0xFF2D2D44);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);          // Optimal / Up
  static const Color warning = Color(0xFFF59E0B);          // Medium severity
  static const Color error = Color(0xFFEF4444);            // Critical / Down
  static const Color info = Color(0xFF3B82F6);

  // Severity-specific
  static const Color severityCritical = Color(0xFFEF4444);
  static const Color severityHigh = Color(0xFFEF4444);
  static const Color severityMedium = Color(0xFFF59E0B);
  static const Color severityLow = Color(0xFF10B981);

  // Neutrals
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Chat Bubbles
  static const Color userBubble = Color(0xFFFF6B00);       // Orange (user)
  static const Color aiBubble = Color(0xFFF1F5F9);         // Light gray (AI)

  // Bottom Nav
  static const Color navBg = Color(0xFF1A1A2E);            // Dark navy
  static const Color navActive = Color(0xFFFF6B00);         // Orange active
  static const Color navInactive = Color(0xFF94A3B8);

  // Loyalty Points
  static const Color loyaltyGradientStart = Color(0xFFFF6B00);
  static const Color loyaltyGradientEnd = Color(0xFFE55D00);
  static const Color loyaltySilver = Color(0xFFB0B0B0);
  static const Color loyaltyGold = Color(0xFFFFD700);

  // Splash
  static const Color splashBg = Color(0xFFFF6B00);

  // Dark mode
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF2D2D44);
}
```

### 4.2 Typography

```dart
// core/constants/app_typography.dart

class AppTypography {
  static const String fontFamilyEn = 'PlusJakartaSans';
  static const String fontFamilyBn = 'HindSiliguri';

  static TextStyle h1(BuildContext context) => TextStyle(
    fontFamily: _fontFamily(context), fontSize: 28,
    fontWeight: FontWeight.w700, height: 1.2, color: AppColors.textPrimary,
  );

  static TextStyle h2(BuildContext context) => TextStyle(
    fontFamily: _fontFamily(context), fontSize: 22,
    fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textPrimary,
  );

  static TextStyle h3(BuildContext context) => TextStyle(
    fontFamily: _fontFamily(context), fontSize: 18,
    fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontFamily: _fontFamily(context), fontSize: 16,
    fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontFamily: _fontFamily(context), fontSize: 14,
    fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontFamily: _fontFamily(context), fontSize: 12,
    fontWeight: FontWeight.w400, height: 1.4, color: AppColors.textTertiary,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontFamily: _fontFamily(context), fontSize: 16,
    fontWeight: FontWeight.w600, height: 1.0, color: Colors.white,
  );

  static String _fontFamily(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'bn' ? fontFamilyBn : fontFamilyEn;
  }
}
```

### 4.3 Spacing & Radius

```dart
class AppSpacing {
  static const double xs = 4, sm = 8, md = 12, lg = 16;
  static const double xl = 20, xxl = 24, xxxl = 32, section = 40;
}

class AppRadius {
  static const double sm = 8, md = 12, lg = 16, xl = 20;
  static const double pill = 100, card = 16, input = 12, chip = 20;
}
```

### 4.4 ThemeData

```dart
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkSurface,
    // ... mirror structure for dark mode
  );
}
```

---

## 5. Navigation & Routing

### 5.1 Route Structure

```dart
class RouteNames {
  static const splash = 'splash';
  static const languageSelection = 'language-selection';
  static const login = 'login';
  static const signup = 'signup';
  static const home = 'home';
  static const chat = 'chat';
  static const chatDetail = 'chat-detail';
  static const healthCenter = 'health-center';
  static const flockOverview = 'flock-overview';
  static const eggRecords = 'egg-records';
  static const chickenRecords = 'chicken-records';
  static const trendGraph = 'trend-graph';
  static const taskList = 'task-list';
  static const createTask = 'create-task';
  static const marketInsights = 'market-insights';
  static const insights = 'insights';
  static const profile = 'profile';
  static const editProfile = 'edit-profile';
  static const liveAi = 'live-ai';
}
```

### 5.2 GoRouter Configuration

```
/                            → SplashScreen (auto-redirect)
/language                    → LanguageSelectionScreen
/auth/login                  → LoginScreen
/auth/signup                 → SignUpScreen
/main                        → MainShell (with BottomNavBar)
  ├── /main/chat             → HomeScreen / AI Chat (tab 0)
  ├── /main/health           → HealthCenterScreen (tab 1)
  ├── /main/market           → MarketInsightsScreen (tab 2)
  └── /main/profile          → ProfileScreen (tab 3)
/flock-overview              → FlockOverviewScreen
/flock-overview/eggs/:shedId → EggRecordsScreen
/flock-overview/chickens/:id → ChickenRecordsScreen
/flock-overview/trends/:id   → TrendGraphScreen
/tasks                       → TaskListScreen
/tasks/create                → CreateTaskScreen
/chat/:sessionId             → ChatScreen
/insights                    → InsightsScreen
/live-ai                     → LiveAIScreen
/main/profile/edit           → EditProfileScreen
```

### 5.3 Bottom Navigation (4 tabs from Figma)

Based on the Figma designs, the bottom nav has 4 main tabs:

1. **চাট (Chat)** — AI Chat home with quick actions
2. **স্বাস্থ্য (Health)** — Health Center with disease tabs
3. **বাজার (Market)** — Market insights with prices
4. **প্রোফাইল (Profile)** — User profile and settings

Additional screens (Flock Overview, Tasks, Insights, Trend Graphs) are accessible from the home/chat screen and sidebar navigation.

### 5.4 Route Guards

- **AuthGuard:** Unauthenticated users redirect to `/auth/login`
- **OnboardingGuard:** No language selected → redirect to `/language`
- **SplashGuard:** Check token validity, then redirect accordingly

---

## 6. State Management Strategy

### 6.1 BLoC Pattern

Every feature uses `flutter_bloc`. Events → States, calling domain use cases.

### 6.2 BLoC Registry

| BLoC | Scope | Purpose |
|------|-------|---------|
| `AuthBloc` | Global | Auth state across app |
| `LocaleBloc` | Global | Language switching (EN ↔ BN) |
| `ThemeBloc` | Global | Light/dark mode |
| `HomeBloc` | Feature | Flock summary, alerts, feed plan |
| `ChatBloc` | Feature (per session) | Messages, sending, streaming |
| `HealthBloc` | Feature | Disease tabs, filtering |
| `ProductionBloc` | Feature | Egg/chicken records, trends |
| `TaskBloc` | Feature | Task list, completion |
| `MarketBloc` | Feature | Price data, trends |
| `InsightsBloc` | Feature | Farm insights, actions |
| `ProfileBloc` | Feature | User profile |
| `LiveAIBloc` | Feature | Voice/camera stream state |

### 6.3 State Shape (freezed)

```dart
@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.loaded({
    required List<ChatMessage> messages,
    required bool isSending,
    required bool isStreaming,
  }) = _Loaded;
  const factory ChatState.error({required String message}) = _Error;
}
```

### 6.4 Error Handling with Either

```dart
class SendMessage {
  final ChatRepository repository;
  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) {
    return repository.sendMessage(params.sessionId, params.text, params.image);
  }
}
```

---

## 7. Localization (Bangla & English)

### 7.1 ARB Samples

```json
// app_en.arb
{
  "appName": "Golden Chicken",
  "selectLanguage": "Choose Language",
  "english": "English",
  "bangla": "বাংলা",
  "login": "Sign In",
  "signUp": "Create Account",
  "chat": "Chat",
  "healthCenter": "Health Center",
  "marketInsights": "Market Insights",
  "profile": "Profile",
  "flockOverview": "Flock Overview",
  "eggRecords": "Egg Records",
  "chickenRecords": "Chicken Records",
  "taskList": "Task List",
  "todaysFeedPlan": "Today's Feed Plan",
  "askGoldenAi": "Ask Golden AI",
  "liveAi": "LIVE AI",
  "aiIsListening": "AI IS LISTENING...",
  "totalBirds": "Total Birds",
  "avgAge": "Avg Age",
  "alerts": "Alerts",
  "diseases": "Diseases",
  "vaccines": "Vaccines",
  "emergency": "Emergency",
  "diagnosis": "Diagnosis",
  "askAi": "Ask AI",
  "symptoms": "symptoms",
  "eggPrice": "Egg Price",
  "meatPrice": "Meat Price",
  "feedCost": "Feed Cost",
  "loyaltyPoints": "Loyalty Points",
  "settings": "Settings",
  "helpSupport": "Help & Support",
  "logout": "Logout",
  "darkMode": "Dark Mode",
  "notifications": "Notifications",
  "chatHistory": "Chat History",
  "exportFarmData": "Export Farm Data"
}
```

```json
// app_bn.arb
{
  "appName": "গোল্ডেন চিকেন",
  "selectLanguage": "ভাষা নির্বাচন করুন",
  "chat": "চাট",
  "healthCenter": "স্বাস্থ্য কেন্দ্র",
  "marketInsights": "বাজার তথ্য",
  "profile": "প্রোফাইল",
  "flockOverview": "পাল পরিদর্শন",
  "eggRecords": "ডিমের রেকর্ড",
  "todaysFeedPlan": "আজকের খাদ্য পরিকল্পনা",
  "totalBirds": "মোট পাখি",
  "diseases": "রোগ",
  "vaccines": "টিকা",
  "emergency": "জরুরি",
  "diagnosis": "নির্ণয়",
  "eggPrice": "ডিমের দাম",
  "meatPrice": "মাংসের দাম",
  "feedCost": "খাদ্য খরচ",
  "aiIsListening": "এআই শুনছে..."
}
```

### 7.2 Bangla Number/Currency

```dart
String formatBDT(double amount) => '৳${amount.toStringAsFixed(2)}';

String toBanglaDigits(String input) {
  const en = ['0','1','2','3','4','5','6','7','8','9'];
  const bn = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
  for (int i = 0; i < en.length; i++) {
    input = input.replaceAll(en[i], bn[i]);
  }
  return input;
}
```

---

## 8. Screen-by-Screen Implementation Guide

### 8.1 Splash Screen

- Orange background with Golden Chicken logo and 🐔 icon
- "Golden Chicken — Poultry AI Assistant" text
- After 2.5s: redirect based on language/auth state

### 8.2 Language Selection Screen

- Two cards: 🇬🇧 English / 🇧🇩 বাংলা
- Selected card has orange border + check icon
- "Continue" button at bottom

### 8.3 Login Screen

- "Welcome Back!" heading, "Sign in to continue to Golden Chicken"
- Phone Number field (with +880 prefix) and Password field
- "Sign In" button (orange), "Forgot Password?" link
- "Don't have an account? Sign Up" link
- Note: Auth uses email+password backend, but UI shows phone field → map to email or adjust backend

### 8.4 Sign Up Screen

- "Create Account" heading
- Full Name, Phone Number, Password fields
- "Create Account" button (orange)
- "Already have an account? Sign In"

### 8.5 Home Screen (AI Chat + Dashboard)

This is the main screen combining AI chat with farm overview. Based on the Figma:

**Layout:**
- Orange AppBar with user name, loyalty points badge (Silver/Gold), notification icon
- Profile drawer (slides from left): home, flock overview, health center, market insights, profile, settings, help, logout
- "Golden AI" chat area with status indicator ("Online — Analyzing your farm")
- Quick info banners: "Water Check — Clean drinkers twice daily" and "Biosec — Disinfect entry points"
- AI message bubble with analysis summary
- Quick action buttons: "আজকের খাদ্য পরিকল্পনা?" / "রোগের প্রথম পরীক্ষা" / "বাজার মূল্য"
- Chat input bar with text field and send
- Bottom nav: চাট | স্বাস্থ্য | বাজার | প্রোফাইল

**When user taps "LIVE AI" button** → navigates to Live AI screen

### 8.6 Flock Overview Screen

From the Figma's flock overview panel:

- Date header ("April 2, 2026 — AI Auto-Updated")
- Stat cards in a row: Total Birds (2,450), Alerts (2), Avg Age (28d)
- AI Score badge (87%)
- Alert cards: "High Temperature Alert", "Rain Expected"
- "Today's Feed Plan" section: Starter Feed, Grower Feed, Supplement Mix with kg amounts
- AI recommendation note at bottom

### 8.7 Health Center Screen

- Search bar: "Search diseases, vaccines..."
- Tab filter row: রোগ (Diseases) | টিকা (Vaccines) | জরুরি (Emergency) | নির্ণয় (Diagnosis)
- Grid of disease cards, each with:
  - Icon (🦠, ⚠️, 🔬, 💊, 🩹)
  - Disease name (EN + BN)
  - Severity badge (High/Critical/Medium/Low) with color coding
  - Symptom count ("6 symptoms")
  - "Ask AI" button → opens chat with prefilled prompt

### 8.8 Market Insights Screen

- "Dhaka Region — Live Prices" header
- Three price hero cards: Egg Price (৳12.5/pc, +4.2%), Meat Price (৳185/kg, -2.6%), Feed Cost (৳42/kg, +2.4%)
- "Updated now" timestamp
- Period toggle: Today | 7 Days | 30 Days
- Price trend chart (line graph with Egg and Meat lines)
- AI market tip card: "💹 ডিম বিক্রির সেরা সময়" with confidence score (88%)
- Meat price alert banner at bottom

### 8.9 Profile Screen

- User avatar with edit icon
- Name, phone, location
- Loyalty Points card (1,240 pts, "760 points to reach Gold", Silver tier)
- Preferences section: Language toggle, Dark Mode toggle, Notifications count
- Data & History: Chat History, Export Farm Data
- Account, Help & Support, About Golden Chicken, Version, Logout

### 8.10 Live AI Screen

Full-screen camera preview as background (pointed at shed/birds) with:
- Semi-transparent overlay
- "Live AI" title
- Three states visible in Figma:
  - **AI Assistant Live** — initial state, AI ready
  - **AI Listening** — orange pulsing mic button, "Tap the orange button to ask a question"
  - **AI Speaking** — AI response waveform, transcript overlay

Controls at bottom: Camera toggle, Mic button (orange circle), End call (red circle)

Transcript overlay shows conversation between farmer and AI in real-time.

---

## 9. Shared Components

### 9.1 AppButton

Primary (orange fill), secondary (outline), text variants. Loading state with spinner.

### 9.2 AppTextField

With label, hint, prefix/suffix icons, validation. Supports BD phone format (+880).

### 9.3 BottomNavBar

4 tabs matching Figma dark navy bar: Chat, Health (🐔), Market, Profile. Orange active icon.

### 9.4 DiseaseCard

Icon + disease name (EN/BN) + severity badge + symptom count + "Ask AI" button. Color-coded border based on severity.

### 9.5 PriceHeroCard

Product icon, price in ৳, percentage change with color-coded arrow, "Updated now" timestamp.

### 9.6 TrendLineChart

`fl_chart` line chart for egg production, mortality, feed consumption, and market price trends. Supports 7d/30d/90d periods.

### 9.7 TaskCard

Task type icon, title, due date/time, completion checkbox, overdue badge (red), recurrence indicator.

### 9.8 InsightCard

Severity-colored left border, insight title, description, proposed action, acknowledge button.

---

## 10. API Integration Layer

### 10.1 Dio Configuration

```dart
class ApiClient {
  late final Dio dio;
  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.addAll([
      AuthInterceptor(), LoggingInterceptor(),
      ErrorInterceptor(), RetryInterceptor(),
    ]);
  }
}
```

### 10.2 SSE Chat Streaming

```dart
// Consume SSE stream from backend
Stream<String> streamChatResponse(String sessionId, String text) async* {
  final response = await dio.get(
    '/chat/sessions/$sessionId/messages/stream',
    queryParameters: {'text': text},
    options: Options(headers: {'Accept': 'text/event-stream'}, responseType: ResponseType.stream),
  );

  await for (final chunk in response.data.stream) {
    final data = utf8.decode(chunk);
    // Parse SSE events, yield text chunks
    for (final line in data.split('\n')) {
      if (line.startsWith('data: ')) {
        final json = jsonDecode(line.substring(6));
        yield json['chunk'];
        if (json['done'] == true) return;
      }
    }
  }
}
```

### 10.3 Failure Types

```dart
abstract class Failure { final String message; const Failure(this.message); }
class ServerFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
```

---

## 11. Image Upload & Camera Integration

1. User taps camera icon in chat input bar
2. Bottom sheet: "Take Photo" or "Choose from Gallery"
3. `ImagePicker` opens camera/gallery
4. Optional crop via `ImageCropper`
5. Compress to max 1MB
6. Preview chip above input bar
7. On send: `multipart/form-data` with text + image
8. AI returns disease diagnosis

---

## 12. Voice Input Integration

**Path A — Chat Screen Mic (lightweight):** On-device `speech_to_text` for quick dictation into text input field.

**Path B — Live AI Screen (primary voice experience):** Raw PCM audio streamed via WebSocket to Gemini 3.1 Flash Live. No separate STT/TTS needed.

---

## 13. Real-time & Live AI Feature

### 13.1 Architecture

```
┌──────────┐     ┌──────────────┐     ┌────────────────────┐
│  Flutter  │◄───►│  FastAPI WS   │◄───►│  Gemini Live API   │
│  (phone)  │     │  (backend)    │     │  (WebSocket)       │
│           │     │              │     │                    │
│ mic audio─┼────►│─forward audio─┼────►│─speech recognition │
│ camera   ─┼────►│─forward frame─┼────►│─vision analysis    │
│           │     │              │     │                    │
│◄─speaker ─┼─────┤◄─audio chunks─┼─────┤◄─spoken response   │
│◄─text    ─┼─────┤◄─transcripts ─┼─────┤◄─text transcript   │
└──────────┘     └──────────────┘     └────────────────────┘
```

### 13.2 WebSocket Datasource

```dart
class LiveAIWebSocketDatasource {
  WebSocketChannel? _channel;

  Stream<Map<String, dynamic>> get responseStream =>
    _channel!.stream.map((raw) => jsonDecode(raw));

  Future<void> connect(String token) async {
    final uri = Uri.parse('${ApiEndpoints.wsBaseUrl}/api/v1/live-ai/stream?token=$token');
    _channel = WebSocketChannel.connect(uri);
    await _channel!.ready;
  }

  void sendAudioChunk(Uint8List pcmData) {
    _channel?.sink.add(jsonEncode({'type': 'audio', 'data': base64Encode(pcmData)}));
  }

  void sendVideoFrame(Uint8List jpegData) {
    _channel?.sink.add(jsonEncode({'type': 'video_frame', 'data': base64Encode(jpegData)}));
  }

  void endSession() {
    _channel?.sink.add(jsonEncode({'type': 'end_session'}));
  }
}
```

### 13.3 LiveAI BLoC

```dart
@freezed
class LiveAIState with _$LiveAIState {
  const factory LiveAIState({
    @Default(LiveSessionStatus.idle) LiveSessionStatus status,
    @Default([]) List<LiveTranscript> transcripts,
    @Default(true) bool isCameraEnabled,
    @Default(false) bool isAISpeaking,
    String? errorMessage,
  }) = _LiveAIState;
}

enum LiveSessionStatus { idle, connecting, listening, aiSpeaking, error }
```

### 13.4 Guardrail Error Handling

Handle WebSocket close code **4003** with error frame:

| Code | UI Action |
|------|-----------|
| `LIVE_AI_DAILY_LIMIT` | "Daily Live AI limit reached. Try again tomorrow." |
| `LIVE_AI_SPEND_CAP` | "Live AI temporarily unavailable. Text chat works." |
| `LIVE_AI_CONCURRENT` | "Close other Live AI session first." |

---

## 14. Offline & Caching Strategy

| Data | Strategy |
|------|----------|
| User profile | Hive cache, refresh on login |
| Health tabs | Hive cache (24h TTL) |
| Recent chat sessions | Hive cache, sync on reconnect |
| Market prices | Hive cache (30min TTL) |
| Farm/shed data | Hive cache, sync on app foreground |
| Offline egg/chicken records | Queue in Hive, sync when online |

---

## 15. Error Handling & Loading States

### 15.1 BLoC State Pattern

```dart
BlocBuilder<ProductionBloc, ProductionState>(
  builder: (context, state) => state.when(
    initial: () => const SizedBox(),
    loading: () => const ProductionShimmer(),
    loaded: (data) => ProductionContent(data: data),
    error: (message) => AppErrorWidget(
      message: message,
      onRetry: () => context.read<ProductionBloc>().add(LoadProduction()),
    ),
  ),
)
```

### 15.2 Empty States

- Chat: "Start a conversation with Golden AI 🐔"
- Egg Records: "No egg records yet. Tap + to add today's count."
- Tasks: "All caught up! No pending tasks."
- Market: "No price data available for your region."

---

## 16. Testing Strategy

### 16.1 Unit Tests (80%+ coverage on domain & data)

- Use cases, BLoCs (event → state), models (JSON), validators, formatters

### 16.2 Widget Tests

- Shared widgets, screen rendering per BLoC state, form validation, navigation

### 16.3 Integration Tests

- Onboarding → Auth → Home flow
- Chat flow: send message → receive AI response
- Production flow: add egg record → view trend
- Locale switch verification

### 16.4 Golden Tests

Screenshot regression for key screens in EN/BN and light/dark themes.

---

## 17. Performance Optimization

- Compress images to max 1MB before upload
- `cached_network_image` for all network images
- `ListView.builder` with keys for all lists
- `const` constructors, scoped `BlocBuilder`
- `flutter build apk --split-per-abi`
- SVG icons (smaller than PNG at all densities)

---

## 18. Accessibility

- All icons/images have `Semantics` labels
- Minimum 48x48dp touch targets
- Support text scaling up to 1.5x
- WCAG AA color contrast (4.5:1 body, 3:1 large text)
- Severity indicators use color AND text labels
- Logical focus order for screen readers

---

## 19. Build, CI/CD & Deployment

### 19.1 Flavors

| Flavor | API Base | Logging |
|--------|----------|---------|
| `dev` | `https://dev-api.goldenchicken.ai` | Verbose |
| `staging` | `https://staging-api.goldenchicken.ai` | Info |
| `production` | `https://api.goldenchicken.ai` | Error only |

### 19.2 CI/CD

```
On Push to main:
  1. flutter analyze
  2. flutter test
  3. flutter build apk --release
  4. flutter build ipa --release
  5. Upload to Firebase App Distribution

On Tag (v*):
  6. Production build
  7. Upload to Play Console + App Store Connect
```

---

## 20. Sprint Breakdown & Milestones

### Sprint 1 (Week 1–2): Foundation

- Project setup, folder structure, dependencies
- Core: Theme (orange palette), colors, typography, spacing
- Core: Dio client, interceptor skeleton, DI setup
- Core: GoRouter, route guards
- Core: Shared widgets (AppButton, AppTextField, BottomNavBar, AppCard)
- Localization setup (ARB files, LocaleBloc)
- **Deliverable:** App shell with navigation between 4 tab screens

### Sprint 2 (Week 3–4): Onboarding, Auth & Home

- Splash screen with Golden Chicken branding
- Language selection screen
- Login screen (phone + password)
- Sign up screen
- AuthBloc with login/register/social use cases
- Token storage (secure storage)
- Route guards
- Home screen: AI chat card, quick action buttons, drawer
- HomeBloc with flock summary
- **Deliverable:** Full onboarding → auth → home flow

### Sprint 3 (Week 5–6): Chat, Health Center & Production

- Chat screen: message bubbles, input bar, streaming, image upload
- ChatBloc with full message lifecycle + SSE streaming
- Quick action chips → prefilled prompts
- Health Center screen: disease grid, severity badges, tab filters
- HealthBloc with disease catalog
- "Ask AI" → opens chat with prefilled prompt
- Flock Overview screen: stat cards, feed plan, alerts
- Egg record & chicken record entry forms
- ProductionBloc
- **Deliverable:** AI Chat + Health Center + Production tracking

### Sprint 4 (Week 7–8): Trends, Tasks & Market

- Trend graph screen (fl_chart): egg production, mortality, FCR
- Period toggle (7d/30d/90d)
- Task list screen: today's tasks, overdue, completed
- Create task screen: type selector, recurrence picker
- TaskBloc
- Market insights screen: price hero cards, trend chart, AI tips
- MarketBloc with price data
- Pull-to-refresh on all data screens
- Error/empty states for all screens
- **Deliverable:** All data screens functional

### Sprint 5 (Week 9–10): Profile, Insights & Live AI

- Profile screen: avatar, loyalty points, preferences
- Edit profile, language toggle, dark mode
- ProfileBloc
- Farm insights screen: insight cards, action checklist
- InsightsBloc
- **Live AI screen (Gemini 3.1 Flash Live):**
  - `AudioRecorderService` (PCM 16kHz + echo cancellation)
  - `AudioPlayerService` (PCM 24kHz playback)
  - `CameraFrameService` (JPEG ≤1 FPS)
  - `LiveAIWebSocketDatasource`
  - `LiveAIBloc` (session lifecycle, transcripts, state machine)
  - `LiveTranscriptOverlay`, `LiveAIControls`
  - Guardrail error handling (4003 codes)
- **Deliverable:** Complete feature set with Live AI

### Sprint 6 (Week 11–12): Polish & QA

- Unit tests for all BLoCs and use cases
- Widget tests for shared components
- Integration tests for critical flows
- Golden tests for EN/BN locales
- Performance profiling
- Accessibility audit
- Bug fixes
- **Deliverable:** Release candidate

### Sprint 7 (Week 13): Release Prep

- Production build configuration
- Play Store / App Store assets (screenshots, descriptions EN + BN)
- CI/CD pipeline finalization
- Soft launch to internal testers
- **Deliverable:** v1.0 ready for submission

---

## Appendix A: Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State management | BLoC | Scalable, testable, event-driven |
| Architecture | Clean Architecture (feature-first) | Clear separation, parallel dev |
| Routing | GoRouter | Deep links, ShellRoute, guards |
| DI | get_it + injectable | Compile-time safety |
| Networking | Dio + Retrofit | Interceptors, type-safe API |
| Local storage | Hive + secure_storage | Fast cache + encrypted tokens |
| Fonts | Plus Jakarta Sans + Hind Siliguri | English + native Bangla |
| Error handling | Either<Failure, T> | Explicit, composable |
| Charts | fl_chart | Lightweight, customizable |
| Color scheme | Orange primary | Matches Golden Chicken brand |

## Appendix B: PRD ↔ Screen Mapping

| PRD Requirement | Screen(s) | Priority |
|----------------|-----------|----------|
| FR-01: Health tabs & AI prompt chat | Health Center, Chat | High |
| FR-02: Egg & chicken record tracker | Flock Overview, Egg Records, Chicken Records | High |
| FR-03: Trend graph & performance view | Trend Graph Screen | High |
| FR-04: Task list & routine reminder planner | Task List, Create Task | High |
| FR-05: Farm insight & alert dashboard | Insights Screen, Home alerts | High |
| Common: Bangla/English | All screens (EN/BN toggle) | High |
| Common: Live AI Agent | Live AI Screen | High |
| Common: RAG Chatbot | Chat Screen (with file/image upload) | High |
| Common: Loyalty Points | Profile Screen, Home | Medium |
| Common: Light/Dark Mode | Profile toggle | Medium |

## Appendix C: Backend Contract Notes

| Endpoint | Notes |
|----------|-------|
| `POST /api/v1/auth/register` | Body uses `full_name`, not separate first/last |
| `GET /api/v1/market/prices` | Direct list under `data`, not paginated |
| `POST /api/v1/health/ask` | Creates chat session from health tab prefilled prompt |
| `GET /api/v1/sheds/{id}/trends/eggs` | Returns `data_points[]` with date + counts |
| `POST /api/v1/chat/messages/{id}/feedback` | Body `{ "value": 1 }` or `{ "value": -1 }` |
| Live AI WebSocket | Token is query param `?token=...`, not header |
| SSE chat streaming | `GET .../messages/stream?text=...` with `Accept: text/event-stream` |

---

*End of Frontend Implementation Plan*
