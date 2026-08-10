import 'package:brew_path/services/crash_reporting/crash_reporting_service.dart';

/// Inert crash reporting — the default until Firebase is activated.
class NoOpCrashReportingService implements CrashReportingService {
  /// Creates a [NoOpCrashReportingService].
  const NoOpCrashReportingService();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}
