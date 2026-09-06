/// Seeding finished lessons the way a completion records them (#115).
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_write.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';

/// Records [lessonId] as first finished on [at], scoring [mastery].
///
/// The snapshot is the record, so a test that needs a learner partway through
/// the course writes here rather than into the old completions table — which
/// nothing reads any more, and which #116 drops.
///
/// It goes through the same writer and the same scope method the completion
/// service uses, so a seeded learner and a real one are the same shape: the
/// day is what the streak backfills from, and the result is what the Path
/// draws a band from.
Future<void> seedCompletedLesson(
  SnapshotRepository snapshots,
  String lessonId, {
  DateTime? at,
  MasteryResult mastery = const MasteryResult(correct: 5, total: 5),
}) async {
  final now = at ?? DateTime.now();
  await updateProgress(
    snapshots,
    (progress) => progress.withLessonCompleted(
      lessonId,
      day: epochDay(now),
      mastery: mastery,
    ),
    now: now,
  );
}

/// Records [cardId] as collected.
Future<void> seedCollectible(SnapshotRepository snapshots, String cardId) =>
    updateProgress(
      snapshots,
      (progress) => progress.withCollectible(cardId),
      now: DateTime.now(),
    );

/// Records every id in [lessonIds] as finished on [at].
Future<void> seedCompletedLessons(
  SnapshotRepository snapshots,
  Iterable<String> lessonIds, {
  DateTime? at,
  MasteryResult mastery = const MasteryResult(correct: 5, total: 5),
}) async {
  for (final lessonId in lessonIds) {
    await seedCompletedLesson(snapshots, lessonId, at: at, mastery: mastery);
  }
}
