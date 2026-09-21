/// The one place the OS's pending reminders are made to match the stored
/// preference.
///
/// Called on a cold start, a resume, a day turning over, a completed activity
/// and every change to the two rows — so a reboot, an upgrade or a timezone
/// change cannot leave the app and the OS disagreeing past a launch.
library;

import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/reminder_plan.dart';
import 'package:brew_path/services/reminders/reminder_scheduler.dart';

/// The reminder as the settings row stores it.
typedef ReminderSetting = ({bool enabled, String? time});

/// What a sync found, and what the caller still owes.
enum ReminderSyncOutcome {
  /// The reminder is on and its occurrences are pending.
  scheduled,

  /// The reminder is off and nothing is pending.
  off,

  /// The learner asked for a reminder the OS will not deliver. Nothing is
  /// pending, and the stored preference has to be put back to off so the
  /// switch stops promising one.
  permissionLost,

  /// This build schedules nothing, so the preference was left alone.
  unsupported,

  /// The scope the refresh was queued in is gone — a torn-down app, which the
  /// smoke suite does between its walks. Nothing was read and nothing posted.
  gone,
}

/// Makes what [scheduler] holds match [setting], as of [now].
///
/// [activeDays] are the qualifying days (`epochDay` indices): a day already on
/// it gets no nudge, because a day that is done needs none.
Future<ReminderSyncOutcome> syncReminders(
  ReminderScheduler scheduler, {
  required ReminderSetting setting,
  required Set<int> activeDays,
  required DateTime now,
}) async {
  if (!setting.enabled) {
    await _clear(scheduler);
    return ReminderSyncOutcome.off;
  }

  final permission = await scheduler.permission();
  if (permission == ReminderPermission.unsupported) {
    return ReminderSyncOutcome.unsupported;
  }
  if (permission != ReminderPermission.granted) {
    await _clear(scheduler);
    return ReminderSyncOutcome.permissionLost;
  }

  await scheduler.replaceAll(
    reminderFireTimes(
      now: now,
      slot: DailyReminder.slotFor(setting.time),
      activeDays: activeDays,
    ),
    title: DailyReminder.notificationTitle,
    body: DailyReminder.notificationBody,
  );
  return ReminderSyncOutcome.scheduled;
}

Future<void> _clear(ReminderScheduler scheduler) => scheduler.replaceAll(
  const [],
  title: DailyReminder.notificationTitle,
  body: DailyReminder.notificationBody,
);
