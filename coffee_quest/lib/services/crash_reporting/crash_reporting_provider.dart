import 'package:coffee_quest/services/crash_reporting/crash_reporting_service.dart';
import 'package:coffee_quest/services/crash_reporting/noop_crash_reporting_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Activation: import + return FirebaseCrashlyticsService() once kUseFirebase
// is true (see lib/core/config/firebase_flags.dart).
// import 'package:coffee_quest/services/crash_reporting/firebase_crashlytics_service.dart';

part 'crash_reporting_provider.g.dart';

@riverpod
CrashReportingService crashReportingService(Ref ref) =>
    const NoOpCrashReportingService();
// To activate Firebase: => FirebaseCrashlyticsService();
