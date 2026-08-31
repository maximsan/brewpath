import 'package:brew_path/features/cards/presentation/reward_card.dart';
import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/companion/presentation/roasty_moment.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/module_complete_screen.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_actions.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_service.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_beat.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_rail.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_screen.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_tree.dart';
import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/features/progress/presentation/growing_tree.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
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

/// Long enough that a learner can qualify [freezeEarnDays] separate days
/// inside one module without finishing it.
const int _lessonCount = 9;

/// The lesson under test in most cases, and the title the screen must print.
const String _titleOfFirst = 'What coffee actually is';

final _testLessons = <LessonModel>[
  for (var index = 1; index <= _lessonCount; index++)
    testLesson(
      id: 'm1l$index',
      title: index == 1 ? _titleOfFirst : 'Lesson number $index',
    ),
];

final ModuleModel _testModule = testModule(
  lessonIds: [for (final lesson in _testLessons) lesson.id],
);

final CoffeeCardModel _testCard = testCoffeeCard();

/// The module's own collectible — what the module moment hands over now that
/// it pays no bonus (§5.1, #16).
// The title is the one the bundled bank actually ships. A card's name is
// authored content and stays as authored; Module Reward is the category,
// not the title (CONTEXT.md).
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

/// Taps past the opening beat and settles onto the content behind it.
///
/// The beat hands over on its own after [RoastyMoment.defaultHold]; tapping is
/// what a learner who does not want to wait does, and asserting it here keeps
/// the skip working.
Future<void> skipBeat(WidgetTester tester) async {
  expect(find.byType(RoastyMoment), findsOneWidget);
  await tester.tap(find.byType(RoastyMoment));
  await settleLoaders(tester);
}

/// Mounts the screen for [lessonId] and lands on its content.
Future<void> pumpCompletion(
  WidgetTester tester,
  ProviderContainer container, {
  String lessonId = 'm1l1',
  MasteryResult mastery = const MasteryResult(correct: 5, total: 5),
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _app(
        LessonCompletionScreen(lessonId: lessonId, mastery: mastery),
      ),
    ),
  );
  await settleLoaders(tester);
  await skipBeat(tester);
}

