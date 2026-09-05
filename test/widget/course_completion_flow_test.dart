import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/learn_list_view.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/storage/progress_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

/// Settles real async (Drift, rootBundle) in bounded steps until [until]
/// matches. `settleLoaders` cannot be used here: its final `pumpAndSettle`
/// hangs on Roasty's infinite idle animation, and Roasty is on the very
/// screen this flow lands on.
Future<void> _settleUntil(WidgetTester tester, Finder until) async {
  await tester.pump();
  for (var i = 0; i < 50; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(LoadingScreen).evaluate().isNotEmpty) {
      await tester.tap(find.byType(LoadingScreen), warnIfMissed: false);
    }
    if (until.evaluate().isNotEmpty) return;
  }
}

/// The completion moment through the *real* router: the redirect intercepts
/// arrival at Today, and the hand-off resolves the ack before navigating, so
/// it cannot bounce back.
void main() {
  setUp(useInMemoryDatabase);

  final completed = [
    ProgressRecord(
      lessonId: 'm1l1',
      isCompleted: true,
      xpEarned: 10,
      completedAt: DateTime(2026, 8, 15),
      mastery: const MasteryResult(correct: 1, total: 1),
    ),
  ];

  const lines = CompanionLines({
    'courseComplete': ['You finished the whole course!'],
  });

  testWidgets('a due completion intercepts Today, then hands off for good', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        // Caught up with a completion on record and no ack stored → due.
        todayLessonProvider.overrideWith((ref) async => null),
        completedLessonsProvider.overrideWith((ref) async => completed),
        companionLinesProvider.overrideWith((ref) async => lines),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BrewPathApp(),
      ),
    );
    await _settleUntil(tester, find.text('You finished Beginner Foundations'));

    // The router intercepted /learn with the ending.
    expect(find.text('You finished Beginner Foundations'), findsOneWidget);

    await tester.tap(find.text('Start Keep Sharp'));
    await _settleUntil(tester, find.byType(LearnListView));
    // The Learn bar appears while the page transition is still mid-flight
    // and both pages are in the tree; let the transition finish before
    // asserting the ending is gone.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // Landed on Learn — and stayed: the ack resolved before navigation, so
    // the redirect no longer fires.
    expect(find.text('You finished Beginner Foundations'), findsNothing);
    expect(find.byType(LearnListView), findsOneWidget);
  });
}
