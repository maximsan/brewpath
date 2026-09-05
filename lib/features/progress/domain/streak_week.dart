/// The streak's week: the strip's seven cells, derived from the active-day
/// set (#26), and how far into a week the count itself stands (#498).
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:flutter/foundation.dart';

/// Days in a week: the strip's cells, Monday through Sunday, and the span the
/// ring fills over.
const int daysPerWeek = 7;

/// How far [streak] stands into its current week: 1 to 7, or 0 with no streak
/// at all.
///
/// The week here is the streak's own, counted from the day it began, not the
/// calendar week the strip below draws — so the two agree on length and
/// nothing else.
///
/// A closing day reads 7 rather than 0. Day 7 finishes a week rather than
/// starting an empty one, so the ring closes before it begins again — the
/// design's *"5 days on a 12-day streak = 5/7 … closes every 7th day"*.
int streakWeekDay(int streak) {
  if (streak <= 0) return 0;
  final dayOfWeek = streak % daysPerWeek;
  return dayOfWeek == 0 ? daysPerWeek : dayOfWeek;
}

/// The hero ring's fill over the current week, 0..1 (#498).
///
/// Only the fill wraps: the count inside the ring, the week strip and the
/// freeze cadence all keep running off the streak itself.
double weekRingFraction(int streak) => streakWeekDay(streak) / daysPerWeek;

/// What one cell of the week strip says about its day.
enum StreakDayMark {
  /// The learner completed a qualifying activity.
  done,

  /// Missed, and a freeze covered it. A third state, distinct from both of the
  /// others, so the strip can never claim a day was earned when it was only
  /// protected.
  frozen,

  /// Nothing — missed and uncovered, or still ahead.
  empty,
}

/// One cell.
@immutable
class StreakDay {
  /// Creates a [StreakDay].
  const StreakDay({
    required this.day,
    required this.mark,
    required this.isToday,
  });

  /// The calendar day, as days since epoch.
  final int day;

  /// How the cell renders.
  final StreakDayMark mark;

  /// Whether this is the day the strip was built for. Today keeps a position
  /// cue whatever its mark, so a reset streak does not read as a credited day.
  final bool isToday;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakDay &&
          other.day == day &&
          other.mark == mark &&
          other.isToday == isToday;

  @override
  int get hashCode => Object.hash(day, mark, isToday);

  @override
  String toString() =>
      'StreakDay($day, ${mark.name}${isToday ? ', today' : ''})';
}

/// The seven cells of the week containing [today], Monday first.
///
/// **Each day is read straight out of [activeDays]** — in the set, done;
/// otherwise covered by a freeze, frozen; otherwise empty. No arithmetic, no
/// clipping, and correct by construction.
///
/// The prototype instead filled the last `streak` cells ending today, because
/// it had no day set to read. That drops a genuinely active day the moment a
/// freeze covers one inside the visible week: a covered day preserves the
/// streak without raising it, so the run spans `streak + 1` calendar days and
/// the arithmetic clips the earliest one off. Ruled in #26 — this is a case
/// where porting the source would ship the defect.
///
/// [today] is a `DateTime` and not a day index because a week boundary is not
/// recoverable from the index: `epochDay` counts local midnights, which land
/// on a different UTC day depending on the offset, so only the calendar knows
/// which weekday an index is.
List<StreakDay> weekStrip({
  required Set<int> activeDays,
  required StreakStatus status,
  required DateTime today,
}) {
  // Built by field arithmetic rather than by subtracting a Duration, which
  // lands on the previous day's 23:00 across a DST boundary.
  final monday = DateTime(
    today.year,
    today.month,
    today.day - (today.weekday - DateTime.monday),
  );
  final todayIndex = epochDay(today);

  return [
    for (var offset = 0; offset < daysPerWeek; offset++)
      _cell(
        epochDay(DateTime(monday.year, monday.month, monday.day + offset)),
        activeDays: activeDays,
        frozenDays: status.frozenDays,
        todayIndex: todayIndex,
      ),
  ];
}

StreakDay _cell(
  int day, {
  required Set<int> activeDays,
  required Set<int> frozenDays,
  required int todayIndex,
}) => StreakDay(
  day: day,
  // A day ahead of today reads empty whatever the set says. `deriveStreak`
  // discards those days — a peer whose clock runs ahead writes them — and a
  // strip that painted one done would credit a day the count does not.
  mark: day > todayIndex
      ? StreakDayMark.empty
      : activeDays.contains(day)
      ? StreakDayMark.done
      : frozenDays.contains(day)
      ? StreakDayMark.frozen
      : StreakDayMark.empty,
  isToday: day == todayIndex,
);
