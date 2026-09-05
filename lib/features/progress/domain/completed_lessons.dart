/// What the snapshot knows about the lessons a learner has finished.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter/foundation.dart';

/// The finished lessons, each with the day it was first completed on and the
/// best result ever scored on it.
///
/// **The two maps travel together** because every reader needs both sides of
/// the same fact: the Path draws a row's band from the result, the streak
/// backfills from the day, and the points total counts the lessons. Handing
/// them out separately is how a screen ends up showing a mastery band for a
/// lesson it does not think is finished.
///
/// It replaces a list of `ProgressRecord`s — rows of the old completions
/// table. Those rows also carried the points a completion paid; the snapshot
/// does not, because a lesson's payout is what the lesson authors, so the
/// total is summed from the course rather than from a stored copy of it.
@immutable
class CompletedLessons {
  /// Creates a [CompletedLessons].
  const CompletedLessons({this.completedOn = const {}, this.best = const {}});

  /// Lesson id → the day it was **first** finished, as days since epoch.
  final Map<String, int> completedOn;

  /// Lesson id → the best graded result stored for it.
  ///
  /// A lesson finished before results were stored has an entry here only if
  /// one was ever recorded, so a lookup can miss on a lesson that is
  /// genuinely complete — read it through [masteryOf], which answers
  /// [MasteryResult.unscored] rather than null.
  final Map<String, MasteryResult> best;

  /// The finished lessons' ids.
  Set<String> get ids => completedOn.keys.toSet();

  /// How many lessons are finished.
  int get count => completedOn.length;

  /// Whether none are.
  bool get isEmpty => completedOn.isEmpty;

  /// Whether any are.
  bool get isNotEmpty => completedOn.isNotEmpty;

  /// The days lessons were first finished on — what the streak backfills from.
  Iterable<int> get firstCompletionDays => completedOn.values;

  /// Whether [lessonId] is finished.
  bool contains(String lessonId) => completedOn.containsKey(lessonId);

  /// The best result stored for [lessonId], or [MasteryResult.unscored] when
  /// none is — which is what a lesson finished without a score reads as.
  MasteryResult masteryOf(String lessonId) =>
      best[lessonId] ?? MasteryResult.unscored;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedLessons &&
          mapEquals(other.completedOn, completedOn) &&
          mapEquals(other.best, best);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(completedOn.keys),
    Object.hashAllUnordered(best.keys),
  );
}