/// Marks [count] consecutive qualifying days ending yesterday, so the screen
/// under test lands on today as the next one.
///
/// Written through the app's own activity path rather than by finishing
/// lessons, because a completion row stamps itself with the wall clock: six
/// lessons "finished" on six past days would still backfill six *completions
/// today*, and the learner would already hold the freeze before the run under
/// test began.
Future<void> qualifyDaysBefore(WidgetTester tester, int count) async {
  final snapshots = SnapshotRepository();
  for (var back = count; back >= 1; back--) {
    await tester.runAsync(
      () => recordActivity(
        snapshots,
        type: ActivityType.lesson,
        subject: 'seed-$back',
        now: DateTime.now().subtract(Duration(days: back)),
      ),
    );
  }
}

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

      await pumpCompletion(tester, container);
      expect(find.text(_titleOfFirst), findsOneWidget);

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

      await pumpCompletion(tester, container);
      // First lesson of m1 — the flat ten it authors. The module moment does
      // not fire yet because the rest of the module is still uncompleted.
      expect(find.text('+10 PTS'), findsOneWidget);

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

  // The screen's whole subject: the design's completion names the lesson and
  // reports the run, where the app's used to do neither on a first completion.
  group('what a first completion reports', () {
    testWidgets('the lesson is named, under a kicker', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(tester, container);

      expect(find.text(completeEyebrow.toUpperCase()), findsOneWidget);
      expect(find.text(_titleOfFirst), findsOneWidget);
      // The headline the lesson's name replaced.
      expect(find.text('Lesson complete!'), findsNothing);
    });

    testWidgets('the score is on screen, not only on a replay', (
      tester,
    ) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(
        tester,
        container,
        mastery: const MasteryResult(correct: 4, total: 5),
      );

      expect(find.text('4 / 5'), findsOneWidget);
    });

    testWidgets('an unscored run prints no score line', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(
        tester,
        container,
        mastery: MasteryResult.unscored,
      );

      expect(find.textContaining(' / '), findsNothing);
    });
  });

  group('the weak run is invited back', () {
    testWidgets('the chip and the invitation appear together', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(
        tester,
        container,
        mastery: const MasteryResult(correct: 1, total: 5),
      );

      expect(
        find.text(MasteryBand.needsPractice.label.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(practiceAgainLabel), findsOneWidget);
    });

    testWidgets('a clean run earns neither', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(tester, container);

      expect(
        find.text(MasteryBand.needsPractice.label.toUpperCase()),
        findsNothing,
      );
      expect(find.text(practiceAgainLabel), findsNothing);
      // The design gives only the weak run a chip: the score above it already
      // says how a good run went.
      expect(find.text(MasteryBand.perfect.label.toUpperCase()), findsNothing);
    });
  });

  // The finding this ticket calls sharpest: the app only ever showed the word
  // "freeze" at the moment a day had already been lost.
  group('the freeze is introduced where it is earned', () {
    testWidgets('the seventh qualifying day shows the row', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);
      container.listen(lessonCompletionServiceProvider, (_, _) {});
      container.listen(contentRepositoryProvider, (_, _) {});

      await qualifyDaysBefore(tester, freezeEarnDays - 1);
      await pumpCompletion(tester, container);

      expect(
        find.text(LessonCompletionRail.freezeKicker.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(LessonCompletionRail.freezeSupport), findsOneWidget);
    });

    testWidgets('an ordinary day does not', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);
      container.listen(lessonCompletionServiceProvider, (_, _) {});
      container.listen(contentRepositoryProvider, (_, _) {});

      await qualifyDaysBefore(tester, freezeEarnDays - 2);
      await pumpCompletion(tester, container);

      expect(
        find.text(LessonCompletionRail.freezeKicker.toUpperCase()),
        findsNothing,
      );
    });
  });

  // Row #40 and #41 of the audit: the screen is where the living-tree metaphor
  // the Welcome screen sells actually pays off, and most completions cross no
  // threshold — so a still tree has to say how far the next one is.
  group('the tree', () {
    testWidgets('is on the screen', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(tester, container);

      expect(find.byType(GrowingTree), findsOneWidget);
    });

    testWidgets('says how far the next stage is when it did not move', (
      tester,
    ) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      // These fixtures hold a single module, and the design gives the last
      // module one growth step rather than two — so the only threshold is the
      // course's own end, and one lesson in leaves the rest of it to go.
      await pumpCompletion(tester, container);

      final tree = tester.widget<GrowingTree>(find.byType(GrowingTree));
      expect(tree.grows, isFalse);
      expect(
        find.text(
          LessonCompletionTree.stillTreeLine(_lessonCount - 1).toUpperCase(),
        ),
        findsOneWidget,
      );
    });

    testWidgets('and says nothing extra when it did move', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);
      container.listen(contentRepositoryProvider, (_, _) {});
      container.listen(lessonCompletionServiceProvider, (_, _) {});

      // Finish every lesson but the first, so the run under test is the one
      // that closes the module — the single threshold this course has.
      final content = container.read(contentRepositoryProvider);
      final service = container.read(lessonCompletionServiceProvider);
      for (final lesson in _testLessons.skip(1)) {
        final loaded = await tester.runAsync(
          () => content.getLessonById(lesson.id),
        );
        await tester.runAsync(
          () => service.finishLesson(
            loaded!,
            mastery: const MasteryResult(correct: 5, total: 5),
          ),
        );
      }

      await pumpCompletion(tester, container);

      final tree = tester.widget<GrowingTree>(find.byType(GrowingTree));
      expect(tree.grows, isTrue);
      expect(find.textContaining('TO THE NEXT STAGE'), findsNothing);
    });
  });

  // Row #47's other half: the rail's card row is the way into the collectible,
  // because the card *is* the module's guide and this is the moment it was
  // earned — not something to go and find on the Cards tab later.
  group('the card the run handed over', () {
    testWidgets('opens its preview when tapped', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(tester, container);
      expect(
        find.text(LessonCompletionRail.cardKicker.toUpperCase()),
        findsOneWidget,
      );

      final row = find.text(LessonCompletionRail.cardKicker.toUpperCase());
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();

      expect(find.byType(RewardCard), findsOneWidget);
      expect(find.text(_testCard.fact), findsOneWidget);
    });

    testWidgets('the rows that open onto nothing are not buttons', (
      tester,
    ) async {
      final container = _buildContainer();
      addTearDown(container.dispose);
      container.listen(lessonCompletionServiceProvider, (_, _) {});
      container.listen(contentRepositoryProvider, (_, _) {});

      await qualifyDaysBefore(tester, freezeEarnDays - 1);
      await pumpCompletion(tester, container);

      final freeze = tester.getSemantics(
        find
            .ancestor(
              of: find.text(LessonCompletionRail.freezeKicker.toUpperCase()),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(freeze.flagsCollection.isButton, isFalse);
    });
  });

  group('the way on', () {
    testWidgets('offers the next lesson while the course has one', (
      tester,
    ) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(tester, container);

      expect(find.text(nextLessonLabel), findsOneWidget);
      expect(find.text(backToPathLabel), findsOneWidget);
    });

    // The reachable case for the plain return: the course is finished, so
    // nothing is queued, and a replay closes no module — which is what a
    // learner revisiting a lesson after the last one actually does.
    testWidgets('and returns to Path once nothing is queued', (tester) async {
      final container = _buildContainer();
      addTearDown(container.dispose);
      container.listen(lessonCompletionServiceProvider, (_, _) {});
      container.listen(contentRepositoryProvider, (_, _) {});

      final service = container.read(lessonCompletionServiceProvider);
      final content = container.read(contentRepositoryProvider);
      for (final lesson in _testLessons) {
        final loaded = await tester.runAsync(
          () => content.getLessonById(lesson.id),
        );
        await tester.runAsync(
          () => service.finishLesson(
            loaded!,
            mastery: const MasteryResult(correct: 5, total: 5),
          ),
        );
      }

      await pumpCompletion(tester, container);

      expect(find.text(nextLessonLabel), findsNothing);
      expect(find.text(backToPathLabel), findsOneWidget);
    });

    testWidgets('the celebration is not a screen you are held on', (
      tester,
    ) async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await pumpCompletion(tester, container);

      expect(find.byTooltip('Close'), findsOneWidget);
    });
  });

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

    // Finish every other lesson of the module directly via the service so the
    // screen below completes the *last* remaining one and triggers the module
    // moment.
    final content = container.read(contentRepositoryProvider);
    final service = container.read(lessonCompletionServiceProvider);
    for (final lesson in _testLessons.where((l) => l.id != 'm1l3')) {
      final loaded = await tester.runAsync(
        () => content.getLessonById(lesson.id),
      );
      await tester.runAsync(
        () => service.finishLesson(
          loaded!,
          mastery: const MasteryResult(correct: 5, total: 5),
        ),
      );
    }

    await pumpCompletion(tester, container, lessonId: 'm1l3');

    // One number, and it is the lesson's. The bonus this replaced added a
    // second — twenty-five for the module, double-counting lessons already
    // paid for (#16).
    expect(find.text('+10 PTS'), findsOneWidget);
    expect(find.textContaining('+25'), findsNothing);
    // The module's reward is the card, on the rail under its own kicker.
    expect(find.text('Beans Field Guide'), findsOneWidget);
    expect(
      find.text(LessonCompletionRail.cardKicker.toUpperCase()),
      findsWidgets,
    );
    // The design routes a closed module to its own screen instead of stacking
    // a second headline here.
    expect(find.text('Module complete!'), findsNothing);
  });

  // The opening beat plays the celebratory companion; the content behind it
  // carries no mascot of its own.
  testWidgets('the beat celebrates, then hands over', (tester) async {
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

    expect(find.byType(RoastyMoment), findsOneWidget);
    expect(find.byType(Companion), findsOneWidget);
    expect(find.text(completionBeatTitle(MasteryBand.perfect)), findsOneWidget);
    // The content is not built until the beat is over.
    expect(find.text(_titleOfFirst), findsNothing);

    await skipBeat(tester);

    expect(find.byType(RoastyMoment), findsNothing);
    expect(find.text(_titleOfFirst), findsOneWidget);
  });

  // ⚠️ Reduced motion must not swallow the hand-over: the content sits behind
  // a callback, so a beat that never ends is a screen that never arrives.
  testWidgets('the beat ends on its own under reduced motion', (tester) async {
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
    expect(find.byType(RoastyMoment), findsOneWidget);

    await tester.pump(RoastyMoment.defaultHold);
    await settleLoaders(tester);

    expect(find.byType(RoastyMoment), findsNothing);
    expect(find.text(_titleOfFirst), findsOneWidget);
  });

  // Review mode pays nothing at all — not the lesson's points, and not the
  // per-day practice reward it used to grant (§5.1, #16).
  testWidgets('review mode pays nothing, and says so', (tester) async {
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

    // No `review` flag: the screen derives the path from the progress store,
    // so a finished lesson reached this way *is* a replay (#188).
    await pumpCompletion(
      tester,
      container,
      mastery: const MasteryResult(correct: 4, total: 5),
    );

    expect(find.text(reviewEyebrow.toUpperCase()), findsOneWidget);
    expect(find.text('4 / 5'), findsOneWidget);
    // No payout line of any kind: the screen used to read '+2 PTS · Practice'
    // or 'Practice points already earned today'.
    expect(find.textContaining('PTS'), findsNothing);
    // A replay pays nothing, so the rail has no row to draw at all.
    expect(
      find.text(LessonCompletionRail.cardKicker.toUpperCase()),
      findsNothing,
    );
  });

  // ⚠️ The screen reports the run that reached it, not the stored best. The
  // two only differ on a replay, and reading the best there would congratulate
  // a learner on a run they did not have — and withhold the chip and the
  // invitation from the exact run that earned them.
  testWidgets('a replay reports the run just played, not the best ever', (
    tester,
  ) async {
    final container = _buildContainer();
    addTearDown(container.dispose);
    container.listen(contentRepositoryProvider, (_, _) {});
    container.listen(lessonCompletionServiceProvider, (_, _) {});

    // A clean first run, so the stored best is perfect.
    final content = container.read(contentRepositoryProvider);
    final service = container.read(lessonCompletionServiceProvider);
    final lesson = await tester.runAsync(() => content.getLessonById('m1l1'));
    await tester.runAsync(
      () => service.finishLesson(
        lesson!,
        mastery: const MasteryResult(correct: 5, total: 5),
      ),
    );

    // Then a bad replay. The stored best stays {5,5}; the screen must not.
    await pumpCompletion(
      tester,
      container,
      mastery: const MasteryResult(correct: 1, total: 5),
    );

    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.text('5 / 5'), findsNothing);
    expect(
      find.text(MasteryBand.needsPractice.label.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(practiceAgainLabel), findsOneWidget);
  });

  // Completing a module's last lesson, then tapping its action, routes to the
  // module-summary recap rather than back to the course.
  testWidgets('module completion continues to the module summary', (
    tester,
  ) async {
    final container = _buildContainer();
    addTearDown(container.dispose);
    container.listen(contentRepositoryProvider, (_, _) {});
    container.listen(lessonCompletionServiceProvider, (_, _) {});

    final content = container.read(contentRepositoryProvider);
    final service = container.read(lessonCompletionServiceProvider);
    for (final lesson in _testLessons.where((l) => l.id != 'm1l3')) {
      final loaded = await tester.runAsync(
        () => content.getLessonById(lesson.id),
      );
      await tester.runAsync(
        () => service.finishLesson(
          loaded!,
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
          path: '/path',
          name: 'path',
          builder: (context, state) => const Scaffold(body: Text('Path tab')),
        ),
        GoRoute(
          path: '/learn/lesson/:lessonId',
          name: 'lesson',
          builder: (context, state) => const Scaffold(body: Text('Lesson')),
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
              ModuleCompleteScreen(moduleId: state.pathParameters['moduleId']!),
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
    await skipBeat(tester);

    await tester.tap(find.text('Continue'));
    await settleLoaders(tester);

    expect(find.byType(ModuleCompleteScreen), findsOneWidget);
  });
}
