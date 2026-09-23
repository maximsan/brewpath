import 'dart:io';

import 'package:brew_path/services/reminders/local_notifications_reminder_scheduler.dart';
import 'package:brew_path/services/reminders/reminder_scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_provider.g.dart';

/// The active [ReminderScheduler].
///
/// iOS is the only platform this app ships, and the only one with a scheduler
/// behind it — so everywhere else, including `flutter_tester`, gets the no-op
/// and no test has to remember to override it. Kept alive because the
/// scheduler initialises the plugin once and remembers what it posted.
@Riverpod(keepAlive: true)
ReminderScheduler reminderScheduler(Ref ref) => Platform.isIOS
    ? LocalNotificationsReminderScheduler()
    : const NoOpReminderScheduler();
