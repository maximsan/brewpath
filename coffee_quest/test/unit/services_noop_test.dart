import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/services/analytics/analytics_provider.dart';
import 'package:coffee_quest/services/analytics/noop_analytics_service.dart';
import 'package:coffee_quest/services/crash_reporting/crash_reporting_provider.dart';
import 'package:coffee_quest/services/crash_reporting/noop_crash_reporting_service.dart';
import 'package:coffee_quest/services/remote_config/noop_remote_config_service.dart';
import 'package:coffee_quest/services/remote_config/remote_config_keys.dart';
import 'package:coffee_quest/services/remote_config/remote_config_provider.dart';

void main() {
  test('service providers default to the No-Op implementations', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(analyticsServiceProvider), isA<NoOpAnalyticsService>());
    expect(
      c.read(crashReportingServiceProvider),
      isA<NoOpCrashReportingService>(),
    );
    expect(
      c.read(remoteConfigServiceProvider),
      isA<NoOpRemoteConfigService>(),
    );
  });

  test('No-Op analytics and crash reporting are inert', () async {
    const analytics = NoOpAnalyticsService();
    await analytics.logEvent('e', parameters: {'k': 1});
    await analytics.logScreen('s');
    await analytics.setUserId('u');

    const crash = NoOpCrashReportingService();
    await crash.recordError(StateError('x'), StackTrace.current, fatal: true);
    await crash.log('m');
    await crash.setCustomKey('k', 'v');
  });

  test('No-Op remote config returns the MVP defaults', () {
    const rc = NoOpRemoteConfigService();
    expect(rc.getString(RemoteConfigKeys.forceUpdateMinVersion), '0.0.0');
    expect(rc.getInt(RemoteConfigKeys.dailyLessonGoal), 1);
    expect(rc.getBool(RemoteConfigKeys.enableCardAnimations), isFalse);
  });
}
