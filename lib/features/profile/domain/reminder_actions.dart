/// The three things the app ever does to the daily reminder: ask for it, drop
/// it, and put the OS back in step with what is stored.
///
/// Plain functions over a `WidgetRef`, the shape `resetProgress` already uses:
/// the state lives in the settings row, so a controller here would only be a
/// second place for it.
library;

import 'package:brew_path/features/profile/domain/reminder_refresher.dart';
import 'package:brew_path/features/profile/domain/reminder_sync.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/services/crash_reporting/crash_reporting_provider.dart';
import 'package:brew_path/services/reminders/reminder_provider.dart';
import 'package:brew_path/services/reminders/reminder_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks the OS for permission, and stores the reminder only if it says yes.
///
/// [time] is the slot to store; null keeps whatever slot is already there. A
/// refusal writes nothing at all, so the switch stays off and the row keeps
/// reading *Off* — a switch that shows on is a promise the OS would break.
Future<ReminderPermission> askForReminder(WidgetRef ref, {String? time}) async {
  final scheduler = ref.read(reminderSchedulerProvider);

  var permission = await scheduler.permission();
  if (permission == ReminderPermission.denied) {
    permission = await scheduler.request();
  }
  if (permission == ReminderPermission.denied) return permission;

  final settings = ref.read(settingsControllerProvider.notifier);
  await (time == null
      ? settings.setNotificationsEnabled(enabled: true)
      : settings.setReminderTime(time));
  await refreshReminders(ref);

  return permission;
}

/// Drops the reminder: the preference goes off and nothing stays pending.
Future<void> dropReminder(WidgetRef ref) async {
  await ref
      .read(settingsControllerProvider.notifier)
      .setNotificationsEnabled(enabled: false);
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
  try {
    await refreshReminders(ref);
  } on Object catch (error, stack) {
    await ref.read(crashReportingServiceProvider).recordError(error, stack);
  }
}
