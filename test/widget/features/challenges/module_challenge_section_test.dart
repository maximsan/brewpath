import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/module_challenge_section.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

/// The capstone offer, over the real course: a module is finished by finishing
/// its lessons, and only then does it offer anything.
void main() {
  setUp(useInMemoryDatabase);

  /// A real router with a Learn marker, because starting a challenge hands the
  /// learner back to Today.
  Widget app({Widget? child}) {
    final router = GoRouter(
      initialLocation: '/host/m1',
      routes: [
        GoRoute(
          path: '/learn',
          name: AppRoutes.learn.name,
          builder: (context, state) => const Scaffold(body: Text('Learn tab')),
        ),
        // A bare host for the section under test. It used to be the
        // module-detail route; that screen is gone (#394) and the section now
        // renders on Path, so this is named for what it is rather than for a
        // route that no longer exists.
        GoRoute(
          path: '/host/:moduleId',
          name: 'challengeHost',
          builder: (context, state) => Scaffold(
            body: child ?? const ModuleChallengeSection(moduleId: 'm1'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    return MaterialApp.router(
      theme: AppTheme.darkRoast,
      routerConfig: router,
    );
  }

  Future<void> pump(WidgetTester tester) => pumpWithProviders(tester, app());

  Future<void> completeModuleOne(WidgetTester tester) async {
    await tester.runAsync(() async {
      final modules = await ContentRepository().getModules();
      final lessonIds = modules.firstWhere((m) => m.id == 'm1').lessonIds;

      final progress = ProgressRepository();
      for (final id in lessonIds) {
        await progress.saveCompletion(
          lessonId: id,
          xpEarned: 10,
          mastery: const MasteryResult(correct: 5, total: 5),
        );
      }
    });
  }

  testWidgets('offers nothing at all while the module is unfinished', (
    tester,
  ) async {
    await pump(tester);

    // Not a header with an empty body — nothing.
    expect(find.text('MODULE COFFEE CHALLENGE'), findsNothing);
    expect(find.text('Start Challenge'), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('offers the capstone once every lesson is finished', (
    tester,
  ) async {
    await completeModuleOne(tester);
    await pump(tester);

    expect(find.text('MODULE COFFEE CHALLENGE'), findsOneWidget);
    expect(find.text('Two cups, two ratios'), findsOneWidget);
    expect(find.text('Start Challenge'), findsOneWidget);
  });

  testWidgets('starting it puts the challenge in play', (tester) async {
    await completeModuleOne(tester);
    await pump(tester);

    await tester.tap(find.text('Start Challenge'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final stored = await tester.runAsync(
      () async => (await SnapshotRepository().read())
          .clearedByReset
          .activeChallenge
          .value,
    );
    expect(stored?.id, 'bc-m1');
    expect(stored?.startedAt, greaterThan(0));
  });

  testWidgets('a module with no capstone offers nothing', (tester) async {
    await pumpWithProviders(
      tester,
      ProviderScope(
        overrides: [
          challengeBankProvider.overrideWith(
            (ref) async => <BrewChallenge>[testChallenge(lessonId: 'm1l1')],
          ),
        ],
        child: app(),
      ),
    );

    expect(find.text('MODULE COFFEE CHALLENGE'), findsNothing);
  });
}
