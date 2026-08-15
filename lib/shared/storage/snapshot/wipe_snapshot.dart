import 'dart:math';

import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';

/// The snapshot **Reset Progress** publishes.
///
/// Every progress-scoped field is cleared **explicitly**, rather than left to
/// recalculate from an emptied lesson list. That worked while nothing was
/// stored and stops working the moment the snapshot is the record: a stored
/// tree stage, a stored best result and a stored collectible set are outcomes,
/// not derivations, and nothing recomputes them back down.
///
/// The grove, the companion and every account-scoped key survive — "reset
/// everything" means the trail, not the wardrobe.
ProgressSnapshot resetTombstone(
  ProgressSnapshot current, {
  required int at,
  required String deviceId,
}) => _tombstone(
  current,
  at: at,
  deviceId: deviceId,
  account: current.clearedByDeleteOnly,
);

/// The snapshot **Delete Account** publishes — the same mechanism at full
/// scope.
///
/// The account scope is cleared *and stamped to win*, which is the part that
/// makes deletion true on the other device rather than only on this one.
/// Account fields merge last-writer-wins rather than by generation, so a
/// tombstone that does not out-stamp what is already stored loses to the very
/// grove it was published to erase — see
/// [ClearedByDeleteOnly.clearedAfter] for how the stamp is chosen.
///
/// One thing this cannot reach: an *account-scoped key written by a newer
/// build*. It is dropped here, but the merge resolves unknown keys by comparing
/// the values themselves rather than by generation or by stamp, so a peer still
/// holding one re-attaches it. Fixing that needs a stamp inside a value this
/// build cannot interpret, which is not available.
ProgressSnapshot deleteTombstone(
  ProgressSnapshot current, {
  required int at,
  required String deviceId,
}) => _tombstone(
  current,
  at: at,
  deviceId: deviceId,
  account: ClearedByDeleteOnly.clearedAfter(
    current.clearedByDeleteOnly,
    at: at,
    deviceId: deviceId,
  ),
);

/// The shape both wipes share: an empty progress scope at generation + 1.
///
/// **Neither wipe deletes the stored key.** A key that simply vanished reads on
/// the second device as *absence* — a fresh install — so it would re-publish
/// its full copy and walk the deleted data straight back. An empty snapshot at
/// a higher generation is the opposite: the peer sees the higher generation,
/// discards its own progress and adopts it.
///
/// What is left holds nothing personal. The envelope keeps only the version,
/// the moment, the writing device and the generation — plus any envelope key a
/// newer build wrote, which rides along because those are not progress, the
/// merge never resolves them by generation, and dropping them would destroy a
/// newer build's data for no gain.
ProgressSnapshot _tombstone(
  ProgressSnapshot current, {
  required int at,
  required String deviceId,
  required ClearedByDeleteOnly account,
}) => ProgressSnapshot(
  // Never written lower than the highest ever read, exactly as the merge holds
  // it: a newer build wrote the stored snapshot, and a wipe is no reason to
  // walk the envelope backwards.
  version: max(current.version, ProgressSnapshot.currentVersion),
  updatedAt: at,
  deviceId: deviceId,
  resetGeneration: current.resetGeneration + 1,
  // The one assignment that clears the whole progress scope, including the keys
  // a newer build added inside it. A field-by-field wipe is what shipped the
  // prototype's defect, by omitting exactly one key.
  // Stated rather than left to the default it matches, because a reader must
  // see the wipe: an omission here would look identical to forgetting one.
  // ignore: avoid_redundant_argument_values
  clearedByReset: ClearedByReset.empty,
  clearedByDeleteOnly: account,
  unknown: current.unknown,
);
