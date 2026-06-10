import 'package:coffee_quest/core/utils/date_utils.dart';

/// Result of a streak update.
class StreakResult {
  /// Creates a [StreakResult].
  const StreakResult({
    required this.streakDays,
    required this.lastActivityDate,
  });

  /// Consecutive-day streak count.
  final int streakDays;

  /// Calendar day of the most recent activity.
  final DateTime lastActivityDate;
}

/// Pure streak rule (per `docs/01-mvp-scope.md`): the streak counts consecutive
/// calendar days with at least one completed lesson and resets after any missed
/// day. No multipliers or bonuses in the MVP.
class StreakService {
  /// Creates a [StreakService].
  const StreakService();

  /// Computes the new streak after a lesson completes at [now].
  StreakResult onLessonCompleted({
    required int currentStreak,
    required DateTime? lastActivityDate,
    required DateTime now,
  }) {
    final today = dateOnly(now);
    if (lastActivityDate == null) {
      return StreakResult(streakDays: 1, lastActivityDate: today);
    }
    final gap = dayGap(lastActivityDate, today);
    final int next;
    if (gap <= 0) {
      next = currentStreak; // already counted a lesson today
    } else if (gap == 1) {
      next = currentStreak + 1;
    } else {
      next = 1; // missed at least one full day
    }
    return StreakResult(streakDays: next, lastActivityDate: today);
  }
}
