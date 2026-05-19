import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:coffee_quest/services/analytics/analytics_service.dart';

/// Firebase-backed analytics. Wired in `analytics_provider.dart` once
/// `kUseFirebase` is enabled.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreen(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> setUserId(String? userId) => _analytics.setUserId(id: userId);
}
