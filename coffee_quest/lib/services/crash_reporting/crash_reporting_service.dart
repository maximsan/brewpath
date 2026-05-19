/// Abstract crash/error sink. Feature and bootstrap code depend only on this
/// interface — never on `FirebaseCrashlytics.instance` directly.
abstract class CrashReportingService {
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  });
  Future<void> log(String message);
  Future<void> setCustomKey(String key, Object value);
}
