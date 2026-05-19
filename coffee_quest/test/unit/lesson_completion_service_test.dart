import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/features/progress/domain/streak_service.dart';
import 'package:coffee_quest/features/progress/domain/xp_service.dart';
import 'package:coffee_quest/services/analytics/noop_analytics_service.dart';
import 'package:coffee_quest/shared/repositories/card_repository.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';
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

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;

    content = ContentRepository();
    progress = ProgressRepository();
    settings = SettingsRepository();
    cards = CardRepository();
    service = LessonCompletionService(
      progressRepository: progress,
      settingsRepository: settings,
      cardRepository: cards,
      contentRepository: content,
      analyticsService: const NoOpAnalyticsService(),
      xpService: const XpService(),
      streakService: const StreakService(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('LessonCompletionService', () {
    test(
      'completing a lesson persists progress, XP, card and streak',
      () async {
        final lesson = (await content.getLessonById('lesson_where_coffee'))!;
        await service.completeLesson(lesson);

        expect(await progress.getByLessonId('lesson_where_coffee'), isNotNull);
        expect((await settings.getSettings()).totalXp, 10);
        expect(await cards.isCardCollected('card_where_coffee'), isTrue);
        expect((await settings.getSettings()).streakDays, 1);
      },
    );

    test('replaying a completed lesson is idempotent', () async {
      final lesson = (await content.getLessonById('lesson_where_coffee'))!;
      await service.completeLesson(lesson);
      await service.completeLesson(lesson);

      expect((await progress.getAllCompleted()).length, 1);
      expect((await settings.getSettings()).totalXp, 10);
    });

    test(
      'finishing every lesson in a module awards the module bonus',
      () async {
        for (final id in const [
          'lesson_where_coffee',
          'lesson_arabica_robusta',
          'lesson_green_coffee',
        ]) {
          await service.completeLesson((await content.getLessonById(id))!);
        }

        // Lesson XP 10 + 20 + 10 = 40, plus the 25 module-completion bonus.
        expect((await settings.getSettings()).totalXp, 65);
      },
    );
  });
}
