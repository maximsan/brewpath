import 'package:brew_path/features/companion/application/companion_outfit.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/studio/domain/dress_companion.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The one place that decides what Roasty wears. The gate is the point: a free
// learner sees the plain mascot everywhere, whatever the snapshot holds — a
// lapsed subscriber must not keep the wardrobe.
const _dressed = CompanionConfig(
  roast: 'dark',
  hat: 'beanie',
  gear: 'scarf',
  sprout: 'flower',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository snapshots;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    snapshots = SnapshotRepository();
  });
  tearDown(() async => db.close());

  Future<CompanionConfig> outfitFor({required bool entitled}) async {
    final container = ProviderContainer(
      overrides: [
        courseEntitlementProvider.overrideWith((ref) async => entitled),
      ],
    );
    addTearDown(container.dispose);
    return container.read(companionOutfitProvider.future);
  }

  test('a learner who has dressed Roasty and paid sees the outfit', () async {
    await dressCompanion(snapshots, outfit: _dressed, now: DateTime.now());

    expect(await outfitFor(entitled: true), _dressed);
  });

  test(
    'the same learner without the entitlement sees the plain bean',
    () async {
      await dressCompanion(snapshots, outfit: _dressed, now: DateTime.now());

      expect(await outfitFor(entitled: false), CompanionConfig.initial);
    },
  );

  test(
    'the stored outfit survives the gate — it is hidden, not wiped',
    () async {
      await dressCompanion(snapshots, outfit: _dressed, now: DateTime.now());
      await outfitFor(entitled: false);

      final stored = (await snapshots.read()).clearedByDeleteOnly.companion;
      expect(stored.value, _dressed);
    },
  );

  test(
    'an undressed learner with the entitlement sees the plain bean',
    () async {
      expect(await outfitFor(entitled: true), CompanionConfig.initial);
    },
  );
}
