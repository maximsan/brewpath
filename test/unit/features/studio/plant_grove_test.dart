import 'package:brew_path/features/studio/domain/plant_grove.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Applying is the feature's only write. It rides the existing
/// last-writer-wins field, so what matters is that it stamps the value the
/// learner picked — and that it does nothing at all when nothing changed.
///
/// Driven through the real repository against an in-memory database, as every
/// other snapshot test is: a fake here would only prove the fake works.
void main() {
  late AppDatabase db;
  late SnapshotRepository snapshots;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    snapshots = SnapshotRepository();
  });

  tearDown(() async => db.close());

  final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  test('planting writes the picked grove, stamped', () async {
    await plantGrove(
      snapshots,
      grove: const Grove(variety: 'robusta', light: 'moonlit'),
      now: now,
    );

    final stored = (await snapshots.read()).clearedByDeleteOnly.grove;
    expect(stored.value, const Grove(variety: 'robusta', light: 'moonlit'));
    expect(stored.updatedAt, now.millisecondsSinceEpoch);
  });

  test('planting what is already planted does not move the stamp', () async {
    // Not an optimisation. An identical write moves the last-writer-wins
    // stamp, so it would beat a real change made on another device — costing
    // the learner a pick they actually made.
    await plantGrove(snapshots, grove: Grove.initial, now: now);

    final stamp = (await snapshots.read()).clearedByDeleteOnly.grove.updatedAt;
    expect(stamp, isNot(now.millisecondsSinceEpoch));
  });

  test('a second plant overwrites the first', () async {
    await plantGrove(
      snapshots,
      grove: const Grove(variety: 'robusta', light: 'moonlit'),
      now: now,
    );
    await plantGrove(
      snapshots,
      grove: const Grove(variety: 'liberica', light: 'frost'),
      now: now.add(const Duration(minutes: 1)),
    );

    final stored = (await snapshots.read()).clearedByDeleteOnly.grove;
    expect(stored.value, const Grove(variety: 'liberica', light: 'frost'));
  });
}
