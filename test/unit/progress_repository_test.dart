import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/module_progress_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
  });

  tearDown(() async {
    await db.close();
  });

  group('ProgressRepository', () {
    late ProgressRepository repo;
    setUp(() => repo = ProgressRepository());

    test(
      'saveCompletion stores a record with score and full-XP flag',
      () async {
        await repo.saveCompletion(
          lessonId: 'lesson_a',
          xpEarned: 10,
          mastery: const MasteryResult(correct: 4, total: 5),
        );
        final record = await repo.getByLessonId('lesson_a');
        expect(record, isNotNull);
        expect(record!.isCompleted, isTrue);
        expect(record.xpEarned, 10);
        expect(record.fullXpAwarded, isTrue);
        expect(record.mastery, const MasteryResult(correct: 4, total: 5));
        expect(record.lastPracticeXpDate, isNull);
      },
    );

    test('saveCompletion is idempotent', () async {
      await repo.saveCompletion(
        lessonId: 'lesson_a',
        xpEarned: 10,
        mastery: const MasteryResult(correct: 4, total: 5),
      );
      await repo.saveCompletion(
        lessonId: 'lesson_a',
        xpEarned: 10,
        mastery: const MasteryResult(correct: 4, total: 5),
      );
      final all = await repo.getAllCompleted();
      expect(all.length, 1);
    });

    test('getAllCompleted returns only completed records', () async {
      await repo.saveCompletion(
        lessonId: 'lesson_a',
        xpEarned: 10,
        mastery: const MasteryResult(correct: 4, total: 5),
      );
      await repo.saveCompletion(
        lessonId: 'lesson_b',
        xpEarned: 20,
        mastery: const MasteryResult(correct: 9, total: 10),
      );
      final all = await repo.getAllCompleted();
      expect(all.length, 2);
      expect(all.every((r) => r.isCompleted), isTrue);
    });

    test(
      'saveProgress updates review fields without touching completion',
      () async {
        await repo.saveCompletion(
          lessonId: 'lesson_a',
          xpEarned: 10,
          mastery: const MasteryResult(correct: 2, total: 5),
        );
        final record = (await repo.getByLessonId('lesson_a'))!;
        final completedAt = record.completedAt;

        record.mastery = const MasteryResult(correct: 9, total: 10);
        record.lastPracticeXpDate = DateTime(2026, 5, 22);
        await repo.saveProgress(record);

        final updated = (await repo.getByLessonId('lesson_a'))!;
        expect(updated.mastery, const MasteryResult(correct: 9, total: 10));
        expect(updated.lastPracticeXpDate, DateTime(2026, 5, 22));
        expect(updated.isCompleted, isTrue);
        expect(updated.xpEarned, 10);
        expect(updated.completedAt, completedAt);
      },
    );

    test('deleteAll wipes every completion record', () async {
      await repo.saveCompletion(
        lessonId: 'lesson_a',
        xpEarned: 10,
        mastery: const MasteryResult(correct: 4, total: 5),
      );
      await repo.saveCompletion(
        lessonId: 'lesson_b',
        xpEarned: 20,
        mastery: const MasteryResult(correct: 3, total: 5),
      );
      expect((await repo.getAllCompleted()).length, 2);

      await repo.deleteAll();

      expect(await repo.getAllCompleted(), isEmpty);
      expect(await repo.getByLessonId('lesson_a'), isNull);
    });
  });

  group('ModuleProgressRepository', () {
    late ModuleProgressRepository repo;
    setUp(() => repo = ModuleProgressRepository());

    test('deleteAll wipes the module-XP ledger', () async {
      await repo.markModuleXpAwarded('module_beans');
      await repo.markModuleXpAwarded('module_brewing');
      expect(await repo.isModuleXpAwarded('module_beans'), isTrue);

      await repo.deleteAll();

      expect(await repo.isModuleXpAwarded('module_beans'), isFalse);
      expect(await repo.isModuleXpAwarded('module_brewing'), isFalse);
    });
  });

  group('CardRepository', () {
    late CardRepository repo;
    setUp(() => repo = CardRepository());

    test('collectCard stores a card', () async {
      await repo.collectCard('card_beans');
      expect(await repo.isCardCollected('card_beans'), isTrue);
    });

    test('collectCard is idempotent', () async {
      await repo.collectCard('card_beans');
      await repo.collectCard('card_beans');
      final ids = await repo.getAllCollectedCardIds();
      expect(ids.length, 1);
    });

    test('isCardCollected returns false for unknown card', () async {
      expect(await repo.isCardCollected('card_unknown'), isFalse);
    });

    test('deleteAll wipes every collected card', () async {
      await repo.collectCard('card_a');
      await repo.collectCard('card_b');
      expect((await repo.getAllCollectedCardIds()).length, 2);

      await repo.deleteAll();

      expect(await repo.getAllCollectedCardIds(), isEmpty);
    });
  });

  group('SettingsRepository', () {
    late SettingsRepository repo;
    setUp(() => repo = SettingsRepository());

    test('getSettings returns defaults on first call', () async {
      final settings = await repo.getSettings();
      expect(settings.totalXp, 0);
      expect(settings.streakDays, 0);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.soundEnabled, isTrue);
      expect(settings.lastActivityDate, isNull);
    });

    test('saveSettings persists changes', () async {
      final settings = await repo.getSettings();
      settings.hapticsEnabled = false;
      await repo.saveSettings(settings);
      final updated = await repo.getSettings();
      expect(updated.hapticsEnabled, isFalse);
    });

    test('resetProgress zeros progress fields and keeps preferences', () async {
      final settings = await repo.getSettings();
      settings
        ..hapticsEnabled = false
        ..soundEnabled = false
        ..streakDays = 4
        ..lastActivityDate = DateTime(2026, 5, 20);
      await repo.saveSettings(settings);

      await repo.resetProgress();

      final after = await repo.getSettings();
      // `totalXp` is not reset here and is not expected to be: the points
      // total is derived from the completions a reset clears, so this row
      // holds no counter to zero (#160).
      expect(after.streakDays, 0);
      expect(after.lastActivityDate, isNull);
      // Preferences are preserved across reset.
      expect(after.hapticsEnabled, isFalse);
      expect(after.soundEnabled, isFalse);
    });
  });
}
