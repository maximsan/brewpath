/// The three things the app ever does to the daily reminder: ask for it, drop
/// it, and put the OS back in step with what is stored.
///
/// Plain functions over a `WidgetRef`, the shape `resetProgress` already uses:
/// the state lives in the settings row, so a controller here would only be a
/// second place for it.
library;

import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';
import 'package:brew_path/features/profile/domain/reminder_refresher.dart';
import 'package:brew_path/features/profile/domain/reminder_sync.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/services/crash_reporting/crash_reporting_provider.dart';
import 'package:brew_path/services/reminders/reminder_provider.dart';
import 'package:brew_path/services/reminders/reminder_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks the OS for permission, and stores the reminder only if it says yes.
///
/// [time] is the slot to store; null takes the one already stored, or
/// [startingSlot] where there is none. A refusal writes nothing at all, so the
/// switch stays off and the row keeps reading *Off* — a switch that shows on
/// is a promise the OS would break.
Future<ReminderPermission> askForReminder(WidgetRef ref, {String? time}) async {
  final scheduler = ref.read(reminderSchedulerProvider);

  var permission = await scheduler.permission();
  if (permission == ReminderPermission.denied) {
    permission = await scheduler.request();
  }
  // Only a yes stores it. `unsupported` is a build with nothing to deliver
  // with, and a switch showing on there would promise exactly as little.
  if (permission != ReminderPermission.granted) return permission;

  await ref
      .read(settingsControllerProvider.notifier)
      .setReminderTime(time ?? await startingSlot(ref));
  await refreshReminders(ref);

  return permission;
}

/// The slot the switch turns on at: the stored one, or [DailyReminder]'s
/// opening slot for the current time where the learner has never chosen.
///
/// A slot they did choose is never moved, even where it has gone by — a
/// deliberate 6:30 AM means tomorrow, not this afternoon.
Future<String> startingSlot(WidgetRef ref) async {
  final stored = (await ref.read(
    settingsControllerProvider.future,
  )).dailyReminderTime;
  return stored ??
      DailyReminder.openingSlot(ref.read(appClockProvider)()).label;
}

/// Drops the reminder: the preference goes off and nothing stays pending.
Future<void> dropReminder(WidgetRef ref) async {
  await ref.read(settingsControllerProvider.notifier).turnNotificationsOff();
  await refreshReminders(ref);
}

/// Makes the OS's pending reminders match the stored preference.
Future<ReminderSyncOutcome> refreshReminders(WidgetRef ref) =>
    ref.read(reminderRefresherProvider).refresh();

/// [refreshReminders] with nowhere to fail to.
///
/// The watcher calls this from a lifecycle callback, where a throw becomes an
/// unhandled async error and takes the app down over a reminder. It goes to
/// the crash sink instead — there is no screen to put it on.
Future<void> refreshRemindersQuietly(WidgetRef ref) async {
  // Resolved before the await, not inside the catch: by the time a refresh
  // fails the scope may be gone, and a `read` there would throw out of the
  // handler that exists to stop exactly that.
  final crashes = ref.read(crashReportingServiceProvider);
  try {
    await refreshReminders(ref);
  } on Object catch (error, stack) {
    await crashes.recordError(error, stack);
  }
}
