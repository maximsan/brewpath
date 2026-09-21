import 'dart:async';

import 'package:brew_path/features/profile/domain/reminder_refresher.dart';
import 'package:brew_path/features/profile/domain/reminder_sync.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/services/reminders/reminder_provider.dart';
import 'package:brew_path/services/reminders/reminder_scheduler.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_reminder_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;
  late FakeReminderScheduler scheduler;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    scheduler = FakeReminderScheduler();
    container = ProviderContainer(
      overrides: [reminderSchedulerProvider.overrideWithValue(scheduler)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  SettingsController settings() =>
      container.read(settingsControllerProvider.notifier);

  ReminderRefresher refresher() => container.read(reminderRefresherProvider);

  test('a refresh posts what the stored preference asks for', () async {
    await settings().setReminderTime('6:30 AM');

    expect(await refresher().refresh(), ReminderSyncOutcome.scheduled);
    expect(scheduler.pending, isNotEmpty);
    expect(
      scheduler.pending.every((at) => at.hour == 6 && at.minute == 30),
      isTrue,
    );
  });

  test(
    'a refresh held open cannot post over the one that followed it',
    () async {
      // The bug this exists for: the settings row and the watcher both refresh,
      // so a run that read `on` used to land its plan after the clear that came
      // of switching the reminder off.
      await settings().setNotificationsEnabled(enabled: true);
      final gate = Completer<void>();
      scheduler.pause = gate.future;

      final held = refresher().refresh();
      await settings().setNotificationsEnabled(enabled: false);
      final second = refresher().refresh();
      gate.complete();
      await Future.wait([held, second]);

      expect(scheduler.writes.last, isEmpty);
      expect(scheduler.pending, isEmpty);
    },
  );

  test('a revoked permission switches the stored preference off', () async {
    await settings().setNotificationsEnabled(enabled: true);
    scheduler.answer = ReminderPermission.denied;

    expect(await refresher().refresh(), ReminderSyncOutcome.permissionLost);
    expect(
      (await SettingsRepository().getSettings()).notificationsEnabled,
      isFalse,
    );
    expect(scheduler.pending, isEmpty);
  });

  test('a refresh queued after the scope is gone reads nothing', () async {
    // The smoke suite tears the app down between walks and closes the
    // database a pump later; a refresh still reading through the old scope
    // would race that close.
    await settings().setNotificationsEnabled(enabled: true);
    final refresh = refresher();
    container.dispose();

    expect(await refresh.refresh(), ReminderSyncOutcome.gone);
    expect(scheduler.writes, isEmpty);
  });

  test('a failed refresh leaves the queue usable', () async {
    await settings().setNotificationsEnabled(enabled: true);
    scheduler.failure = StateError('no notification centre');

    await expectLater(refresher().refresh(), throwsStateError);

    scheduler.failure = null;
    expect(await refresher().refresh(), ReminderSyncOutcome.scheduled);
  });
}
