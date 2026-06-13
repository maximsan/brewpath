import 'package:coffee_quest/services/analytics/analytics_service.dart';

/// Inert analytics — the default until Firebase is activated, and the impl
/// used by all tests.
class NoOpAnalyticsService implements AnalyticsService {
  /// Creates a [NoOpAnalyticsService].
  const NoOpAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreen(String screenName) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}
