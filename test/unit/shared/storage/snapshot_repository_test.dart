import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/snapshot_generators.dart';

/// The snapshot survives a restart, and nothing device-local moves with it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SnapshotRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    repo = SnapshotRepository();
  });

  tearDown(() async {
    await db.close();
  });

  test('a fresh install reads an empty snapshot rather than failing', () async {
    expect(await repo.read(), ProgressSnapshot.empty);
  });

  test('a written snapshot reads back identical', () async {
    const written = ProgressSnapshot(
      updatedAt: 1234,
      deviceId: 'phone',
      resetGeneration: 2,
      clearedByReset: ClearedByReset(
        completedLessons: {'m1l1': 4},
        bestResults: {'m1l1': MasteryResult(correct: 7, total: 8)},
        ownedCollectibles: {'c1'},
        treeStage: 3,
        favourites: Timestamped(
          value: {'l:m1l1'},
          updatedAt: 900,
          writerId: 'phone',
        ),
      ),
      clearedByDeleteOnly: ClearedByDeleteOnly(
        grove: Timestamped(
          value: Grove(variety: 'liberica', light: 'moonlit'),
          updatedAt: 800,
          writerId: 'phone',
        ),
      ),
    );

    await repo.write(written);

    expect(await repo.read(), written);
  });

  test('survives a restart, over generated snapshots', () async {
    for (var seed = 0; seed < 40; seed++) {
      final original = SnapshotGen(seed).snapshot();
      await repo.write(original);

      // Close and reopen against the same file-less executor is not available,
      // so re-read through a fresh repository — the row, not the object, is
      // what is being trusted here.
      expect(await SnapshotRepository().read(), original, reason: 'seed $seed');
    }
  });

  test(
    'a later write replaces the earlier one rather than adding a row',
    () async {
      await repo.write(ProgressSnapshot.empty);
      await repo.write(
        ProgressSnapshot.empty.copyWith(resetGeneration: 9, deviceId: 'phone'),
      );

      final rows = await db.select(db.progressSnapshots).get();

      expect(rows, hasLength(1));
      expect((await repo.read()).resetGeneration, 9);
    },
  );

  test(
    'a mangled payload reads as empty rather than bricking launch',
    () async {
      await db.customStatement(
        "INSERT INTO progress_snapshots (id, payload) VALUES (1, '{not json')",
      );

      expect(await repo.read(), ProgressSnapshot.empty);
    },
  );

  test('writing the snapshot leaves device-local settings untouched', () async {
    // "Not synced" and "not wiped" are two different properties, and the
    // settings row has both. A snapshot write must not reach it at all.
    final settings = SettingsRepository();
    final before = await settings.getSettings();

    await repo.write(SnapshotGen(1).snapshot());

    final after = await settings.getSettings();
    expect(after.themeMode, before.themeMode);
    expect(after.hapticsEnabled, before.hapticsEnabled);
    expect(after.soundEnabled, before.soundEnabled);
    expect(after.onboardingCompleted, before.onboardingCompleted);
  });
}
