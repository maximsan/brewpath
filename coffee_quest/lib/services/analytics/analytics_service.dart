/// Abstract analytics sink. The real Firebase-backed implementation is wired in
/// Phase 8; until then [NoOpAnalyticsService] is injected so domain code can fire
/// events without any third-party dependency.
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> logScreen(String screenName);
}

class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreen(String screenName) async {}
}
