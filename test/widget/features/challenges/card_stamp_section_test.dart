import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/card_stamp_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> pump(
    WidgetTester tester, {
    required bool isCollected,
    String cardId = 'cM1',
    Set<String> done = const {},
  }) => pumpWithProviders(
    tester,
    ProviderScope(
      overrides: [
        challengeBankProvider.overrideWith((ref) async => [testChallenge()]),
        completedChallengesProvider.overrideWith((ref) async => done),
      ],
      child: MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: CardStampSection(cardId: cardId, isCollected: isCollected),
        ),
      ),
    ),
  );

  testWidgets('shows the challenge as unbrewed on an earned card', (
    tester,
  ) async {
    await pump(tester, isCollected: true);

    expect(find.text('CHALLENGE'), findsOneWidget);
    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('Not brewed yet'), findsOneWidget);
  });

  testWidgets('shows it as brewed once logged', (tester) async {
    await pump(tester, isCollected: true, done: const {'bc-m1'});

    expect(find.text('Brewed'), findsOneWidget);
    expect(find.text('Not brewed yet'), findsNothing);
  });

  testWidgets('shows nothing on a card the learner has not earned', (
    tester,
  ) async {
    // Earning the card is the gate; offering a brew from a locked card would
    // advertise content they cannot reach.
    await pump(tester, isCollected: false);

    expect(find.text('CHALLENGE'), findsNothing);
  });

  testWidgets('shows nothing on a card with no challenge', (tester) async {
    await pump(tester, isCollected: true, cardId: 'c9');

    expect(find.text('CHALLENGE'), findsNothing);
  });
}
