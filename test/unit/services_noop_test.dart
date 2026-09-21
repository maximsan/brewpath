import 'package:brew_path/services/analytics/analytics_provider.dart';
import 'package:brew_path/services/analytics/noop_analytics_service.dart';
import 'package:brew_path/services/crash_reporting/crash_reporting_provider.dart';
import 'package:brew_path/services/crash_reporting/noop_crash_reporting_service.dart';
import 'package:brew_path/services/remote_config/noop_remote_config_service.dart';
import 'package:brew_path/services/remote_config/remote_config_keys.dart';
import 'package:brew_path/services/remote_config/remote_config_provider.dart';
import 'package:brew_path/services/reminders/reminder_provider.dart';
import 'package:brew_path/services/reminders/reminder_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('service providers default to the No-Op implementations', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(analyticsServiceProvider), isA<NoOpAnalyticsService>());
    expect(
      c.read(crashReportingServiceProvider),
      isA<NoOpCrashReportingService>(),
    );
    expect(c.read(remoteConfigServiceProvider), isA<NoOpRemoteConfigService>());
    // iOS is the only platform with a scheduler behind it, so the suite gets
    // the no-op without any test having to remember to override it.
    expect(c.read(reminderSchedulerProvider), isA<NoOpReminderScheduler>());
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

  test('the No-Op scheduler holds nothing and asks for nothing', () async {
    const scheduler = NoOpReminderScheduler();
    expect(await scheduler.permission(), ReminderPermission.unsupported);
    expect(await scheduler.request(), ReminderPermission.unsupported);
    await scheduler.replaceAll([DateTime(2026, 9, 21)], title: 't', body: 'b');
    await scheduler.openSystemSettings();
  });

  test('No-Op remote config returns the MVP defaults', () {
    const rc = NoOpRemoteConfigService();
    expect(rc.getString(RemoteConfigKeys.forceUpdateMinVersion), '0.0.0');
    expect(rc.getInt(RemoteConfigKeys.dailyLessonGoal), 1);
    expect(rc.getBool(RemoteConfigKeys.enableCardAnimations), isFalse);
  });
}
