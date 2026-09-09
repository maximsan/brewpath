/// One pure fold over the active-day set, and the nine rules of §10.
library;

import 'package:brew_path/features/progress/domain/streak_status.dart';

/// Derives the whole streak state from [activeDays], read as of [today], both
/// day indices (`epochDay`). They are the **only** inputs: no clock in here,
/// no storage, and no entitlement — §10 makes freezes free for everyone.
///
/// **Today is never judged a miss**, and days after it are ignored rather than
/// folded: a peer whose clock runs ahead would otherwise open a gap behind it.
StreakStatus deriveStreak({
  required Set<int> activeDays,
  required int today,
}) {
  final fold = _StreakFold();
  final days = activeDays.where((day) => day <= today).toList()..sort();
  if (days.isEmpty) return fold.status;

  // One before the first day, so the opening gap is empty and the first
  // qualifying day is reached without a miss in front of it.
  var previous = days.first - 1;
  for (final day in days) {
    fold.missedThrough(from: previous + 1, to: day - 1);
    fold.qualified();
    previous = day;
  }
  fold.missedThrough(from: previous + 1, to: today - 1);
  return fold.status;
}

/// The fold's cursor.
///
/// Mutable and private, which is what keeps [deriveStreak] pure: the state is
/// created, walked and read inside one call. A cursor rather than a chain of
/// copies because the rules read as a sequence of events, and each one reads
/// here as the sentence §10 states it in.
class _StreakFold {
  int _streak = 0;
  int _longestStreak = 0;
  bool _freezeHeld = false;
  int _towardFreeze = 0;
  final Set<int> _frozenDays = {};

  /// One qualifying day.
  void qualified() {
    _streak++;
    // The only place the streak rises, so the high-water mark is complete
    // here — a break below can then zero the streak without losing it.
    if (_streak > _longestStreak) _longestStreak = _streak;
    // "While a freeze is already held, additional qualifying days do not
    // accumulate progress toward another one."
    if (_freezeHeld) return;
    _towardFreeze++;
    if (_towardFreeze < freezeEarnDays) return;
    // "The user earns one streak freeze after completing seven qualifying days
    // in a row." Progress zeroes on the earn, and stays zeroed until a spend
    // reopens accrual — which is the same thing as "seven new days from here".
    _freezeHeld = true;
    _towardFreeze = 0;
  }

  /// The unbroken run of missed days `from`..`to`, empty when `to < from`.
  void missedThrough({required int from, required int to}) {
    if (to < from) return;
    if (!_freezeHeld) {
      _break();
      return;
    }
    // "The freeze is used automatically when the user misses a day", covering
    // the first of them. The streak is preserved, not advanced.
    _freezeHeld = false;
    _towardFreeze = 0;
    _frozenDays.add(from);
    // "If the user misses two consecutive days, the freeze protects the first
    // missed day and the streak resets after the second."
    if (to > from) _break();
  }

  void _break() {
    _streak = 0;
    _towardFreeze = 0;
  }

  StreakStatus get status => StreakStatus(
    streak: _streak,
    longestStreak: _longestStreak,
    freezeHeld: _freezeHeld,
    daysToNextFreeze: _freezeHeld ? null : freezeEarnDays - _towardFreeze,
    freezesSpent: _frozenDays.length,
    frozenDays: Set.unmodifiable(_frozenDays),
  );
}

/// Whether growing the day set from [before] to [after] earned the freeze.
///
/// **A rise, not a state.** `freezeHeld` would answer yes for every run after
/// the seventh; the design's `FREEZE EARNED` row belongs to the run that
/// actually paid it out. Both folds run against the same [today], so a day
/// rolling over cannot look like an earn.
bool freezeEarnedBetween({
  required Set<int> before,
  required Set<int> after,
  required int today,
}) =>
    !deriveStreak(activeDays: before, today: today).freezeHeld &&
    deriveStreak(activeDays: after, today: today).freezeHeld;
