import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_suggestion.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

/// The lesson-complete offer — and, more importantly, its absence.
void main() {
  setUp(useInMemoryDatabase);

  final bank = <BrewChallenge>[testChallenge(lessonId: 'm1l1')];

  Future<void> pump(WidgetTester tester, String lessonId) => pumpWithProviders(
    tester,
    ProviderScope(
      overrides: [challengeBankProvider.overrideWith((ref) async => bank)],
      child: MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: Column(
            children: [
              const Text('above'),
              ChallengeSuggestion(lessonId: lessonId),
              const Text('below'),
            ],
          ),
        ),
      ),
    ),
  );

  testWidgets('offers the challenge the finished lesson carries', (
    tester,
  ) async {
    await pump(tester, 'm1l1');

    expect(find.text('COFFEE CHALLENGE UNLOCKED'), findsOneWidget);
    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('Start Challenge'), findsOneWidget);
    expect(find.text('Save for later'), findsOneWidget);
  });

  testWidgets('a lesson with no challenge takes up no space at all', (
    tester,
  ) async {
    await pump(tester, 'm1l2');

    expect(find.text('COFFEE CHALLENGE UNLOCKED'), findsNothing);
    expect(find.text('Start Challenge'), findsNothing);

    // Not merely "the offer is absent" — the widget must occupy no height, or
    // twenty of thirty-two completion screens grow a mystery gap.
    final gap = tester.getRect(find.byType(ChallengeSuggestion));
    expect(gap.height, 0);
  });

  testWidgets('the surrounding layout is unchanged without a challenge', (
    tester,
  ) async {
    await pump(tester, 'm1l2');
    final withoutBelow = tester.getRect(find.text('below'));
    final withoutAbove = tester.getRect(find.text('above'));

    // The two neighbours sit flush, exactly as they would if the suggestion
    // were not in the tree at all.
    expect(withoutBelow.top, withoutAbove.bottom);
  });

  testWidgets('starting the challenge puts it in play and confirms', (
    tester,
  ) async {
    await pump(tester, 'm1l1');

    await tester.tap(find.text('Start Challenge'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Added to Today'), findsOneWidget);
    // The offer is replaced, so it cannot be started twice.
    expect(find.text('Start Challenge'), findsNothing);

    final active = await tester.runAsync(
      () async =>
          (await SnapshotRepository().read()).clearedByReset.activeChallenge,
    );
    expect(active?.value?.id, 'bc-m1');
  });

  testWidgets('saving it queues it without putting it in play', (tester) async {
    await pump(tester, 'm1l1');

    await tester.tap(find.text('Save for later'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Saved'), findsOneWidget);

    final progress = await tester.runAsync(
      () async => (await SnapshotRepository().read()).clearedByReset,
    );
    expect(progress?.challengesSaved.value, {'bc-m1'});
    // Parking is not starting: nothing has been put on Today.
    expect(progress?.activeChallenge.value, isNull);
  });
}
