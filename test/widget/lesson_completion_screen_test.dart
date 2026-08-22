import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/module_summary_screen.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_service.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

final ModuleModel _testModule = testModule(
  lessonIds: [for (final lesson in _testLessons) lesson.id],
);

final CoffeeCardModel _testCard = testCoffeeCard();

/// The module's own collectible — what the module moment hands over now that
/// it pays no bonus (§5.1, #16).
// The title is the one the bundled bank actually ships. The card's *words*
// are authored content, which this rename does not reach — see #228.
final CoffeeCardModel _testModuleReward = testCoffeeCard(
  id: 'cM1',
  title: 'Beans Field Guide',
  lessonId: null,
  moduleId: 'm1',
);

class _FakeContent extends ContentRepository {
  @override
  Future<List<ModuleModel>> getModules() async => [_testModule];

  @override
  Future<List<LessonModel>> getLessons() async => _testLessons;

  @override
  Future<List<CoffeeCardModel>> getCards() async => [
    _testCard,
    _testModuleReward,
  ];

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
    'completing a lesson refreshes the points total, streak, lessons and cards',
    (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      // Live listeners keep these auto-dispose providers alive across the
      // completion, so the test observes the invalidation triggered by
      // LessonCompletionScreen rather than an unrelated fresh recompute.
      final subs = [
        container.listen(totalPointsProvider, (_, _) {}),
        container.listen(streakProvider, (_, _) {}),
        container.listen(completedLessonsProvider, (_, _) {}),
        container.listen(collectedCardsProvider, (_, _) {}),
      ];
      addTearDown(() {
        for (final s in subs) {
          s.close();
        }
      });

      final pointsBefore = await tester.runAsync(
        () => container.read(totalPointsProvider.future),
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
      expect(pointsBefore, 0);
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
      // First lesson of m1 — the flat ten it authors. The module moment does
      // not fire yet because the rest of the module is still uncompleted.
      expect(find.text('+10 PTS'), findsOneWidget);
      expect(find.textContaining('Module complete!'), findsNothing);

      // The completion invalidated each provider, so they now resolve to the
      // post-completion state instead of the stale pre-completion values.
      final pointsAfter = await tester.runAsync(
        () => container.read(totalPointsProvider.future),
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
      expect(pointsAfter, 10); // m1l1 pays the flat ten it authors
      expect(streakAfter, 1);
      expect(lessonsAfter, hasLength(1));
      expect(cardsAfter, contains('c1'));
    },
  );

  // Finishing the last lesson of a module pays the lesson's flat ten and
  // nothing more. What the module gives is its Module Reward card, so the
  // screen must show one number and one extra card — never a second number.
  testWidgets('completion screen shows the Module Reward card, not a bonus', (
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
    // module moment.
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
    // One number, and it is the lesson's. The bonus this replaced added a
    // second — twenty-five for the module, double-counting lessons already
    // paid for (#16).
    expect(find.text('+10 PTS'), findsOneWidget);
    expect(find.text('Module complete!'), findsOneWidget);
    expect(find.textContaining('+25'), findsNothing);
    // The module's reward is the card.
    expect(find.text('Beans Field Guide'), findsOneWidget);
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

  // Review mode pays nothing at all — not the lesson's points, and not the
  // per-day practice reward it used to grant (§5.1, #16). It shows the best
  // score and no number.
  testWidgets('review mode shows best score and pays nothing', (tester) async {
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
    // No payout line of any kind: the screen used to read '+2 PTS · Practice'
    // or 'Practice points already earned today'.
    expect(find.textContaining('PTS'), findsNothing);
    expect(find.textContaining('Practice'), findsNothing);
    // A review must not re-award the lesson's points.
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
