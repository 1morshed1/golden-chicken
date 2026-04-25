import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_chicken/core/router/route_names.dart';
import 'package:golden_chicken/core/widgets/main_shell.dart';
import 'package:golden_chicken/features/auth/presentation/login_screen.dart';
import 'package:golden_chicken/features/auth/presentation/signup_screen.dart';
import 'package:golden_chicken/features/chat/presentation/chat_tab_screen.dart';
import 'package:golden_chicken/features/health_center/presentation/health_tab_screen.dart';
import 'package:golden_chicken/features/market/presentation/market_tab_screen.dart';
import 'package:golden_chicken/features/onboarding/presentation/language_selection_screen.dart';
import 'package:golden_chicken/features/profile/presentation/profile_tab_screen.dart';
import 'package:golden_chicken/features/splash/presentation/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({
  required bool isLoggedIn,
  required bool hasSelectedLanguage,
}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.matchedLocation;

      if (path == '/') return null;

      if (!hasSelectedLanguage) {
        if (path != '/language') return '/language';
        return null;
      }

      final authPaths = ['/auth/login', '/auth/signup'];
      if (!isLoggedIn && !authPaths.contains(path)) {
        return '/auth/login';
      }
      if (isLoggedIn && authPaths.contains(path)) {
        return '/main/chat';
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
