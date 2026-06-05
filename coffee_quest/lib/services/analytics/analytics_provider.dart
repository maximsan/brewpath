import 'package:coffee_quest/services/analytics/analytics_service.dart';
import 'package:coffee_quest/services/analytics/noop_analytics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Activation: import + return FirebaseAnalyticsService() once kUseFirebase is
// true (see lib/core/config/firebase_flags.dart).
// import 'package:coffee_quest/services/analytics/firebase_analytics_service.dart';

part 'analytics_provider.g.dart';

@riverpod
AnalyticsService analyticsService(Ref ref) => const NoOpAnalyticsService();
// To activate Firebase: => FirebaseAnalyticsService();
