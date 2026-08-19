import 'package:brew_path/core/constants/xp_values.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_service.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/streak_service.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/domain/xp_service.dart';
import 'package:brew_path/services/analytics/noop_analytics_service.dart';
import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/module_progress_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LessonCompletionService service;
  late ContentRepository content;
  late ProgressRepository progress;
  late SettingsRepository settings;
  late CardRepository cards;
  late ModuleProgressRepository moduleProgress;
  late SnapshotRepository snapshots;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;

    content = ContentRepository();
    progress = ProgressRepository();
    settings = SettingsRepository();
    cards = CardRepository();
    moduleProgress = ModuleProgressRepository();
    snapshots = SnapshotRepository();
    service = LessonCompletionService(
      progressRepository: progress,
      settingsRepository: settings,
      cardRepository: cards,
      contentRepository: content,
      moduleProgressRepository: moduleProgress,
      snapshotRepository: snapshots,
      analyticsService: const NoOpAnalyticsService(),
      xpService: const XpService(),
      streakService: const StreakService(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> totalXp() async => (await settings.getSettings()).totalXp;

  group('completeLesson', () {
    test(
      'first completion persists progress, XP, card, streak and score',
      () async {
        final lesson = (await content.getLessonById('lesson_where_coffee'))!;
        final result = await service.completeLesson(
          lesson,
          mastery: const MasteryResult(correct: 4, total: 5),
        );

        // lesson_where_coffee has 5 steps × 10 XP each = 50.
        expect(result.lessonXp, 50);
        expect(result.moduleBonusXp, 0);
        expect(result.moduleCompleted, isFalse);
        expect(await totalXp(), 50);
        expect(await cards.isCardCollected('card_where_coffee'), isTrue);
        expect((await settings.getSettings()).streakDays, 1);

        final record = (await progress.getByLessonId('lesson_where_coffee'))!;
        expect(record.isCompleted, isTrue);
        expect(record.fullXpAwarded, isTrue);
        expect(record.mastery, const MasteryResult(correct: 4, total: 5));
      },
    );

    test('replaying a completed lesson is idempotent', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(
        lesson,
        mastery: const MasteryResult(correct: 4, total: 5),
      );
      final replay = await service.completeLesson(
        lesson,
        mastery: const MasteryResult(correct: 4, total: 5),
      );

      expect(replay.lessonXp, 50);
      expect(replay.moduleBonusXp, 0);
      expect((await progress.getAllCompleted()).length, 1);
      expect(await totalXp(), 50);
    });

    test(
      'finishing every lesson in a module awards the module bonus once',
      () async {
        late LessonCompletionResult last;
        for (final id in const [
          'lesson_where_coffee',
          'lesson_arabica_robusta',
          'lesson_green_coffee',
          'lesson_coffee_plant',
          'lesson_altitude_quality',
        ]) {
          last = await service.completeLesson(
            (await content.getLessonById(id))!,
            mastery: const MasteryResult(correct: 5, total: 5),
          );
        }

        expect(last.moduleBonusXp, 25);
        expect(last.moduleCompleted, isTrue);
        // 5 lessons × 5 steps × 10 XP = 250, plus the 25 module bonus.
        expect(await totalXp(), 275);
        expect(await moduleProgress.isModuleXpAwarded('module_beans'), isTrue);
      },
    );
  });

  group('reviewLesson', () {
    /// Completes every lesson of `module_beans`, leaving the module fully done
    /// and its completion bonus already paid out.
    Future<void> completeBeansModule() async {
      for (final id in const [
        'lesson_where_coffee',
        'lesson_arabica_robusta',
        'lesson_green_coffee',
        'lesson_coffee_plant',
        'lesson_altitude_quality',
      ]) {
        await service.completeLesson(
          (await content.getLessonById(id))!,
          mastery: const MasteryResult(correct: 5, total: 5),
        );
      }
    }

    test(
      'review does not reset completion, lesson XP, or the earned card',
      () async {
        final lesson = (await content.getLessonById('lesson_where_coffee'))!;
        await service.completeLesson(
          lesson,
          mastery: const MasteryResult(correct: 3, total: 5),
        );
        final before = (await progress.getByLessonId(lesson.id))!;

        await service.reviewLesson(
          lesson,
          mastery: const MasteryResult(correct: 4, total: 5),
          now: DateTime(2026, 5, 22),
        );

        final after = (await progress.getByLessonId(lesson.id))!;
        expect(after.isCompleted, isTrue);
        expect(after.xpEarned, before.xpEarned);
        expect(after.completedAt, before.completedAt);
        expect(after.fullXpAwarded, isTrue);
        expect(await cards.isCardCollected('card_where_coffee'), isTrue);
      },
    );

    test('review never re-awards full lesson XP', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
      );
      final afterCompletion = await totalXp(); // 5 steps × 10 = 50

      await service.reviewLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
        now: DateTime(2026, 5, 22),
      );

      // Review adds only practice XP — never the full lesson XP again.
      expect(await totalXp(), afterCompletion + XpValues.practiceXp);
    });

    test(
      'reviewing inside a completed module re-awards no module XP',
      () async {
        await completeBeansModule();
        // 5 lessons × 5 steps × 10 XP = 250, plus the 25 module bonus.
        expect(await totalXp(), 275);
        expect(await moduleProgress.isModuleXpAwarded('module_beans'), isTrue);

        final lesson = (await content.getLessonById('lesson_where_coffee'))!;
        await service.reviewLesson(
          lesson,
          mastery: const MasteryResult(correct: 5, total: 5),
          now: DateTime(2026, 5, 22),
        );

        // 275 + 2 practice XP — the 25 module bonus is not granted again.
        expect(await totalXp(), 275 + XpValues.practiceXp);
      },
    );

    test('review improves the stored best score', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
      );

      final result = await service.reviewLesson(
        lesson,
        mastery: const MasteryResult(correct: 9, total: 10),
        now: DateTime(2026, 5, 22),
      );

      expect(result.mastery, const MasteryResult(correct: 9, total: 10));
      expect(
        (await progress.getByLessonId(lesson.id))!.mastery,
        const MasteryResult(correct: 9, total: 10),
      );
    });

    test('review never lowers the stored best score', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(
        lesson,
        mastery: const MasteryResult(correct: 9, total: 10),
      );

      final result = await service.reviewLesson(
        lesson,
        mastery: const MasteryResult(correct: 1, total: 5),
        now: DateTime(2026, 5, 22),
      );

      expect(result.mastery, const MasteryResult(correct: 9, total: 10));
      expect(
        (await progress.getByLessonId(lesson.id))!.mastery,
        const MasteryResult(correct: 9, total: 10),
      );
    });

    test('practice XP is granted at most once per lesson per day', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
      );
      final base = await totalXp(); // 5 steps × 10 = 50

      final first = await service.reviewLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
        now: DateTime(2026, 5, 22, 9),
      );
      expect(first.practiceXpAwarded, isTrue);
      expect(await totalXp(), base + XpValues.practiceXp);

      // Same calendar day → no further practice XP.
      final sameDay = await service.reviewLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
        now: DateTime(2026, 5, 22, 20),
      );
      expect(sameDay.practiceXpAwarded, isFalse);
      expect(await totalXp(), base + XpValues.practiceXp);

      // Next calendar day → practice XP again.
      final nextDay = await service.reviewLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
        now: DateTime(2026, 5, 23, 8),
      );
      expect(nextDay.practiceXpAwarded, isTrue);
      expect(await totalXp(), base + 2 * XpValues.practiceXp);
    });
  });
  group('the Coffee Tree grows', () {
    Future<int> storedStage() async =>
        (await snapshots.read()).clearedByReset.treeStage;

    test('a fresh install is at seed, with nothing completed', () async {
      expect(await storedStage(), freshTreeStage);
    });

    test('a first completion advances the stored stage', () async {
      final lessons = await content.getLessons();

      await service.completeLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );

      expect(await storedStage(), greaterThan(freshTreeStage));
    });

    test('a replay grows nothing', () async {
      final lessons = await content.getLessons();
      await service.completeLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );
      final afterFirst = await storedStage();

      await service.completeLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );

      expect(await storedStage(), afterFirst);
    });

    test('finishing every lesson reaches the last stage', () async {
      final lessons = await content.getLessons();
      for (final lesson in lessons) {
        await service.completeLesson(
          lesson,
          mastery: const MasteryResult(correct: 1, total: 1),
        );
      }

      expect(await storedStage(), treeStageCount);
    });

    // The stage is stored as the outcome, so a course that grows later cannot
    // walk a learner's tree back down.
    test('a stage already reached is never lowered by a later write', () async {
      final lessons = await content.getLessons();
      final snapshot = await snapshots.read();
      await snapshots.write(
        snapshot.copyWith(
          clearedByReset: snapshot.clearedByReset.withTreeStageAtLeast(
            treeStageCount,
          ),
        ),
      );

      await service.completeLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );

      expect(await storedStage(), treeStageCount);
    });

    test('the stage survives a restart', () async {
      final lessons = await content.getLessons();
      await service.completeLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );
      final grown = await storedStage();

      // A new repository over the same store is what a relaunch looks like.
      expect(
        (await SnapshotRepository().read()).clearedByReset.treeStage,
        grown,
      );
    });
  });
}
