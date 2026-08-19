/// One pure fold over the active-day set, and the nine rules of §10.
library;

import 'package:brew_path/features/progress/domain/streak_status.dart';

/// Derives the whole streak state from [activeDays], read as of [today].
///
/// Both are day indices — `epochDay` from `core/utils/date_utils.dart` — and
/// they are the **only** inputs. There is no clock in here, no storage, and
/// deliberately no entitlement: §10 makes freezes free for everyone, so there
/// is no parameter a paid tier could arrive through.
///
/// **Today is never judged a miss.** A day the learner has not finished yet is
/// not a day they skipped, so an inactive [today] neither spends the freeze nor
/// breaks the streak; both decide when the day is over. Days *after* [today]
/// are ignored rather than folded — a peer whose clock runs ahead can write
/// one, and counting it would open a gap of missed days behind it.
///
/// The fold walks the gaps between active days rather than every calendar day,
/// so its cost is the size of the set and not the age of the account.
StreakStatus deriveStreak({
  required Set<int> activeDays,
  required int today,
}) {
  final days = activeDays.where((day) => day <= today).toList()..sort();
  if (days.isEmpty) return StreakStatus.idle;

  final fold = _StreakFold();
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
/// created, walked and read inside one call and can never be observed
/// mid-fold. Written as a cursor rather than a chain of copies because the
/// rules are read as a sequence of events — one qualifying day, one run of
/// missed days — and each one reads here as the sentence §10 states it in.
class _StreakFold {
  int _streak = 0;
  bool _freezeHeld = false;
  int _towardFreeze = 0;
  final Set<int> _frozenDays = {};

  /// One qualifying day.
  void qualified() {
    _streak++;
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
    freezeHeld: _freezeHeld,
    daysToNextFreeze: _freezeHeld ? null : freezeEarnDays - _towardFreeze,
    freezesSpent: _frozenDays.length,
    frozenDays: Set.unmodifiable(_frozenDays),
  );
}
