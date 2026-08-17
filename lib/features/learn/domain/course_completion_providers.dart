import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/learn/domain/course_completion.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_completion_providers.g.dart';

/// Whether the completion moment has already been acknowledged — one key in
/// the snapshot's `acks` map, cleared only by Reset Progress.
@riverpod
Future<bool> courseCompletionAcked(Ref ref) async {
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();
  return snapshot.clearedByReset.hasAck(courseCompleteAckKey);
}

/// Whether the router should present the completion moment now: the course
/// derives as complete (no lesson anywhere is current), something was
/// actually completed, and the moment has not been acknowledged.
@riverpod
Future<bool> courseCompletionDue(Ref ref) async {
  // All watches happen before any await: a rebuild triggered mid-flight (the
  // ack invalidation does exactly this) must not find a watch on the far
  // side of an async gap, where the old build's ref is already disposed.
  final todayFuture = ref.watch(todayLessonProvider.future);
  final completedFuture = ref.watch(completedLessonsProvider.future);
  final ackedFuture = ref.watch(courseCompletionAckedProvider.future);
  final today = await todayFuture;
  final completed = await completedFuture;
  final acked = await ackedFuture;
  return courseCompletionMomentDue(
    caughtUp: today == null,
    hasCompletedLessons: completed.isNotEmpty,
    acked: acked,
  );
}

/// Writes the completion ack: the moment has been shown, dated today. A
/// no-op when already acked, so two racing callers cannot move the day.
Future<void> ackCourseCompletion(
  SnapshotRepository repository,
  DateTime now,
) async {
  final snapshot = await repository.read();
  if (snapshot.clearedByReset.hasAck(courseCompleteAckKey)) return;
  await repository.write(
    snapshot.copyWith(
      updatedAt: now.millisecondsSinceEpoch,
      clearedByReset: snapshot.clearedByReset.withAck(
        courseCompleteAckKey,
        epochDay(now),
      ),
    ),
  );
}
