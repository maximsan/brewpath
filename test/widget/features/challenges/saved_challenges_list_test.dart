import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/saved_challenges_list.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> pump(WidgetTester tester, List<BrewChallenge> queued) =>
      pumpWithProviders(
        tester,
        ProviderScope(
          overrides: [
            savedChallengesProvider.overrideWith((ref) async => queued),
          ],
          child: MaterialApp(
            theme: AppTheme.darkRoast,
            home: const Scaffold(body: SavedChallengesList()),
          ),
        ),
      );

  testWidgets('renders nothing at all when the queue is empty', (tester) async {
    await pump(tester, const []);

    // A header over an empty list tells the learner they are missing
    // something rather than that there is nothing to miss.
    expect(find.text('SAVED CHALLENGES'), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('lists what is parked', (tester) async {
    await pump(tester, [
      testChallenge(),
      testChallenge(id: 'bc-m2', title: 'Blind process test'),
    ]);

    expect(find.text('SAVED CHALLENGES'), findsOneWidget);
    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('Blind process test'), findsOneWidget);
    expect(find.text('Next brews · 5 min'), findsNWidgets(2));
  });

  testWidgets('starting one puts it in play', (tester) async {
    await pump(tester, [testChallenge()]);

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final active = await tester.runAsync(
      () async =>
          (await SnapshotRepository().read()).clearedByReset.activeChallenge,
    );
    expect(active?.value?.id, 'bc-m1');
  });

  testWidgets('removing one is reachable by its own label', (tester) async {
    await pump(tester, [testChallenge()]);

    expect(
      find.byTooltip('Remove Two cups, two ratios from saved'),
      findsOneWidget,
    );
  });
}
