import 'dart:convert';

import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/snapshot_generators.dart';

/// The snapshot is stored as one JSON blob and published as one key, so
/// encoding is not a detail — a field that fails to round-trip is data the
/// learner silently loses on the next launch.
void main() {
  test('round-trips through JSON unchanged, over generated snapshots', () {
    for (var seed = 0; seed < 200; seed++) {
      final original = SnapshotGen(seed).snapshot();

      // Through a real string, not just the intermediate map, so anything that
      // only survives as a Dart object is caught.
      final decoded = ProgressSnapshot.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );

      expect(decoded, original, reason: 'seed $seed');
    }
  });

  test('an absent field decodes as empty rather than throwing', () {
    // An older build's payload simply lacks the keys added since. It has to
    // read as the zero value, not as a crash on launch.
    final sparse = ProgressSnapshot.fromJson(const {'version': 1});

    expect(sparse.clearedByReset, ClearedByReset.empty);
    expect(sparse.clearedByDeleteOnly, ClearedByDeleteOnly.empty);
    expect(sparse.resetGeneration, 0);
  });

  test('a malformed field decodes as empty rather than throwing', () {
    // The store is a plain key-value blob with no schema enforcement, so a
    // truncated or hand-mangled payload must degrade rather than brick launch.
    final malformed = ProgressSnapshot.fromJson(const {
      'version': 1,
      'clearedByReset': 'not an object',
      'clearedByDeleteOnly': 42,
    });

    expect(malformed.clearedByReset, ClearedByReset.empty);
    expect(malformed.clearedByDeleteOnly, ClearedByDeleteOnly.empty);
  });

  test('the empty snapshot is what a tombstone carries', () {
    // Reset and Delete publish an empty snapshot at generation + 1 rather than
    // deleting the key: a key that simply vanished reads as absence on the
    // other device, which re-publishes its copy and walks the data back.
    final tombstone = ProgressSnapshot.empty.copyWith(
      resetGeneration: 4,
      deviceId: 'phone',
      updatedAt: 123,
    );

    expect(tombstone.clearedByReset, ClearedByReset.empty);
    expect(tombstone.clearedByDeleteOnly, ClearedByDeleteOnly.empty);
    expect(tombstone.resetGeneration, 4);
  });
}
