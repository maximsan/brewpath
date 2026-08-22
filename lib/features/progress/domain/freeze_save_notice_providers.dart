import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/progress/domain/freeze_save_notice.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'freeze_save_notice_providers.g.dart';

/// The covered day the Learn-tab save notice should announce, or null.
///
/// All watches happen before any await — a rebuild triggered mid-flight (the
/// dismiss invalidation does exactly this) must not find a watch on the far
/// side of an async gap.
@riverpod
Future<int?> freezeSaveNoticeDay(Ref ref) async {
  final statusFuture = ref.watch(streakStatusProvider.future);
  final daysFuture = ref.watch(activeDaySetProvider.future);
  final repository = ref.watch(snapshotRepositoryProvider);
  final status = await statusFuture;
  final activeDays = await daysFuture;
  final snapshot = await repository.read();
  return dueFreezeSaveDay(
    activeDays: activeDays,
    status: status,
    ackedDay: snapshot.clearedByReset.acks[freezeSaveAckKey],
    today: epochDay(DateTime.now()),
  );
}

/// Acknowledges the save notice for [coveredDay]: dismissed, never re-shown.
///
/// The stored value is the covered day itself, raise-only, so two racing
/// dismissals — or a peer's older acknowledgement arriving in a merge — can
/// never resurrect a notice the learner already closed.
Future<void> ackFreezeSave(
  SnapshotRepository repository,
  int coveredDay,
  DateTime now,
) async {
  final snapshot = await repository.read();
  final existing = snapshot.clearedByReset.acks[freezeSaveAckKey];
  if (existing != null && existing >= coveredDay) return;
  await repository.write(
    snapshot.copyWith(
      updatedAt: now.millisecondsSinceEpoch,
      clearedByReset: snapshot.clearedByReset.withAck(
        freezeSaveAckKey,
        coveredDay,
      ),
    ),
  );
}
