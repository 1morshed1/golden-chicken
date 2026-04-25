import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/app.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/core/l10n/locale_cubit.dart';
import 'package:golden_chicken/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LocaleCubit(prefs: sl<SharedPreferences>()),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(prefs: sl<SharedPreferences>()),
        ),
      ],
      child: const GoldenChickenApp(),
    ),
  );
}
