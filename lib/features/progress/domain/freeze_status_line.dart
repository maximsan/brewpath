/// The streak screen's one-line freeze status (#26, #232).
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';

/// Weekday names for the covered-day line, Monday first — the order the week
/// renders everywhere else.
const List<String> weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// The one line that carries the whole freeze state.
///
/// Three branches, first match wins (#26 §4): a day this week was covered —
/// name it; else a freeze is held — say so, with no countdown, because accrual
/// is paused and [StreakStatus.daysToNextFreeze] is null; else the countdown.
/// Under a cap of one the held copy is singular by construction.
String freezeStatusLine({
  required StreakStatus status,
  required DateTime today,
}) {
  final todayIndex = epochDay(today);
  final mondayIndex = todayIndex - (today.weekday - DateTime.monday);
  final coveredThisWeek =
      status.frozenDays
          .where((day) => day >= mondayIndex && day <= todayIndex)
          .toList()
        ..sort();
  if (coveredThisWeek.isNotEmpty) {
    final weekdayName = weekdayNames[coveredThisWeek.last - mondayIndex];
    return '$weekdayName was covered by a freeze';
  }
  if (status.freezeHeld) return '1 freeze held · covers a missed day';
  final daysLeft = status.daysToNextFreeze ?? freezeEarnDays;
  return daysLeft == 1
      ? 'Next freeze in 1 day'
      : 'Next freeze in $daysLeft days';
}
