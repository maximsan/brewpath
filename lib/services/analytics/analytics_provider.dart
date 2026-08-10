import 'package:brew_path/services/analytics/analytics_service.dart';
import 'package:brew_path/services/analytics/noop_analytics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Activation: import + return FirebaseAnalyticsService() once kUseFirebase is
// true (see lib/core/config/firebase_flags.dart).
// import 'package:brew_path/services/analytics/firebase_analytics_service.dart';

part 'analytics_provider.g.dart';

/// Provides the active [AnalyticsService] — No-Op until Firebase is enabled.
@riverpod
AnalyticsService analyticsService(Ref ref) => const NoOpAnalyticsService();
// To activate Firebase: => FirebaseAnalyticsService();
