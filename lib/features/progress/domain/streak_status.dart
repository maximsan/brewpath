/// Everything the streak rules derive from the stored set of active days.
library;

import 'package:flutter/foundation.dart';

/// Qualifying days in a row that earn a freeze (§10).
const int freezeEarnDays = 7;

/// Freezes a learner may hold at once (§10).
///
/// The value is **1**, which is why [StreakStatus.freezeHeld] is a boolean
/// rather than a count: the cap is expressed in the type, so no arithmetic can
/// exceed it. The prototype's `FREEZE_CAP = 2` is superseded (#58) and its
/// pip row is dropped with it (#26) — one dash on the covered day and one
/// status line carry what two pips used to.
const int maxFreezesHeld = 1;

/// The streak, the freeze, and the days a freeze covered — all **derived**,
/// none of them stored.
///
/// A stored copy of any of these would need a merge rule, and a max-merged
/// counter launders an inflation bug permanently: two devices offline at five
/// days each do not make five, and no later correction can lower the number
/// once it has been written. The active-day set unions instead, which is
/// exactly right, and everything here is recovered by replaying it.
@immutable
class StreakStatus {
  /// Creates a [StreakStatus]. Prefer `deriveStreak` — this exists for the
  /// two constants below and for tests that want a fixture.
  const StreakStatus({
    required this.streak,
    required this.freezeHeld,
    required this.daysToNextFreeze,
    required this.freezesSpent,
    required this.frozenDays,
  });

  /// A learner with no qualifying day yet: no streak, no freeze, and the full
  /// seven days still to go. Also what Reset Progress leaves behind, since it
  /// clears the day set this derives from.
  static const idle = StreakStatus(
    streak: 0,
    freezeHeld: false,
    daysToNextFreeze: freezeEarnDays,
    freezesSpent: 0,
    frozenDays: {},
  );

  /// Consecutive qualifying days, counting today only once it qualifies.
  ///
  /// A day a freeze covered **preserves this and does not raise it** (§10), so
  /// a run of `streak` days can span more than `streak` calendar days — the
  /// defect that makes deriving the week strip from this number wrong (#26).
  final int streak;

  /// Whether an unspent freeze is held. See [maxFreezesHeld] for why this is
  /// not a count.
  final bool freezeHeld;

  /// Qualifying days still needed to earn a freeze, or **null while one is
  /// held** — accrual stops at the cap (§10), so there is no countdown to
  /// show. The surface renders this only in its `held == 0` branch (#26), and
  /// null is what makes rendering it in the other branch impossible.
  final int? daysToNextFreeze;

  /// Freezes spent over the whole history. Equal to `frozenDays.length` by
  /// construction — one spend covers exactly one day.
  final int freezesSpent;

  /// Every day a freeze covered, as days since epoch.
  ///
  /// The whole history, not this week's: clipping is the strip's job, and the
  /// prototype conflated the two facts into one and silently refunded every
  /// spent freeze on each week rollover.
  final Set<int> frozenDays;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakStatus &&
          other.streak == streak &&
          other.freezeHeld == freezeHeld &&
          other.daysToNextFreeze == daysToNextFreeze &&
          other.freezesSpent == freezesSpent &&
          setEquals(other.frozenDays, frozenDays);

  @override
  int get hashCode => Object.hash(
    streak,
    freezeHeld,
    daysToNextFreeze,
    freezesSpent,
    Object.hashAllUnordered(frozenDays),
  );

  @override
  String toString() =>
      'StreakStatus(streak: $streak, freezeHeld: $freezeHeld, '
      'daysToNextFreeze: $daysToNextFreeze, freezesSpent: $freezesSpent)';
}
