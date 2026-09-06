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
  const CompletedLessons({
    this.completedOn = const {},
    this.mastery = const {},
  });

  /// Lesson id → the day it was **first** finished, as days since epoch.
  final Map<String, int> completedOn;

  /// Lesson id → its mastery, the best `{correct, total}` pair ever scored.
  ///
  /// A lesson finished without a stored score is **absent here while present
  /// in [completedOn]** — the two maps are not the same key set, and a reader
  /// that assumes they are will report a lesson as unfinished for want of a
  /// score it never had.
  final Map<String, MasteryResult> mastery;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedLessons &&
          mapEquals(other.completedOn, completedOn) &&
          mapEquals(other.mastery, mastery);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(completedOn.keys),
    Object.hashAllUnordered(mastery.keys),
  );
}
