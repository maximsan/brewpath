import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/learn/presentation/course_completion_screen.dart';
import 'package:brew_path/features/progress/domain/completed_lessons.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/content_fixtures.dart';

const _lessonCount = 32;
const _moduleRewardCount = 5;
const _longestStreakDays = 12;

/// A learner whose best run is behind them, so the screen cannot pass by
/// showing the current streak under the new label.
const _streak = StreakStatus(
  streak: 3,
  longestStreak: _longestStreakDays,
  freezeHeld: false,
  daysToNextFreeze: freezeEarnDays,
  freezesSpent: 0,
  frozenDays: {},
);

/// The five Module Rewards plus a lesson card, all owned — so a count that
/// took every collected card would read six.
final List<CardWithCollection> _collection = [
  for (var i = 0; i < _moduleRewardCount; i++)
    CardWithCollection(
      card: testCoffeeCard(id: 'cM$i', lessonId: null, moduleId: 'm$i'),
      isCollected: true,
    ),
  CardWithCollection(card: testCoffeeCard(), isCollected: true),
  CardWithCollection(
    card: testCoffeeCard(id: 'cM9', lessonId: null, moduleId: 'm9'),
    isCollected: false,
  ),
];

final CompletedLessons _completed = CompletedLessons(
  completedOn: {
    for (var i = 0; i < _lessonCount; i++) 'l$i': 20680,
  },
  mastery: {
    for (var i = 0; i < _lessonCount; i++)
      'l$i': const MasteryResult(correct: 1, total: 1),
  },
);

/// One deterministic line so the bubble's copy is assertable.
const _lines = CompanionLines({
  'courseComplete': ['You finished the whole course!'],
});

Future<void> _pump(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.courseComplete.path,
    routes: [
      GoRoute(
        path: AppRoutes.courseComplete.path,
        name: AppRoutes.courseComplete.name,
        builder: (_, _) => const CourseCompletionScreen(),
      ),
      GoRoute(
        path: AppRoutes.learn.path,
        name: AppRoutes.learn.name,
        builder: (_, _) => const Text('learn home'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        completedLessonsProvider.overrideWith((ref) async => _completed),
        cardsWithCollectionProvider.overrideWith((ref) async => _collection),
        streakStatusProvider.overrideWith((ref) async => _streak),
        companionLinesProvider.overrideWith((ref) async => _lines),
      ],
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  // Fixed pumps rather than pumpAndSettle: the companion may animate.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('renders the ending: headline, stats and companion line', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('You finished Beginner Foundations'), findsOneWidget);
    expect(
      find.text('Course complete'),
      findsNothing,
      reason: 'the design has no eyebrow: the headline already says it',
    );
    expect(find.text('Lessons completed'), findsOneWidget);
    expect(find.text('Module Rewards'), findsOneWidget);
    expect(find.text('Longest streak'), findsOneWidget);
    expect(find.text('$_lessonCount'), findsOneWidget);
    expect(find.text('$_moduleRewardCount'), findsOneWidget);
    expect(find.text('$_longestStreakDays'), findsOneWidget);
    expect(find.text('You finished the whole course!'), findsOneWidget);
  });

  testWidgets('the streak stat reads the longest run, not the current one', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('${_streak.streak}'), findsNothing);
    expect(find.text('Day streak'), findsNothing);
    expect(find.text('Cards collected'), findsNothing);
  });

  testWidgets('presenting the moment writes the acknowledgement', (
    tester,
  ) async {
    await _pump(tester);

    final snapshot = await SnapshotRepository().read();
    expect(snapshot.clearedByReset.acks, contains('courseComplete'));
  });

  testWidgets('the hand-off lands on Today', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Start Keep Sharp'));
    // The hand-off awaits real IO (the ack write, the gate's recompute);
    // bounded runAsync steps let it progress under the test binding.
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('learn home').evaluate().isNotEmpty) break;
    }

    expect(find.text('learn home'), findsOneWidget);
  });

  testWidgets('reduced motion renders the moment statically', (tester) async {
    await _pump(tester, disableAnimations: true);

    expect(find.text('You finished Beginner Foundations'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the stats carry a spoken summary', (tester) async {
    await _pump(tester);

    expect(
      find.bySemanticsLabel(
        RegExp('What you did.*32 lessons.*5 Module Rewards.*12 days'),
      ),
      findsOneWidget,
    );
  });
}
