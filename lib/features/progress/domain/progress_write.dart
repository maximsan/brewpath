/// The one way to change the progress scope of the snapshot.
library;

import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';

/// Reads the progress scope, applies [change], writes it back stamped at
/// [now], and returns what was written.
///
/// Every progress write is this shape — read, fold, stamp, write — and it was
/// spelled out at each call site, which is a read-modify-write to get subtly
/// wrong in a dozen places. Named once, a caller states only what changed.
///
/// **It returns the scope it wrote.** A caller that has to report what it just
/// recorded reads it off the result rather than asking the store a second
/// time, where Reset Progress could have landed in between.
///
/// Whole-value, like every snapshot write: the snapshot *is* the record, so
/// there is no partial write to reconcile.
Future<ClearedByReset> updateProgress(
  SnapshotRepository repository,
  ClearedByReset Function(ClearedByReset progress) change, {
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final next = change(snapshot.clearedByReset);
  await repository.write(
    snapshot.copyWith(
      updatedAt: now.millisecondsSinceEpoch,
      clearedByReset: next,
    ),
  );
  return next;
}
