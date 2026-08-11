import 'package:brew_path/core/config/firebase_flags.dart';
import 'package:brew_path/services/remote_config/firebase_remote_config_service.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:firebase_core/firebase_core.dart';

/// One-time app initialization (database, and Firebase when enabled).
class AppBootstrap {
  /// Initializes the database and, when [kUseFirebase] is set, Firebase.
  static Future<void> initialize() async {
    AppDatabaseService.instance = AppDatabase();

    // Gated until the manual Firebase setup is done (see kUseFirebase). With
    // no GoogleService-Info.plist present, initializeApp would throw — so we
    // skip it entirely while the flag is false.
    if (kUseFirebase) {
      await Firebase.initializeApp();
      await FirebaseRemoteConfigService().fetchAndActivate();
    }
  }
}
