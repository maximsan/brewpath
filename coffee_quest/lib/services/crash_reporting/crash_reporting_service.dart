/// Abstract crash/error sink. Feature and bootstrap code depend only on this
/// interface — never on `FirebaseCrashlytics.instance` directly.
abstract class CrashReportingService {
  /// Records an [error] (with optional [stack]); set [fatal] for crashes.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  });

  /// Logs a breadcrumb [message] attached to subsequent reports.
  Future<void> log(String message);

  /// Attaches a custom [key]/[value] pair to subsequent reports.
  Future<void> setCustomKey(String key, Object value);
}
