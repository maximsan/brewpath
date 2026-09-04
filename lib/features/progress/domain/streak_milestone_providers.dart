import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_milestones.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'streak_milestone_providers.g.dart';

/// The acks-map key for the milestone celebration. The value is the day the
/// beat was presented; max-merge keeps the newest across devices.
const String milestoneAckKey = 'streakMilestone';

/// Whether the streak screen should open on the milestone beat now.
///
/// All watches happen before any await — the ack invalidation rebuilds this
/// mid-flight, and a watch on the far side of an async gap would find the old
/// build's ref already disposed.
@riverpod
Future<bool> streakMilestoneDue(Ref ref) async {
  final today = epochDay(ref.watch(currentDayProvider));
  final statusFuture = ref.watch(streakStatusProvider.future);
  final repository = ref.watch(snapshotRepositoryProvider);
  final status = await statusFuture;
  final snapshot = await repository.read();
  return milestoneCelebrationDue(
    streak: status.streak,
    ackedDay: snapshot.clearedByReset.acks[milestoneAckKey],
    today: today,
  );
}

/// Acknowledges today's milestone: presented, dated, never re-offered today.
///
/// Raise-only, so two racing presentations — or a peer's older day arriving
/// in a merge — cannot move the acknowledgement backwards.
Future<void> ackStreakMilestone(
  SnapshotRepository repository,
  DateTime now,
) async {
  final snapshot = await repository.read();
  final today = epochDay(now);
  final existing = snapshot.clearedByReset.acks[milestoneAckKey];
  if (existing != null && existing >= today) return;
  await repository.write(
    snapshot.copyWith(
      updatedAt: now.millisecondsSinceEpoch,
      clearedByReset: snapshot.clearedByReset.withAck(milestoneAckKey, today),
    ),
  );
}
