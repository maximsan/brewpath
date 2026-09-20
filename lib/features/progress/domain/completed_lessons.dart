/// What the snapshot knows about the lessons a learner has finished.
library;

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:flutter/foundation.dart';

/// The finished lessons: when each was first run, when it was last run, and
/// the best result ever scored on it.
///
/// **The maps travel together** because every reader needs more than one side
/// of the same fact. Handing them out separately is how a screen ends up
/// showing a mastery band for a lesson it does not think is finished.
@immutable
class CompletedLessons {
  /// Creates a [CompletedLessons].
  const CompletedLessons({
    this.completedOn = const {},
    this.lastCompletedOn = const {},
    this.mastery = const {},
  });

  /// Lesson id → the day it was **first** finished, as days since epoch.
  final Map<String, int> completedOn;

  /// Lesson id → the day it was **last** finished, first run or replay.
  ///
  /// Absent for a lesson last finished before the day was recorded, which is
  /// why [lastRunDay] falls back to the first completion rather than to null.
  final Map<String, int> lastCompletedOn;

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

  /// The day [lessonId] was last finished, or null when it is not finished.
  ///
  /// The first completion stands in where no last run was recorded: for a
  /// lesson run once they are the same day, and a replay from before the
  /// field existed corrects itself on the next run.
  int? lastRunDay(String lessonId) =>
      lastCompletedOn[lessonId] ?? completedOn[lessonId];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedLessons &&
          mapEquals(other.completedOn, completedOn) &&
          mapEquals(other.lastCompletedOn, lastCompletedOn) &&
          mapEquals(other.mastery, mastery);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(completedOn.keys),
    Object.hashAllUnordered(lastCompletedOn.keys),
    Object.hashAllUnordered(mastery.keys),
  );
}
