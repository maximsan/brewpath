import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/reward_row.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_suggestion.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

/// The lesson-complete offer as a reward-list row — and, more importantly,
/// whether there is an offer at all.
void main() {
  setUp(useInMemoryDatabase);

  final challenge = testChallenge(lessonId: 'm1l1');
  final bank = <BrewChallenge>[challenge];

  /// Pumps the row itself, for the cases about what it says.
  Future<void> pumpRow(WidgetTester tester) => pumpWithProviders(
    tester,
    ProviderScope(
      overrides: [challengeBankProvider.overrideWith((ref) async => bank)],
      child: MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(body: ChallengeSuggestion(challenge: challenge)),
      ),
    ),
  );

  /// Resolves whether [lessonId] has an offer at all — the question the reward
  /// list asks before it builds a row.
  Future<BrewChallenge?> offerFor(WidgetTester tester, String lessonId) async {
    final container = ProviderContainer(
      overrides: [challengeBankProvider.overrideWith((ref) async => bank)],
    );
    addTearDown(container.dispose);
    return tester.runAsync<BrewChallenge?>(
      () => container.read(lessonChallengeOfferProvider(lessonId).future),
    );
  }

  group('whether there is an offer', () {
    testWidgets('the lesson that carries one has it', (tester) async {
      expect((await offerFor(tester, 'm1l1'))?.id, challenge.id);
    });

    testWidgets('a lesson with no challenge has none', (tester) async {
      // Asked as one question, so an absent offer contributes no row — and
      // therefore no hairline above it in the reward list.
      expect(await offerFor(tester, 'm1l2'), isNull);
    });

    testWidgets('a challenge already in play is no longer an offer', (
      tester,
    ) async {
      // Started now, not on a fixed date: the offer returns once the 48-hour
      // window lapses, so a hardcoded day makes this test pass until the
      // calendar reaches it and fail every day after.
      await tester.runAsync(
        () => startChallenge(
          SnapshotRepository(),
          id: challenge.id,
          now: DateTime.now(),
        ),
      );

      expect(await offerFor(tester, 'm1l1'), isNull);
    });
  });

  group('the row', () {
    testWidgets('names the challenge and how long it takes', (tester) async {
      await pumpRow(tester);

      expect(find.text(ChallengeSuggestion.offerLabel), findsOneWidget);
      expect(find.text(challengeOfferDetail(challenge)), findsOneWidget);
    });

    testWidgets('is one row, in the list anatomy', (tester) async {
      await pumpRow(tester);

      expect(find.byType(RewardRow), findsOneWidget);
    });

    testWidgets('offers no decline — leaving the screen is the not-now', (
      tester,
    ) async {
      await pumpRow(tester);

      expect(find.text('Save for later'), findsNothing);
    });

    testWidgets('taking it up puts it in play and says so', (tester) async {
      await pumpRow(tester);

      await tester.tap(find.text(ChallengeSuggestion.offerLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(ChallengeSuggestion.acceptedLabel), findsOneWidget);
      // The offer is replaced, so it cannot be started twice.
      expect(find.text(ChallengeSuggestion.offerLabel), findsNothing);

      final active = await tester.runAsync(
        () async =>
            (await SnapshotRepository().read()).clearedByReset.activeChallenge,
      );
      expect(active?.value?.id, challenge.id);
    });
  });

  group('the detail line', () {
    test('takes the time from the end of the effort', () {
      expect(challengeEffortTime('Two cups · 5 min'), '5 min');
    });

    test('and the whole string when there is no separator', () {
      expect(challengeEffortTime('1 min'), '1 min');
    });
  });
}
