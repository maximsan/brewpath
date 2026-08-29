/// The Profile rollup's fold over stored lesson results.
///
/// Pure, so the counts the card renders can be checked without a database or a
/// pump — and so the one place that decides what "solid" means is testable on
/// its own.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';

/// Scored lessons split into the design's two states, plus the total scored.
///
/// `solid` and `needsPractice` always sum to `scored`: every scored lesson
/// lands in exactly one, and an unscored one lands in neither.
typedef MasteryRollup = ({int solid, int needsPractice, int scored});

/// Folds stored results into the rollup's two states.
///
/// **Two states, from three bands.** [MasteryBand.perfect] and
/// [MasteryBand.mastered] are both *solid*; only [MasteryBand.needsPractice]
/// is not. The design's rollup shows two colours, so Perfect is not a third
/// column — it is the best kind of solid.
///
/// A lesson with no stored score has no band and joins neither count. The bar
/// treats it the way it treats an unplayed lesson: empty track, not a segment.
MasteryRollup rollUpMastery(Iterable<MasteryResult> results) {
  var solid = 0;
  var needsPractice = 0;

  for (final result in results) {
    switch (result.band) {
      case null:
        continue;
      case MasteryBand.needsPractice:
        needsPractice++;
      case MasteryBand.mastered:
      case MasteryBand.perfect:
        solid++;
    }
  }

  return (
    solid: solid,
    needsPractice: needsPractice,
    scored: solid + needsPractice,
  );
}

/// How much of a whole course this rollup has not scored yet.
extension MasteryRollupBar on MasteryRollup {
  /// The empty tail of the bar, floored at zero — `total - scored`.
  ///
  /// A content bank edited between runs can leave more lessons played than the
  /// course now declares. Flooring here keeps that out of the layout, where a
  /// negative flex on a `Spacer` throws.
  int remainderOf(int total) {
    final remainder = total - scored;
    return remainder < 0 ? 0 : remainder;
  }
}
