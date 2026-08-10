import 'package:brew_path/services/crash_reporting/crash_reporting_service.dart';
import 'package:brew_path/services/crash_reporting/noop_crash_reporting_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Activation: import + return FirebaseCrashlyticsService() once kUseFirebase
// is true (see lib/core/config/firebase_flags.dart).
// import 'package:brew_path/services/crash_reporting/firebase_crashlytics_service.dart';

part 'crash_reporting_provider.g.dart';

/// Provides the active [CrashReportingService] — No-Op until Firebase is on.
@riverpod
CrashReportingService crashReportingService(Ref ref) =>
    const NoOpCrashReportingService();
// To activate Firebase: => FirebaseCrashlyticsService();
