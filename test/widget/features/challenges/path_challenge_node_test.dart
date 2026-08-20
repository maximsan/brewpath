import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/path_challenge_node.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

/// Module capstones only — the Path here lists modules, and a lesson
/// challenge has no row of its own to hang from.
void main() {
  setUp(useInMemoryDatabase);

  final capstone = testChallenge(scope: ChallengeScope.module);

  Future<void> pump(
    WidgetTester tester, {
    bool offerable = true,
    BrewChallenge? active,
    Set<String> done = const {},
    List<BrewChallenge> saved = const [],
  }) => pumpWithProviders(
    tester,
    ProviderScope(
      overrides: [
        challengeBankProvider.overrideWith((ref) async => [capstone]),
        moduleChallengeOfferProvider(
          'm1',
        ).overrideWith((ref) async => offerable ? capstone : null),
        activeChallengeProvider.overrideWith((ref) async => active),
        completedChallengesProvider.overrideWith((ref) async => done),
        savedChallengesProvider.overrideWith((ref) async => saved),
      ],
      child: MaterialApp(
        theme: AppTheme.darkRoast,
        home: const Scaffold(body: PathChallengeNode(moduleId: 'm1')),
      ),
    ),
  );

  testWidgets('says nothing while the module is unfinished', (tester) async {
    await pump(tester, offerable: false);

    // The module node above already carries the lock.
    expect(find.text('Two cups, two ratios'), findsNothing);
  });

  testWidgets('offers the capstone once the module is done', (tester) async {
    await pump(tester);

    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('Challenge'), findsOneWidget);
  });

  testWidgets('reads Active while it is in play', (tester) async {
    await pump(tester, active: capstone);

    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('reads Done once brewed', (tester) async {
    await pump(tester, done: const {'bc-m1'});

    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('a replay reads Active, not Done', (tester) async {
    await pump(tester, active: capstone, done: const {'bc-m1'});

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('reads Saved while parked', (tester) async {
    await pump(tester, saved: [capstone]);

    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('announces its state to a screen reader', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, done: const {'bc-m1'});

    expect(
      find.bySemanticsLabel('Two cups, two ratios, coffee challenge, Done'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('a module with no capstone shows nothing', (tester) async {
    await pumpWithProviders(
      tester,
      ProviderScope(
        overrides: [
          challengeBankProvider.overrideWith(
            (ref) async => [testChallenge(lessonId: 'm1l1')],
          ),
          moduleChallengeOfferProvider('m1').overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          theme: AppTheme.darkRoast,
          home: const Scaffold(body: PathChallengeNode(moduleId: 'm1')),
        ),
      ),
    );

    expect(find.text('Two cups, two ratios'), findsNothing);
  });
}
