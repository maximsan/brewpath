import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/module_summary_screen.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_service.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';

import '../support/content_fixtures.dart';

import '../support/widget_harness.dart';

// In-memory content used to override `contentRepositoryProvider` for these
// tests. Going through `rootBundle.loadString` + a JSON decode of the real
// `assets/content/lessons.json` inside a `testWidgets` fake-async zone hangs:
// the live-zone Future returned by `rootBundle` schedules continuations that
// never get pumped, and `tester.runAsync` waits for them forever. Feeding
// the providers in-memory data dodges the bundle entirely.

final _testLessons = <LessonModel>[
  for (var index = 1; index <= 5; index++)
    testLesson(id: 'm1l$index', title: 'm1l$index'),
];

final _testModule = testModule(
  lessonIds: [for (final lesson in _testLessons) lesson.id],
);

final _testCard = testCoffeeCard(title: 'The Coffee Cherry');

class _FakeContent extends ContentRepository {
  @override
  Future<List<ModuleModel>> getModules() async => [_testModule];

  @override
  Future<List<LessonModel>> getLessons() async => _testLessons;

  @override
  Future<List<CoffeeCardModel>> getCards() async => [_testCard];

  @override
  Future<CoffeeCardModel?> getCardForLesson(String lessonId) async =>
      lessonId == _testCard.lessonId ? _testCard : null;

  @override
  Future<LessonModel?> getLessonById(String id) async =>
      _testLessons.where((l) => l.id == id).firstOrNull;
}

ProviderContainer _buildContainer() => ProviderContainer(
  overrides: [contentRepositoryProvider.overrideWith((ref) => _FakeContent())],
);

/// Wraps the screen in a MaterialApp that forces reduced motion, so the
/// completion companion renders a static frame. Without it, the companion's
/// idle loop never settles and `settleLoaders`' final `pumpAndSettle` hangs.
Widget _app(Widget home) => MaterialApp(
  home: home,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
);

