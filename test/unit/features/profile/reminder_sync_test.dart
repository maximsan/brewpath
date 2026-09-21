import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/reminder_plan.dart';
import 'package:brew_path/features/profile/domain/reminder_sync.dart';
import 'package:brew_path/services/reminders/reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_reminder_scheduler.dart';

void main() {
  late FakeReminderScheduler scheduler;
  final morning = DateTime(2026, 9, 21, 6);

  setUp(() => scheduler = FakeReminderScheduler());

  Future<ReminderSyncOutcome> sync({
    required bool enabled,
    String? time = '7:00 AM',
    Set<int> activeDays = const {},
  }) => syncReminders(
    scheduler,
    setting: (enabled: enabled, time: time),
    activeDays: activeDays,
    now: morning,
  );

  test('an enabled reminder is posted at every slot the plan names', () async {
    final outcome = await sync(enabled: true);

    expect(outcome, ReminderSyncOutcome.scheduled);
    expect(
      scheduler.pending,
      reminderFireTimes(
        now: morning,
        slot: DailyReminder.slotFor('7:00 AM'),
        activeDays: const {},
      ),
    );
    expect(scheduler.pending.first, DateTime(2026, 9, 21, 7));
  });

  test('it carries the words the reminder was ruled to say', () async {
    await sync(enabled: true);

    expect(scheduler.title, 'BrewPath');
    expect(scheduler.body, 'Today’s practice keeps your streak alive.');
    // No quantity in the sentence: any qualifying activity keeps the streak,
    // not one lesson (ruled 8 September 2026, #443).
    expect(scheduler.body, isNot(contains('lesson')));
  });

  test('a day already practised on is left out of what is posted', () async {
    await sync(enabled: true, activeDays: {epochDay(morning)});

    expect(scheduler.pending.first, DateTime(2026, 9, 22, 7));
  });

  test('switching it off leaves nothing pending', () async {
    await sync(enabled: true);

    final outcome = await sync(enabled: false);

    expect(outcome, ReminderSyncOutcome.off);
    expect(scheduler.pending, isEmpty);
  });

  test(
    'a refused permission posts nothing and hands back the switch',
    () async {
      scheduler.answer = ReminderPermission.denied;

      final outcome = await sync(enabled: true);

      expect(outcome, ReminderSyncOutcome.permissionLost);
      expect(scheduler.pending, isEmpty);
    },
  );

  test('a build with no scheduler leaves the preference alone', () async {
    scheduler.answer = ReminderPermission.unsupported;

    final outcome = await sync(enabled: true);

    expect(outcome, ReminderSyncOutcome.unsupported);
    expect(scheduler.writes, isEmpty);
  });

  test('an unknown stored slot still posts, at the default hour', () async {
    await sync(enabled: true, time: '3:15 AM');

    expect(scheduler.pending.first, DateTime(2026, 9, 21, 8));
  });

  test('a second sync replaces what the first posted', () async {
    await sync(enabled: true);

    await sync(enabled: true, time: '6:30 AM');

    expect(scheduler.writes, hasLength(2));
    expect(scheduler.pending.first, DateTime(2026, 9, 21, 6, 30));
  });
}
