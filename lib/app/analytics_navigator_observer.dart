import 'dart:async';

import 'package:brew_path/services/analytics/analytics_service.dart';
import 'package:flutter/widgets.dart';

/// Reports route changes to [AnalyticsService.logScreen]. Wired into go_router
/// via `observers`. The injected service is the NoOp impl until Firebase lands
/// in Phase 8, so this is currently inert but exercises the call path.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  /// Creates an [AnalyticsNavigatorObserver] over an [AnalyticsService].
  AnalyticsNavigatorObserver(this._analytics);

  final AnalyticsService _analytics;

  void _log(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null) {
      unawaited(_analytics.logScreen(name));
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log(previousRoute);
  }
}
