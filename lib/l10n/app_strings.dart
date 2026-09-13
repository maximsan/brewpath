/// Reading the interface strings the way the mood colours are read.
library;

import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// The interface strings, in the locale this build resolved to.
extension AppStrings on BuildContext {
  /// Every translated interface string, from `lib/l10n/*.arb`.
  AppLocalizations get strings => AppLocalizations.of(this);
}
