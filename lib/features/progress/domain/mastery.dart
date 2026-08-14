/// A lesson's graded result, and the mastery band it earns.
///
/// No storage and no widgets, so every rule below is unit-testable without a
/// database or a pump. The one import is `foundation` for `@immutable`, which
/// is how the theme-token files reach it too.
library;

import 'package:flutter/foundation.dart';

/// The three mastery states a scored lesson can hold.
///
/// The keys, labels and ordering come from the design's `LESSON_STATES`
/// (`brew-path/data.jsx`); only the *derivation* differs — see
/// [MasteryResult.band].
enum MasteryBand {
  /// Two or more wrong answers.
  needsPractice(rank: 0, label: 'Needs practice'),

  /// Exactly one wrong answer. The design calls this "Solid".
  mastered(rank: 1, label: 'Solid'),

  /// A clean run.
  perfect(rank: 2, label: 'Perfect');

  const MasteryBand({required this.rank, required this.label});

  /// Ordering, so callers can compare bands and never downgrade one.
  final int rank;

  /// User-facing name.
  final String label;
}

/// One lesson's best graded result, stored as the **pair** `{correct, total}`
/// rather than a percentage.
///
/// Both halves are load-bearing and neither can be recovered from a single
/// number: the band derives from [wrong], while the node gauge fills to
/// [ratio]. The app's previous `bestScore` percentage column could express
/// neither, and was not convertible — it measured first-try accuracy across
/// *all* steps with unlimited retries, where grading is one-shot.
///
/// [best] returns a result rather than mutating one, so a stored pair is only
/// ever replaced, never edited underneath a holder.
@immutable
class MasteryResult {
  /// Creates a [MasteryResult]. [correct] is clamped into `0..total` and a
  /// negative [total] is floored at zero, so no arithmetic below can see a
  /// nonsensical pair.
  const MasteryResult({required int correct, required int total})
    : total = total < 0 ? 0 : total,
      correct = correct < 0
          ? 0
          : (correct > total ? (total < 0 ? 0 : total) : correct);

  /// The unscored pair — a lesson finished without a stored result.
  static const unscored = MasteryResult(correct: 0, total: 0);

  /// Graded cards answered right on the one attempt available.
  final int correct;

  /// Graded cards in the run. Zero means the lesson holds no score.
  final int total;

  /// Whether a real result is stored.
  ///
  /// A lesson completed before scores were recorded reads as unscored, which
  /// the design renders as a deliberately neutral empty node — never as a full
  /// one. "Only a lesson with a stored score can claim mastery."
  bool get isScored => total > 0;

  /// Graded cards answered wrong. The band's only input.
  int get wrong => total - correct;

  /// Fill ratio for the node gauge, in `0..1`.
  double get ratio => total == 0 ? 0 : correct / total;

  /// The band this result earns, or null when nothing is stored.
  ///
  /// **Bands on wrong answers, never on a percentage.** The design's
  /// `MASTERY_PASS = 0.8` is unreachable in 14 of 31 lessons: graded-card
  /// counts run 3–7, and at 3 or 4 cards no score lands in 80–99%, so a single
  /// mistake drops the learner from Perfect straight to Needs Practice. Wrong-
  /// answer bands are denominator-independent by construction, so they cannot
  /// silently re-break when a lesson's card mix changes.
  MasteryBand? get band => switch (this) {
    _ when !isScored => null,
    _ when wrong == 0 => MasteryBand.perfect,
    _ when wrong == 1 => MasteryBand.mastered,
    _ => MasteryBand.needsPractice,
  };

  /// The better of two results, for the never-downgrade rule.
  ///
  /// **Band rank first, [ratio] second, [correct] third.** A scored result
  /// always beats an unscored one.
  ///
  /// Ratio alone downgrades across changing denominators: `{18,20}` is 90% but
  /// two wrong (Needs Practice), while `{4,5}` is 80% but one wrong (Solid) —
  /// comparing ratios would pick the worse badge.
  ///
  /// **Band, then ratio, then fewer [wrong], then larger [total] — and all four
  /// are needed to make this a total order.**
  ///
  /// This is the comparator a two-device merge runs, so a tie it cannot break
  /// is not a cosmetic wobble: each device keeps its own pair and the field
  /// never converges. Two keys are not enough, because
  /// [MasteryBand.needsPractice] lumps every wrong count from two upward:
  ///
  /// - `{2,4}` and `{3,6}` share a band *and* a ratio of 0.50
  /// - `{0,2}` and `{0,7}` share a band, a ratio of 0.00 *and* a [correct] of 0
  ///
  /// **Fewer wrong wins**, because the band is itself defined on the wrong
  /// count — ordering within a band on the same axis keeps the two consistent,
  /// where "more correct" would rank `{3,6}` above `{2,4}` despite it holding
  /// one more mistake. [total] settles the last case, `{3,3}` against `{5,5}`:
  /// equally flawless, so the longer run is the better result.
  static MasteryResult best(MasteryResult a, MasteryResult b) {
    if (!a.isScored) return b;
    if (!b.isScored) return a;
    final byBand = a.band!.rank.compareTo(b.band!.rank);
    if (byBand != 0) return byBand > 0 ? a : b;
    final byRatio = a.ratio.compareTo(b.ratio);
    if (byRatio != 0) return byRatio > 0 ? a : b;
    final byWrong = b.wrong.compareTo(a.wrong);
    if (byWrong != 0) return byWrong > 0 ? a : b;
    return a.total >= b.total ? a : b;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasteryResult &&
          other.correct == correct &&
          other.total == total;

  @override
  int get hashCode => Object.hash(correct, total);

  @override
  String toString() => 'MasteryResult($correct/$total)';
}
