import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';

/// Plants [grove], and nothing else.
///
/// A read-modify-write over the whole snapshot, as every other progress write
/// is — the snapshot **is** the record, so there is no partial write to get
/// wrong.
///
/// **A no-change plant writes nothing.** Not an optimisation: the grove is
/// last-writer-wins, so an identical write would move the stamp and beat a
/// real pick made on another device. The screen already disables its confirm
/// when the draft matches, and this is the same rule where it cannot be
/// bypassed.
Future<void> plantGrove(
  SnapshotRepository repository, {
  required Grove grove,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  if (snapshot.clearedByDeleteOnly.grove.value == grove) return;

  final at = now.millisecondsSinceEpoch;
  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByDeleteOnly: snapshot.clearedByDeleteOnly.withGrove(
        grove,
        at: at,
        writerId: snapshot.deviceId,
      ),
    ),
  );
}
