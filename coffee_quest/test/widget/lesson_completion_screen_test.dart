import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/lessons/domain/lesson_completion_service.dart';
import 'package:coffee_quest/features/lessons/presentation/lesson_completion_screen.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:coffee_quest/shared/repositories/content_repository.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  testWidgets(
    'completing a lesson refreshes "Today\'s lesson" to the next lesson',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // A live listener keeps the auto-dispose provider alive across the
      // completion, so the test observes the invalidation triggered by
      // LessonCompletionScreen rather than an unrelated fresh recompute.
      final sub = container.listen(todayLessonProvider, (_, _) {});
      addTearDown(sub.close);

      final before = await tester.runAsync(
        () => container.read(todayLessonProvider.future),
      );
      expect(before?.id, 'lesson_where_coffee');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LessonCompletionScreen(
              lessonId: 'lesson_where_coffee',
              score: 100,
            ),
          ),
        ),
      );
      await settleLoaders(tester);
      expect(find.text('Lesson complete!'), findsOneWidget);

      // The completion invalidated todayLessonProvider, so it now resolves to
      // the next uncompleted lesson instead of the stale finished one.
      final after = await tester.runAsync(
        () => container.read(todayLessonProvider.future),
      );
      expect(after?.id, 'lesson_arabica_robusta');
      expect(after?.id, isNot('lesson_where_coffee'));
    },
  );

  // The Profile/Cards tabs stay mounted in the indexed-stack shell, so
  // LessonCompletionScreen must invalidate every completion-derived provider —
  // otherwise their stats keep showing pre-completion values.
  testWidgets(
    'completing a lesson refreshes Total XP, streak, lessons and cards',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Live listeners keep these auto-dispose providers alive across the
      // completion, so the test observes the invalidation triggered by
      // LessonCompletionScreen rather than an unrelated fresh recompute.
      final subs = [
        container.listen(totalXpProvider, (_, _) {}),
        container.listen(streakProvider, (_, _) {}),
        container.listen(completedLessonsProvider, (_, _) {}),
        container.listen(collectedCardsProvider, (_, _) {}),
      ];
      addTearDown(() {
        for (final s in subs) {
          s.close();
        }
      });

      final xpBefore = await tester.runAsync(
        () => container.read(totalXpProvider.future),
      );
      final streakBefore = await tester.runAsync(
        () => container.read(streakProvider.future),
      );
      final lessonsBefore = await tester.runAsync(
        () => container.read(completedLessonsProvider.future),
      );
      final cardsBefore = await tester.runAsync(
        () => container.read(collectedCardsProvider.future),
      );
      expect(xpBefore, 0);
      expect(streakBefore, 0);
      expect(lessonsBefore, isEmpty);
      expect(cardsBefore, isEmpty);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LessonCompletionScreen(
              lessonId: 'lesson_where_coffee',
              score: 100,
            ),
          ),
        ),
      );
      await settleLoaders(tester);
      expect(find.text('Lesson complete!'), findsOneWidget);
      // First lesson of module_beans — 5 steps × 10 XP each. Module bonus
      // doesn't fire yet because the rest of the module is still uncompleted.
      expect(find.text('+50 XP'), findsOneWidget);
      expect(find.textContaining('Module complete!'), findsNothing);

      // The completion invalidated each provider, so they now resolve to the
      // post-completion state instead of the stale pre-completion values.
      final xpAfter = await tester.runAsync(
        () => container.read(totalXpProvider.future),
      );
      final streakAfter = await tester.runAsync(
        () => container.read(streakProvider.future),
      );
      final lessonsAfter = await tester.runAsync(
        () => container.read(completedLessonsProvider.future),
      );
      final cardsAfter = await tester.runAsync(
        () => container.read(collectedCardsProvider.future),
      );
      expect(xpAfter, 50); // lesson_where_coffee has 5 steps × 10 XP
      expect(streakAfter, 1);
      expect(lessonsAfter, hasLength(1));
      expect(cardsAfter, contains('card_where_coffee'));
    },
  );

  // Finishing the last lesson of a module banks the lesson XP *plus* a 25 XP
  // module-completion bonus. The completion screen must surface that bonus so
  // the displayed XP reconciles with the profile total.
  testWidgets('completion screen shows the module-completion bonus', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Live listeners keep these auto-dispose providers alive, so the throwaway
    // container.read calls below don't schedule a Riverpod dispose timer that
    // would outlive the test.
    container.listen(contentRepositoryProvider, (_, _) {});
    container.listen(lessonCompletionServiceProvider, (_, _) {});

    // Finish every other lesson of module_beans directly via the service so
    // the screen below completes the *last* remaining lesson and triggers the
    // module bonus.
    final content = container.read(contentRepositoryProvider);
    final service = container.read(lessonCompletionServiceProvider);
    for (final id in const [
      'lesson_where_coffee',
      'lesson_arabica_robusta',
      'lesson_coffee_plant',
      'lesson_altitude_quality',
    ]) {
      final lesson = await tester.runAsync(() => content.getLessonById(id));
      await tester.runAsync(() => service.completeLesson(lesson!, score: 100));
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: LessonCompletionScreen(
            lessonId: 'lesson_green_coffee',
            score: 100,
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget); // lesson_green_coffee, 5 steps
    expect(find.text('+25 XP · Module complete!'), findsOneWidget);
  });

  // Review mode never re-awards full lesson XP; it shows the best score and
  // grants practice XP on the first review of the day.
  testWidgets('review mode shows best score and practice XP', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Keep these alive so the throwaway container.read calls don't schedule a
    // Riverpod dispose timer that would outlive the test.
    container.listen(contentRepositoryProvider, (_, _) {});
    container.listen(lessonCompletionServiceProvider, (_, _) {});

    // The lesson must already be completed before it can be reviewed.
    final content = container.read(contentRepositoryProvider);
    final service = container.read(lessonCompletionServiceProvider);
    final lesson = await tester.runAsync(
      () => content.getLessonById('lesson_where_coffee'),
    );
    await tester.runAsync(() => service.completeLesson(lesson!, score: 50));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: LessonCompletionScreen(
            lessonId: 'lesson_where_coffee',
            review: true,
            score: 80,
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    expect(find.text('Review complete!'), findsOneWidget);
    expect(find.text('Best score: 80%'), findsOneWidget); // max(50, 80)
    expect(find.text('+2 XP · Practice'), findsOneWidget);
    // A review must not re-award full lesson XP.
    expect(find.textContaining('Lesson complete!'), findsNothing);
  });
}
