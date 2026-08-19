import 'package:flutter_test/flutter_test.dart';

import '../../../../support/snapshot_generators.dart';

/// A guard on the fixture the merge laws are proved with.
///
/// The laws only say something if two generated snapshots actually overlap:
/// union, max and last-writer-wins are all trivially satisfied by values that
/// never meet. Ids and days are drawn from tiny pools for that reason, and
/// activity entries have to be drawn the same way — minting real tokens would
/// make every entry globally unique and quietly hollow out the property tests
/// over that field.
void main() {
  test('two generated snapshots collide on daily-activity entries', () {
    var collisions = 0;
    for (var seed = 0; seed < 40; seed++) {
      final mine = SnapshotGen(seed).progress().dailyActivity;
      final theirs = SnapshotGen(seed + 1).progress().dailyActivity;
      for (final day in mine.keys) {
        final shared = mine[day]!.intersection(theirs[day] ?? const {});
        collisions += shared.length;
      }
    }

    expect(collisions, greaterThan(0));
  });

  test('the same seed still generates the same snapshot', () {
    expect(SnapshotGen(7).progress(), SnapshotGen(7).progress());
  });
}
