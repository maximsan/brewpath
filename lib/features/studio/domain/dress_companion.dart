import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';

/// Dresses Roasty in [outfit], and nothing else.
///
/// `plantGrove`'s twin, down to the no-op: the outfit is last-writer-wins, so
/// an identical write would move the stamp and beat a real pick made on
/// another device. The screen already disables its confirm when the draft
/// matches, and this is the same rule where it cannot be bypassed.
Future<void> dressCompanion(
  SnapshotRepository repository, {
  required CompanionConfig outfit,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  if (snapshot.clearedByDeleteOnly.companion.value == outfit) return;

  final at = now.millisecondsSinceEpoch;
  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByDeleteOnly: snapshot.clearedByDeleteOnly.withCompanion(
        outfit,
        at: at,
        writerId: snapshot.deviceId,
      ),
    ),
  );
}
