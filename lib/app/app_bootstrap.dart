import 'package:brew_path/core/config/firebase_flags.dart';
import 'package:brew_path/core/config/payments_flags.dart';
import 'package:brew_path/services/remote_config/firebase_remote_config_service.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/theme/app_theme_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// One-time app initialization (database, and Firebase when enabled).
class AppBootstrap {
  /// Initializes the database, and the services this build has keys for, then
  /// returns the persisted appearance preference.
  ///
  /// The preference is read here rather than in a provider because `main()`
  /// already awaits this before `runApp`: the opening frame is drawn in the
  /// right mood, so there is no flash of the wrong theme to mitigate.
  static Future<AppThemeMode> initialize() async {
    AppDatabaseService.instance = AppDatabase();

    // Gated until the manual Firebase setup is done (see kUseFirebase). With
    // no GoogleService-Info.plist present, initializeApp would throw — so we
    // skip it entirely while the flag is false.
    if (kUseFirebase) {
      await Firebase.initializeApp();
      await FirebaseRemoteConfigService().fetchAndActivate();
    }

    // Skipped without a key, so a build that cannot take money never reaches
    // RevenueCat (see kUseRevenueCat).
    if (kUseRevenueCat) {
      await Purchases.configure(PurchasesConfiguration(kRevenueCatKey));
    }

    return (await SettingsRepository().getSettings()).themeMode;
  }
}
