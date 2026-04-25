import 'package:flutter/widgets.dart';
import 'package:golden_chicken/core/l10n/generated/app_localizations.dart';

export 'package:golden_chicken/core/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
