import 'package:brew_path/shared/storage/snapshot/merge_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/snapshot_generators.dart';

/// The three laws that *are* convergence.
///
/// The design's whole safety claim is that merging is a lattice join, and that
/// claim is exactly these: idempotent, commutative, associative. Together they
/// mean two devices reach the same state regardless of which synced first, how
/// often a payload was redelivered, or how the merges were grouped — which is
/// what makes a key-value store whose writes are *not durable* survivable.
///
/// Hand-picked examples cannot establish this; they can only fail to disprove
/// it. So these run over generated snapshots with deliberately colliding ids,
/// days and timestamps.
void main() {
  const runs = 400;

  group('mergeSnapshot is a lattice join', () {
    test('is idempotent — merging a snapshot with itself changes nothing', () {
      for (var seed = 0; seed < runs; seed++) {
        final a = SnapshotGen(seed).snapshot();
        expect(
          mergeSnapshot(a, a),
          a,
          reason: 'seed $seed: merge(a, a) must equal a',
        );
      }
    });

    test('is commutative — whichever device syncs first, same answer', () {
      for (var seed = 0; seed < runs; seed++) {
        final gen = SnapshotGen(seed);
        final a = gen.snapshot();
        final b = gen.snapshot();
        expect(
          mergeSnapshot(a, b),
          mergeSnapshot(b, a),
          reason: 'seed $seed: merge order must not matter',
        );
      }
    });

    test('is associative — grouping does not matter', () {
      for (var seed = 0; seed < runs; seed++) {
        final gen = SnapshotGen(seed);
        final a = gen.snapshot();
        final b = gen.snapshot();
        final c = gen.snapshot();
        expect(
          mergeSnapshot(mergeSnapshot(a, b), c),
          mergeSnapshot(a, mergeSnapshot(b, c)),
          reason: 'seed $seed: merge grouping must not matter',
        );
      }
    });

    test('re-merging a result with either input changes nothing', () {
      // Redelivery is normal: a device re-reads and re-merges a payload it has
      // already absorbed. If that moved the state, the two devices would chase
      // each other forever.
      for (var seed = 0; seed < runs; seed++) {
        final gen = SnapshotGen(seed);
        final a = gen.snapshot();
        final b = gen.snapshot();
        final merged = mergeSnapshot(a, b);
        expect(
          mergeSnapshot(merged, a),
          merged,
          reason: 'seed $seed: re-merge a',
        );
        expect(
          mergeSnapshot(merged, b),
          merged,
          reason: 'seed $seed: re-merge b',
        );
      }
    });
  });
}
