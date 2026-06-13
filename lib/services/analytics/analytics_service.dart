/// Abstract analytics sink. Firebase-backed and No-Op implementations live in
/// sibling files; the provider selects one. Feature code depends only on this
/// interface — never on `FirebaseAnalytics.instance` directly.
abstract class AnalyticsService {
  /// Logs a named analytics event with optional [parameters].
  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  /// Logs a screen view for [screenName].
  Future<void> logScreen(String screenName);

  /// Passing `null` clears the user ID.
  Future<void> setUserId(String? userId);
}
