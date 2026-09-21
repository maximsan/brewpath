/// When the daily reminder should arrive — the whole rule, as arithmetic.
///
/// No clock, no storage, no platform: a fold over the day set and a slot, so
/// what the app asks the OS to hold can be asserted without an OS.
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/profile/domain/daily_reminder.dart';

/// How many days ahead the app keeps reminders pending.
///
/// One-shot occurrences rather than one repeating request, because a day the
/// learner has already practised on gets no nudge (#443) and a repeat cannot
/// skip an occurrence. Well under the 64 iOS keeps, and re-filled on every
/// launch and resume.
const reminderHorizonDays = 14;

/// The instants the reminder should arrive at, soonest first.
///
/// A day already in [activeDays] is skipped — a day that is done gets no
/// nudge — and so is a slot [now] has passed. Built from local `DateTime`s, so
/// an hour lost or gained to daylight saving lands on the wall clock the
/// learner chose rather than a fixed number of hours from here.
List<DateTime> reminderFireTimes({
  required DateTime now,
  required ReminderSlot slot,
  required Set<int> activeDays,
}) => [
  for (var ahead = 0; ahead < reminderHorizonDays; ahead++)
    DateTime(now.year, now.month, now.day + ahead, slot.hour, slot.minute),
].where((at) => at.isAfter(now) && !activeDays.contains(epochDay(at))).toList();
