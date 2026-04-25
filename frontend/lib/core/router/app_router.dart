import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_chicken/core/router/route_names.dart';
import 'package:golden_chicken/core/widgets/main_shell.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_state.dart';
import 'package:golden_chicken/features/auth/presentation/login_screen.dart';
import 'package:golden_chicken/features/auth/presentation/signup_screen.dart';
import 'package:golden_chicken/features/chat/presentation/chat_detail_screen.dart';
import 'package:golden_chicken/features/chat/presentation/chat_tab_screen.dart';
import 'package:golden_chicken/features/health_center/presentation/health_tab_screen.dart';
import 'package:golden_chicken/features/market/presentation/market_tab_screen.dart';
import 'package:golden_chicken/features/onboarding/presentation/language_selection_screen.dart';
import 'package:golden_chicken/features/production/presentation/chicken_records_screen.dart';
import 'package:golden_chicken/features/production/presentation/egg_records_screen.dart';
import 'package:golden_chicken/features/production/presentation/flock_overview_screen.dart';
import 'package:golden_chicken/features/profile/presentation/profile_tab_screen.dart';
import 'package:golden_chicken/features/splash/presentation/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({
  required ValueNotifier<AuthState> authNotifier,
  required bool hasSelectedLanguage,
}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final authState = authNotifier.value;
      final isAuthenticated = authState is AuthAuthenticated;
      final isCheckingAuth =
          authState is AuthInitial || authState is AuthLoading;

      if (path == '/' && isCheckingAuth) return null;

      if (!hasSelectedLanguage && path != '/language' && path != '/') {
        return '/language';
      }

      final authPaths = ['/auth/login', '/auth/signup'];

      if (isAuthenticated && (authPaths.contains(path) || path == '/')) {
        return '/main/chat';
      }

      if (!isAuthenticated &&
          !isCheckingAuth &&
          !authPaths.contains(path) &&
          path != '/' &&
          path != '/language') {
        return '/auth/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language',
        name: RouteNames.languageSelection,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/flock-overview',
        name: RouteNames.flockOverview,
        builder: (context, state) => const FlockOverviewScreen(),
      ),
      GoRoute(
        path: '/egg-records',
        name: RouteNames.eggRecords,
        builder: (context, state) => const EggRecordsScreen(),
      ),
      GoRoute(
        path: '/chicken-records',
        name: RouteNames.chickenRecords,
        builder: (context, state) => const ChickenRecordsScreen(),
      ),
      GoRoute(
        path: '/chat/detail',
        name: RouteNames.chatDetail,
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['sessionId'];
          final prompt = state.uri.queryParameters['prompt'];
          return ChatDetailScreen(
            sessionId: sessionId,
            initialPrompt: prompt,
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/main/chat',
            name: RouteNames.chat,
            builder: (context, state) => const ChatTabScreen(),
          ),
          GoRoute(
            path: '/main/health',
            name: RouteNames.healthCenter,
            builder: (context, state) => const HealthTabScreen(),
          ),
          GoRoute(
            path: '/main/market',
            name: RouteNames.marketInsights,
            builder: (context, state) => const MarketTabScreen(),
          ),
          GoRoute(
            path: '/main/profile',
            name: RouteNames.profile,
            builder: (context, state) => const ProfileTabScreen(),
          ),
        ],
      ),
    ],
  );
}
