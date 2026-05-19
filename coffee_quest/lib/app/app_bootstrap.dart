import 'package:firebase_core/firebase_core.dart';

import 'package:coffee_quest/core/config/firebase_flags.dart';
import 'package:coffee_quest/services/remote_config/firebase_remote_config_service.dart';
import 'package:coffee_quest/shared/storage/app_database.dart';

class AppBootstrap {
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
