import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/install_repository.dart';
import 'package:brew_path/shared/repositories/module_progress_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/account_wipe.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/settings_record.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';
import 'package:brew_path/shared/theme/app_theme_mode.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The two wipes as the app performs them: read, tombstone, write — plus the
/// stores each one owns.
const _wipedAt = 7000;
const _thisDevice = 'phone';

/// A learner mid-course: progress in the snapshot, a customised grove, and
/// device-local preferences they never asked to lose.
const _stored = ProgressSnapshot(
  updatedAt: 100,
  deviceId: 'phone',
  resetGeneration: 3,
  clearedByReset: ClearedByReset(
    completedLessons: {'m1l1': 3},
    bestResults: {'m1l1': MasteryResult(correct: 5, total: 8)},
    activeDays: {1, 2, 3},
    ownedCollectibles: {'c1'},
    treeStage: 4,
  ),
  clearedByDeleteOnly: ClearedByDeleteOnly(
    grove: Timestamped(
      value: Grove(variety: 'liberica', light: 'moonlit'),
      updatedAt: 5000,
      writerId: 'phone',
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AccountWipe wipe;
  late SnapshotRepository snapshots;
  late SettingsRepository settings;
  late ProgressRepository lessons;
  late ModuleProgressRepository modules;
  late CardRepository cards;
  late InstallRepository install;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
    snapshots = SnapshotRepository();
    settings = SettingsRepository();
    lessons = ProgressRepository();
    modules = ModuleProgressRepository();
    cards = CardRepository();
    install = InstallRepository();
    wipe = AccountWipe(deviceId: _thisDevice, clock: () => _wipedAt);

    await snapshots.write(_stored);
    await lessons.saveCompletion(
      lessonId: 'm1l1',
      xpEarned: 10,
      mastery: const MasteryResult(correct: 5, total: 8),
    );
    await modules.markModuleXpAwarded('m1');
    await cards.collectCard('c1');
    await settings.saveSettings(
      UserSettingsRecord(
        hapticsEnabled: false,
        soundEnabled: false,
        totalXp: 50,
        onboardingCompleted: true,
        onboardingGoal: 'brew_better',
        onboardingBrewer: 'v60',
        themeMode: AppThemeMode.light,
        tourSeen: true,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Reset Progress', () {
    test('publishes an empty snapshot at the next generation', () async {
      await wipe.resetProgress();

      final published = await snapshots.read();
      expect(published.resetGeneration, _stored.resetGeneration + 1);
      expect(published.clearedByReset, ClearedByReset.empty);
      expect(published.updatedAt, _wipedAt);
      expect(published.deviceId, _thisDevice);
    });

    test('keeps the grove the learner chose', () async {
      await wipe.resetProgress();

      final published = await snapshots.read();
      expect(published.clearedByDeleteOnly, _stored.clearedByDeleteOnly);
    });

    test('publishes generation 1 on a device with nothing stored', () async {
      await db.delete(db.progressSnapshots).go();

      await wipe.resetProgress();

      expect((await snapshots.read()).resetGeneration, 1);
    });

    test('leaves every device-local preference alone', () async {
      // "Not synced" and "not wiped" are different properties, and these have
      // both. The appearance preference is the one a learner would notice.
      await wipe.resetProgress();

      final after = await settings.getSettings();
      expect(after.themeMode, AppThemeMode.light);
      expect(after.hapticsEnabled, false);
      expect(after.soundEnabled, false);
      expect(after.onboardingCompleted, true);
      expect(after.onboardingGoal, 'brew_better');
      expect(after.onboardingBrewer, 'v60');
      expect(after.tourSeen, true);
    });

    test('keeps the two already-introduced bits together', () async {
      // `tourSeen` fate-shares with `onboardingCompleted`, and a reset is the
      // wipe that keeps both. Asserted as a pair, not as two independent
      // facts, because the failure worth catching is one of them moving alone.
      await wipe.resetProgress();

      final after = await settings.getSettings();
      expect(after.onboardingCompleted, true);
      expect(after.tourSeen, true);
    });

    test('leaves the day the learner joined where it was', () async {
      // Starting the course over does not change when you started using the
      // app, so the closing line must read the same month afterwards.
      final before = await install.installedAt();

      await wipe.resetProgress();

      expect(await install.installedAt(), before);
    });

    test('leaves the settings row alone entirely', () async {
      // There is nothing left on it for a reset to zero: the streak derives
      // from the day set this wipe empties, and the points total from the
      // completions it clears. What remains is what the learner chose, and the
      // preference test above is what guards it.
      final before = await settings.getSettings();

      await wipe.resetProgress();

      final after = await settings.getSettings();
      expect(after.totalXp, before.totalXp);
      expect(after.themeMode, before.themeMode);
      expect(after.onboardingCompleted, before.onboardingCompleted);
    });

    test('clears the tables the snapshot has not replaced yet', () async {
      await wipe.resetProgress();

      expect(await lessons.getAllCompleted(), isEmpty);
      expect(await modules.isModuleXpAwarded('m1'), false);
      expect(await cards.getAllCollectedCardIds(), isEmpty);
    });
  });

  group('Delete Account', () {
    test('publishes a tombstone rather than removing the stored row', () async {
      // A row that simply vanished reads as absence on the second device — a
      // fresh install — which re-publishes its copy and undoes the deletion.
      await wipe.deleteAccount();

      expect(await db.select(db.progressSnapshots).get(), hasLength(1));
      expect((await snapshots.read()).resetGeneration, 4);
    });

    test('clears both scopes', () async {
      await wipe.deleteAccount();

      final published = await snapshots.read();
      expect(published.clearedByReset, ClearedByReset.empty);
      expect(published.clearedByDeleteOnly.grove.value, Grove.initial);
      expect(
        published.clearedByDeleteOnly.companion.value,
        CompanionConfig.initial,
      );
    });

    test('stamps the cleared account fields with this wipe', () async {
      await wipe.deleteAccount();

      final grove = (await snapshots.read()).clearedByDeleteOnly.grove;
      expect(grove.updatedAt, _wipedAt);
      expect(grove.writerId, _thisDevice);
    });

    test('clears the device-local table, appearance included', () async {
      await wipe.deleteAccount();

      final after = await settings.getSettings();
      expect(after.themeMode, AppThemeMode.fallback);
      expect(after.onboardingCompleted, false);
      expect(after.onboardingGoal, isNull);
      expect(after.totalXp, 0);
    });

    test('clears the two already-introduced bits together', () async {
      // The other half of the fate-sharing rule: delete is the wipe that takes
      // both, and it takes them by dropping the row they share.
      await wipe.deleteAccount();

      final after = await settings.getSettings();
      expect(after.onboardingCompleted, false);
      expect(after.tourSeen, false);
    });

    test('restamps the day the learner joined to this wipe', () async {
      // What is left behind is a fresh install in every other respect, so the
      // account the closing line dates is the one beginning now — not the one
      // that was just erased.
      await wipe.deleteAccount();

      expect(
        await install.installedAt(),
        DateTime.fromMillisecondsSinceEpoch(_wipedAt),
      );
    });

    test('clears the tables the snapshot has not replaced yet', () async {
      await wipe.deleteAccount();

      expect(await lessons.getAllCompleted(), isEmpty);
      expect(await modules.isModuleXpAwarded('m1'), false);
      expect(await cards.getAllCollectedCardIds(), isEmpty);
    });
  });
}
