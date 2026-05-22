import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/core/constants/xp_values.dart';
import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/features/progress/domain/streak_service.dart';
import 'package:coffee_quest/features/progress/domain/xp_service.dart';
import 'package:coffee_quest/services/analytics/noop_analytics_service.dart';
import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
import 'package:coffee_quest/shared/repositories/module_progress_repository.dart';
import 'package:coffee_quest/shared/repositories/progress_repository.dart';
import 'package:coffee_quest/shared/repositories/settings_repository.dart';
import 'package:coffee_quest/shared/storage/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LessonCompletionService service;
  late ContentRepository content;
  late ProgressRepository progress;
  late SettingsRepository settings;
  late CardRepository cards;
  late ModuleProgressRepository moduleProgress;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;

    content = ContentRepository();
    progress = ProgressRepository();
    settings = SettingsRepository();
    cards = CardRepository();
    moduleProgress = ModuleProgressRepository();
    service = LessonCompletionService(
      progressRepository: progress,
      settingsRepository: settings,
      cardRepository: cards,
      contentRepository: content,
      moduleProgressRepository: moduleProgress,
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
        final result = await service.completeLesson(lesson, score: 80);

        expect(result.lessonXp, 10);
        expect(result.moduleBonusXp, 0);
        expect(result.moduleCompleted, isFalse);
        expect(await totalXp(), 10);
        expect(await cards.isCardCollected('card_where_coffee'), isTrue);
        expect((await settings.getSettings()).streakDays, 1);

        final record = (await progress.getByLessonId('lesson_where_coffee'))!;
        expect(record.isCompleted, isTrue);
        expect(record.fullXpAwarded, isTrue);
        expect(record.bestScore, 80);
      },
    );

    test('replaying a completed lesson is idempotent', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(lesson, score: 80);
      final replay = await service.completeLesson(lesson, score: 80);

      expect(replay.lessonXp, 10);
      expect(replay.moduleBonusXp, 0);
      expect((await progress.getAllCompleted()).length, 1);
      expect(await totalXp(), 10);
    });

    test(
      'finishing every lesson in a module awards the module bonus once',
      () async {
        late LessonCompletionResult last;
        for (final id in const [
          'lesson_where_coffee',
          'lesson_arabica_robusta',
          'lesson_green_coffee',
        ]) {
          last = await service.completeLesson(
            (await content.getLessonById(id))!,
            score: 100,
          );
        }

        expect(last.moduleBonusXp, 25);
        expect(last.moduleCompleted, isTrue);
        // Lesson XP 10 + 20 + 10 = 40, plus the 25 module-completion bonus.
        expect(await totalXp(), 65);
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
      ]) {
        await service.completeLesson(
          (await content.getLessonById(id))!,
          score: 100,
        );
      }
    }

    test(
      'review does not reset completion, lesson XP, or the earned card',
      () async {
        final lesson = (await content.getLessonById('lesson_where_coffee'))!;
        await service.completeLesson(lesson, score: 60);
        final before = (await progress.getByLessonId(lesson.id))!;

        await service.reviewLesson(
          lesson,
          score: 80,
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
      await service.completeLesson(lesson, score: 50);
      final afterCompletion = await totalXp(); // 10

      await service.reviewLesson(lesson, score: 50, now: DateTime(2026, 5, 22));

      // Review adds only practice XP — never the 10 full-lesson XP again.
      expect(await totalXp(), afterCompletion + XpValues.practiceXp);
    });

    test('reviewing inside a completed module re-awards no module XP', () async {
      await completeBeansModule();
      expect(await totalXp(), 65);
      expect(await moduleProgress.isModuleXpAwarded('module_beans'), isTrue);

      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.reviewLesson(lesson, score: 100, now: DateTime(2026, 5, 22));

      // 65 + 2 practice XP — the 25 module bonus is not granted again.
      expect(await totalXp(), 65 + XpValues.practiceXp);
    });

    test('review improves the stored best score', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(lesson, score: 40);

      final result = await service.reviewLesson(
        lesson,
        score: 90,
        now: DateTime(2026, 5, 22),
      );

      expect(result.bestScore, 90);
      expect((await progress.getByLessonId(lesson.id))!.bestScore, 90);
    });

    test('review never lowers the stored best score', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(lesson, score: 90);

      final result = await service.reviewLesson(
        lesson,
        score: 30,
        now: DateTime(2026, 5, 22),
      );

      expect(result.bestScore, 90);
      expect((await progress.getByLessonId(lesson.id))!.bestScore, 90);
    });

    test('practice XP is granted at most once per lesson per day', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(lesson, score: 50);
      final base = await totalXp(); // 10

      final first = await service.reviewLesson(
        lesson,
        score: 50,
        now: DateTime(2026, 5, 22, 9),
      );
      expect(first.practiceXpAwarded, isTrue);
      expect(await totalXp(), base + XpValues.practiceXp);

      // Same calendar day → no further practice XP.
      final sameDay = await service.reviewLesson(
        lesson,
        score: 50,
        now: DateTime(2026, 5, 22, 20),
      );
      expect(sameDay.practiceXpAwarded, isFalse);
      expect(await totalXp(), base + XpValues.practiceXp);

      // Next calendar day → practice XP again.
      final nextDay = await service.reviewLesson(
        lesson,
        score: 50,
        now: DateTime(2026, 5, 23, 8),
      );
      expect(nextDay.practiceXpAwarded, isTrue);
      expect(await totalXp(), base + 2 * XpValues.practiceXp);
    });
  });
}
