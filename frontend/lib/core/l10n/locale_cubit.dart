import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(
          Locale(prefs.getString(_localeKey) ?? 'en'),
        );

  final SharedPreferences _prefs;
  static const _localeKey = 'selected_locale';

  bool get hasSelectedLanguage => _prefs.containsKey(_localeKey);

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
    emit(locale);
  }

  void toggleLocale() {
    final next = state.languageCode == 'en'
        ? const Locale('bn')
        : const Locale('en');
    setLocale(next);
  }
}
