/// The Profile rollup's fold over stored lesson results.
///
/// Pure, so the counts the card renders can be checked without a database or a
/// pump — and so the one place that decides what "solid" means is testable on
/// its own.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter/foundation.dart';

/// A course's scored lessons, split into the design's two states.
///
/// A class rather than a record so [scored] cannot disagree with its parts: it
/// is derived here, where a third stored field could have been passed a number
/// of its own. [total] rides along because every reader needs both — the bar
/// cannot size its empty tail without it, and separating them only invites a
/// caller to pair a rollup with someone else's course length.
@immutable
class MasteryRollup {
  /// Creates a [MasteryRollup].
  const MasteryRollup({
    required this.solid,
    required this.needsPractice,
    required this.completed,
    required this.total,
  });

  /// Lessons whose best run left at most one wrong answer.
  final int solid;

  /// Lessons whose best run left two or more.
  final int needsPractice;

  /// Lessons finished, scored or not.
  ///
  /// **Not [scored].** The design counts every finished lesson in its `DONE`
  /// line, and the hero above this card counts the same way — a card that
  /// counted only the scored ones would put two different totals for the same
  /// thing on one screen.
  final int completed;

  /// Lessons in the course, scored or not.
  final int total;

  /// Lessons holding a score at all, and so claiming a band.
  int get scored => solid + needsPractice;

  /// The unfilled part of the bar.
  ///
  /// Everything without a band: never started, and finished before scores were
  /// recorded. `mastery.dart` rules that the second kind "reads as unscored,
  /// which the design renders as a deliberately neutral empty node — never as
  /// a full one", so the two look alike here on purpose.
  ///
  /// Floored at zero: a content bank edited between runs can leave more played
  /// than the course now declares, and a negative flex on a `Spacer` throws.
  int get remainder => total - scored < 0 ? 0 : total - scored;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasteryRollup &&
          other.solid == solid &&
          other.needsPractice == needsPractice &&
          other.completed == completed &&
          other.total == total;

  @override
  int get hashCode => Object.hash(solid, needsPractice, completed, total);

  @override
  String toString() =>
      'MasteryRollup(solid: $solid, needsPractice: $needsPractice, '
      'completed: $completed, total: $total)';
}

/// Folds stored results into the rollup's two states.
///
/// **Two states, from three bands.** [MasteryBand.perfect] and
/// [MasteryBand.mastered] are both *solid*; only [MasteryBand.needsPractice]
/// is not. The design's rollup shows two colours, so Perfect is not a third
/// column — it is the best kind of solid.
///
/// A lesson with no stored score has no band and joins neither count. The bar
/// treats it the way it treats an unplayed one: empty track, not a segment.
MasteryRollup rollUpMastery(
  Iterable<MasteryResult> results, {
  required int total,
}) {
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

  return MasteryRollup(
    solid: solid,
    needsPractice: needsPractice,
    completed: results.length,
    total: total,
  );
}
