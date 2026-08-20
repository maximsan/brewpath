import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_stat_row.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> pump(
    WidgetTester tester, {
    required List<BrewChallenge> bank,
    Set<String> done = const {},
  }) => pumpWithProviders(
    tester,
    ProviderScope(
      overrides: [
        challengeBankProvider.overrideWith((ref) async => bank),
        completedChallengesProvider.overrideWith((ref) async => done),
      ],
      child: MaterialApp(
        theme: AppTheme.darkRoast,
        home: const Scaffold(body: ChallengeStatRow()),
      ),
    ),
  );

  testWidgets('counts out of the bank, not out of a hard-coded twelve', (
    tester,
  ) async {
    // A three-record bank is the only thing that can catch a literal 12 — the
    // course decides this number, so the stat must ask it.
    await pump(
      tester,
      bank: [
        testChallenge(),
        testChallenge(id: 'bc-m2'),
        testChallenge(id: 'bc-m3'),
      ],
      done: const {'bc-m1'},
    );

    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('reads zero for a learner who has brewed nothing', (
    tester,
  ) async {
    await pump(
      tester,
      bank: [
        testChallenge(),
        testChallenge(id: 'bc-m2'),
      ],
    );

    expect(find.text('0 / 2'), findsOneWidget);
  });

  testWidgets('ignores a completed id the bank no longer carries', (
    tester,
  ) async {
    // Content can be re-authored; a stale id must not push the count past
    // the total.
    await pump(
      tester,
      bank: [testChallenge()],
      done: const {'bc-m1', 'bc-retired'},
    );

    expect(find.text('1 / 1'), findsOneWidget);
  });

  testWidgets('summarises the whole block into one label', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, bank: [testChallenge()], done: const {'bc-m1'});

    expect(
      find.bySemanticsLabel('Coffee Challenges, 1 of 1 brewed'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('renders nothing when the bank is empty', (tester) async {
    await pump(tester, bank: const []);

    expect(find.text('COFFEE CHALLENGES'), findsNothing);
  });
}
