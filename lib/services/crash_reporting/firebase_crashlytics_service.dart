import 'package:brew_path/services/crash_reporting/crash_reporting_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Firebase Crashlytics-backed implementation. Wired in
/// `crash_reporting_provider.dart` once `kUseFirebase` is enabled.
class FirebaseCrashlyticsService implements CrashReportingService {
  /// Creates a [FirebaseCrashlyticsService] (optional custom [crashlytics]).
  FirebaseCrashlyticsService([FirebaseCrashlytics? crashlytics])
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) => _crashlytics.recordError(error, stack, fatal: fatal);

  @override
  Future<void> log(String message) => _crashlytics.log(message);

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);
}