void main() {
  setUp(useInMemoryDatabase);

  testWidgets(
    'completing a lesson refreshes "Today\'s lesson" to the next lesson',
    (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      // A live listener keeps the auto-dispose provider alive across the
      // completion, so the test observes the invalidation triggered by
      // LessonCompletionScreen rather than an unrelated fresh recompute.
      final sub = container.listen(todayLessonProvider, (_, _) {});
      addTearDown(sub.close);

      final before = await tester.runAsync(
        () => container.read(todayLessonProvider.future),
      );
      expect(before?.id, 'm1l1');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _app(
            const LessonCompletionScreen(
              lessonId: 'm1l1',
              mastery: MasteryResult(correct: 5, total: 5),
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
      expect(after?.id, 'm1l2');
      expect(after?.id, isNot('m1l1'));
    },
  );

  // The Profile/Cards tabs stay mounted in the indexed-stack shell, so
  // LessonCompletionScreen must invalidate every completion-derived provider —
  // otherwise their stats keep showing pre-completion values.
  testWidgets(
    'completing a lesson refreshes Total XP, streak, lessons and cards',
    (tester) async {
      final container = _buildContainer();
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
          child: _app(
            const LessonCompletionScreen(
              lessonId: 'm1l1',
              mastery: MasteryResult(correct: 5, total: 5),
            ),
          ),
        ),
      );
      await settleLoaders(tester);
      expect(find.text('Lesson complete!'), findsOneWidget);
      // First lesson of m1 — the flat ten it authors. Module bonus
      // doesn't fire yet because the rest of the module is still uncompleted.
      expect(find.text('+10 XP'), findsOneWidget);
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
      expect(xpAfter, 10); // m1l1 pays the flat ten it authors
      expect(streakAfter, 1);
      expect(lessonsAfter, hasLength(1));
      expect(cardsAfter, contains('c1'));
    },
  );

  // Finishing the last lesson of a module banks the lesson XP *plus* a 25 XP
  // module-completion bonus. The completion screen must surface that bonus so
  // the displayed XP reconciles with the profile total.
  testWidgets('completion screen shows the module-completion bonus', (
    tester,
  ) async {
    final container = _buildContainer();
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
      'm1l1',
      'm1l2',
      'm1l4',
      'm1l5',
    ]) {
      final lesson = await tester.runAsync(() => content.getLessonById(id));
      await tester.runAsync(
        () => service.finishLesson(
          lesson!,
          mastery: const MasteryResult(correct: 5, total: 5),
        ),
      );
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _app(
          const LessonCompletionScreen(
            lessonId: 'm1l3',
            mastery: MasteryResult(correct: 5, total: 5),
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.text('+10 XP'), findsOneWidget); // lesson_green_coffee, 5 steps
    expect(find.text('+25 XP · Module complete!'), findsOneWidget);
  });

  // The first-completion path shows the celebratory companion in place of the
  // static badge; review/practice paths keep the badge (no companion).
  testWidgets('first completion shows the companion', (tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _app(
          const LessonCompletionScreen(
            lessonId: 'm1l1',
            mastery: MasteryResult(correct: 5, total: 5),
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.byType(Companion), findsOneWidget);
  });

  // Review mode never re-awards full lesson XP; it shows the best score and
  // grants practice XP on the first review of the day.
  testWidgets('review mode shows best score and practice XP', (tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    // Keep these alive so the throwaway container.read calls don't schedule a
    // Riverpod dispose timer that would outlive the test.
    container.listen(contentRepositoryProvider, (_, _) {});
    container.listen(lessonCompletionServiceProvider, (_, _) {});

    // The lesson must already be completed before it can be reviewed.
    final content = container.read(contentRepositoryProvider);
    final service = container.read(lessonCompletionServiceProvider);
    final lesson = await tester.runAsync(
      () => content.getLessonById('m1l1'),
    );
    await tester.runAsync(
      () => service.finishLesson(
        lesson!,
        mastery: const MasteryResult(correct: 2, total: 5),
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _app(
          // No `review` flag: the screen derives the path from the progress
          // store, so a finished lesson reached this way *is* a replay (#188).
          const LessonCompletionScreen(
            lessonId: 'm1l1',
            mastery: MasteryResult(correct: 4, total: 5),
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    expect(find.text('Review complete!'), findsOneWidget);
    // {4,5} is one wrong (Solid); {2,5} is three wrong (Needs Practice).
    // The better band wins, so the review result replaces the completion's.
    expect(find.text('Best score: 4 / 5'), findsOneWidget);
    expect(find.text('+2 XP · Practice'), findsOneWidget);
    // A review must not re-award full lesson XP.
    expect(find.textContaining('Lesson complete!'), findsNothing);
  });

  // Completing a module's last lesson, then tapping Continue, routes to the
  // module-summary recap rather than back to Learn.
  testWidgets('module completion continues to the module summary', (
    tester,
  ) async {
    final container = _buildContainer();
    addTearDown(container.dispose);
    container.listen(contentRepositoryProvider, (_, _) {});
    container.listen(lessonCompletionServiceProvider, (_, _) {});

    final content = container.read(contentRepositoryProvider);
    final service = container.read(lessonCompletionServiceProvider);
    for (final id in const [
      'm1l1',
      'm1l2',
      'm1l4',
      'm1l5',
    ]) {
      final lesson = await tester.runAsync(() => content.getLessonById(id));
      await tester.runAsync(
        () => service.finishLesson(
          lesson!,
          mastery: const MasteryResult(correct: 5, total: 5),
        ),
      );
    }

    final router = GoRouter(
      initialLocation: '/learn/lesson/m1l3/complete?correct=5&total=5',
      routes: [
        GoRoute(
          path: '/learn',
          name: 'learn',
          builder: (context, state) => const Scaffold(body: Text('Learn tab')),
        ),
        GoRoute(
          path: '/learn/lesson/:lessonId/complete',
          name: 'lessonComplete',
          builder: (context, state) => LessonCompletionScreen(
            lessonId: state.pathParameters['lessonId']!,
            mastery: MasteryResult(
              correct:
                  int.tryParse(state.uri.queryParameters['correct'] ?? '') ?? 0,
              total:
                  int.tryParse(state.uri.queryParameters['total'] ?? '') ?? 0,
            ),
          ),
        ),
        GoRoute(
          path: '/learn/module-summary/:moduleId',
          name: 'moduleSummary',
          builder: (context, state) =>
              ModuleSummaryScreen(moduleId: state.pathParameters['moduleId']!),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    expect(find.text('Lesson complete!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await settleLoaders(tester);

    expect(find.text('Module complete!'), findsOneWidget);
    expect(find.byType(ModuleSummaryScreen), findsOneWidget);
  });
}
