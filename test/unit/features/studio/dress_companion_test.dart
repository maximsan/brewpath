import 'package:brew_path/features/studio/domain/dress_companion.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// The Roasty section's only write. It rides the same last-writer-wins field
// the grove does, so what matters is that it stamps what the learner picked,
// leaves the grove alone, and writes nothing at all when nothing changed.
const _dressed = CompanionConfig(
  roast: 'dark',
  hat: 'beanie',
  gear: 'scarf',
  sprout: 'flower',
);

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

  test('dressing writes the picked outfit, stamped', () async {
    await dressCompanion(snapshots, outfit: _dressed, now: now);

    final stored = (await snapshots.read()).clearedByDeleteOnly.companion;
    expect(stored.value, _dressed);
    expect(stored.updatedAt, now.millisecondsSinceEpoch);
  });

  test('dressing in what is already worn does not move the stamp', () async {
    // An identical write moves the last-writer-wins stamp, so it would beat a
    // real change made on another device.
    await dressCompanion(
      snapshots,
      outfit: CompanionConfig.initial,
      now: now,
    );

    final stored = (await snapshots.read()).clearedByDeleteOnly.companion;
    expect(stored.updatedAt, isNot(now.millisecondsSinceEpoch));
  });

  test('a second change overwrites the first', () async {
    await dressCompanion(snapshots, outfit: _dressed, now: now);
    await dressCompanion(
      snapshots,
      outfit: const CompanionConfig(
        roast: 'light',
        hat: 'none',
        gear: 'none',
        sprout: 'leaf',
      ),
      now: now.add(const Duration(minutes: 1)),
    );

    final stored = (await snapshots.read()).clearedByDeleteOnly.companion;
    expect(stored.value.roast, 'light');
    expect(stored.value.hat, 'none');
  });

  test('dressing leaves the grove exactly where it was', () async {
    // The two live in one scope, so a writer that rebuilt the scope carelessly
    // would silently replant.
    const planted = Grove(variety: 'robusta', light: 'moonlit');
    final before = await snapshots.read();
    await snapshots.write(
      before.copyWith(
        clearedByDeleteOnly: before.clearedByDeleteOnly.withGrove(
          planted,
          at: now.millisecondsSinceEpoch,
          writerId: before.deviceId,
        ),
      ),
    );

    await dressCompanion(
      snapshots,
      outfit: _dressed,
      now: now.add(const Duration(minutes: 1)),
    );

    final stored = (await snapshots.read()).clearedByDeleteOnly;
    expect(stored.grove.value, planted);
    expect(stored.companion.value, _dressed);
  });
}
