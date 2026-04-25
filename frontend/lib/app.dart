import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:golden_chicken/core/l10n/generated/app_localizations.dart';
import 'package:golden_chicken/core/l10n/locale_cubit.dart';
import 'package:golden_chicken/core/router/app_router.dart';
import 'package:golden_chicken/core/theme/app_theme.dart';
import 'package:golden_chicken/core/theme/theme_cubit.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_state.dart';

class GoldenChickenApp extends StatefulWidget {
  const GoldenChickenApp({super.key});

  @override
  State<GoldenChickenApp> createState() => _GoldenChickenAppState();
}

class _GoldenChickenAppState extends State<GoldenChickenApp> {
  final _authNotifier = ValueNotifier<AuthState>(const AuthInitial());

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _authNotifier.value = state;
      },
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              final router = createRouter(
                authNotifier: _authNotifier,
                hasSelectedLanguage:
                    context.read<LocaleCubit>().hasSelectedLanguage,
              );

              return MaterialApp.router(
                title: 'Golden Chicken',
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: AppTheme.light(locale: locale.languageCode),
                darkTheme: AppTheme.dark(locale: locale.languageCode),
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
