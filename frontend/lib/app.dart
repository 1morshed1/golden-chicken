import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:golden_chicken/core/l10n/generated/app_localizations.dart';
import 'package:golden_chicken/core/l10n/locale_cubit.dart';
import 'package:golden_chicken/core/router/app_router.dart';
import 'package:golden_chicken/core/theme/app_theme.dart';
import 'package:golden_chicken/core/theme/theme_cubit.dart';

class GoldenChickenApp extends StatelessWidget {
  const GoldenChickenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            final router = createRouter(
              isLoggedIn: false,
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
    );
  }
}
