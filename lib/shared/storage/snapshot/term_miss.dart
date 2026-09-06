import 'dart:math';

import 'package:flutter/foundation.dart';

/// How a learner has answered one dictionary term, as the two moments that
/// decide whether it is still owed a review.
///
/// In its own file rather than beside the snapshot's other value types: it is
/// the only one carrying a merge rule of its own, and the rule is the reason
/// the type exists at all.
///
/// **Not a set of missed ids.** A set with removals cannot merge — a term
/// cleared on the phone comes straight back from the tablet that still holds
/// it, forever. Two stamps merged by [TermMiss.later] converge on whichever
/// event actually happened last, from either device, in any arrival order.
///
/// Milliseconds rather than days, because miss-then-correct inside one sitting
/// is the normal way a term leaves the deck and a day number cannot order it.
@immutable
class TermMiss {
  /// Creates a [TermMiss].
  const TermMiss({this.lastMissedAt = 0, this.lastCorrectAt = 0});

  /// Builds one from its JSON form.
  factory TermMiss.fromJson(Map<String, dynamic> json) => TermMiss(
    lastMissedAt: json['lastMissedAt'] as int? ?? 0,
    lastCorrectAt: json['lastCorrectAt'] as int? ?? 0,
  );

  /// The join of two records for the same term.
  ///
  /// Per-stamp `max`, which is idempotent, commutative and associative — so
  /// the whole snapshot's merge laws still hold — and which resolves the two
  /// devices onto whichever of the four events was genuinely latest.
  factory TermMiss.later(TermMiss a, TermMiss b) => TermMiss(
    lastMissedAt: max(a.lastMissedAt, b.lastMissedAt),
    lastCorrectAt: max(a.lastCorrectAt, b.lastCorrectAt),
  );

  /// A term nobody has answered either way.
  static const none = TermMiss();

  /// When the learner last got this term wrong, in milliseconds since epoch.
  final int lastMissedAt;

  /// When they last got it right.
  final int lastCorrectAt;

  /// Whether the term is owed a review: missed more recently than corrected.
  ///
  /// A tie clears it. Two answers landing in the same millisecond is only
  /// reachable across devices, and leaving a term the learner has just got
  /// right in their review deck is the worse of the two ways to be wrong.
  bool get isMissed => lastMissedAt > lastCorrectAt;

  /// This record with the answer given at [at] folded in.
  ///
  /// Raise-only on both stamps, so it stays monotonic like every other field
  /// in its scope: an out-of-order clock cannot walk a stamp backwards.
  TermMiss answered({required bool correct, required int at}) => TermMiss(
    lastMissedAt: correct ? lastMissedAt : max(lastMissedAt, at),
    lastCorrectAt: correct ? max(lastCorrectAt, at) : lastCorrectAt,
  );

  /// This record's JSON form.
  Map<String, dynamic> toJson() => {
    'lastMissedAt': lastMissedAt,
    'lastCorrectAt': lastCorrectAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermMiss &&
          other.lastMissedAt == lastMissedAt &&
          other.lastCorrectAt == lastCorrectAt;

  @override
  int get hashCode => Object.hash(lastMissedAt, lastCorrectAt);

  @override
  String toString() => 'TermMiss(missed $lastMissedAt, correct $lastCorrectAt)';
}
