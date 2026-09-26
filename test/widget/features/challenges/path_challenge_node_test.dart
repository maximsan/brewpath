import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/path_challenge_node.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

const _today = 'Today, where the challenge now sits';

void main() {
  setUp(useInMemoryDatabase);

  final capstone = testChallenge(scope: ChallengeScope.module);

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    bool offerable = true,
    BrewChallenge? active,
    Set<String> done = const {},
    List<BrewChallenge> saved = const [],
    // An active row pulses forever, which the harness's settle cannot wait
    // out; reduced motion holds the dot still.
    bool reducedMotion = false,
  }) {
    final router = GoRouter(
      initialLocation: AppRoutes.path.path,
      routes: [
        GoRoute(
          path: AppRoutes.path.path,
          name: AppRoutes.path.name,
          builder: (_, _) => Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final shown = pathModuleCapstone(ref, 'm1');
                if (shown == null) return const SizedBox.shrink();
                return PathChallengeRow(
                  challenge: shown.challenge,
                  state: shown.state,
                  isLast: true,
                );
              },
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.learn.path,
          name: AppRoutes.learn.name,
          builder: (_, _) => const Scaffold(body: Text(_today)),
        ),
      ],
    );

    return pumpWithProviders(
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
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.darkRoast,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reducedMotion),
            child: child!,
          ),
        ),
      ),
    );
  }

  testWidgets('says nothing while the module is unfinished', (tester) async {
    await pump(tester, offerable: false);

    // The module node above already carries the lock.
    expect(find.text('Two cups, two ratios'), findsNothing);
  });

  testWidgets('offers the capstone once the module is done, with its time', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('CHALLENGE · 5 MIN'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('reads Active while it is in play, and drops the time', (
    tester,
  ) async {
    await pump(tester, active: capstone, reducedMotion: true);

    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('CHALLENGE'), findsOneWidget);
    expect(find.text('START'), findsNothing);
  });

  testWidgets('a brewed challenge draws no pill at all', (tester) async {
    await pump(tester, done: const {'bc-m1'});

    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('START'), findsNothing);
    expect(find.text('ACTIVE'), findsNothing);
    expect(find.text('DONE'), findsNothing);
  });

  testWidgets('a replay reads Active, not Done', (tester) async {
    await pump(
      tester,
      active: capstone,
      done: const {'bc-m1'},
      reducedMotion: true,
    );

    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('a parked challenge offers Resume, under For later', (
    tester,
  ) async {
    await pump(tester, saved: [capstone]);

    expect(find.text('RESUME'), findsOneWidget);
    expect(find.text('FOR LATER'), findsOneWidget);
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

  testWidgets('Start puts the challenge in play and lands on Today', (
    tester,
  ) async {
    final container = await pump(tester);

    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();

    expect(find.text(_today), findsOneWidget);
    final snapshot = await container.read(snapshotRepositoryProvider).read();
    expect(snapshot.clearedByReset.activeChallenge.value?.id, 'bc-m1');
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.darkRoast,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) =>
                  Text('${pathModuleCapstone(ref, 'm1') == null}'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('true'), findsOneWidget);
  });
}
