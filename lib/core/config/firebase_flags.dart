/// Master switch for Firebase. Stays `false` until the manual setup is done:
/// create the Firebase project, add `ios/Runner/GoogleService-Info.plist`,
/// run `flutterfire configure`, then enable Crashlytics & Remote Config.
///
/// While `false`: bootstrap skips `Firebase.initializeApp`, the service
/// providers return their No-Op implementations, and `main.dart` keeps
/// Flutter's default error handling — so the app and tests run with no
/// Firebase config present.
///
/// To activate: set this to `true` and switch the three commented one-liners
/// in `analytics_provider.dart`, `crash_reporting_provider.dart`, and
/// `remote_config_provider.dart` to the Firebase implementations.
const bool kUseFirebase = false;
