import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_offer_row.dart';
import 'package:brew_path/features/challenges/presentation/module_challenge_offer.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

/// The capstone offer, over the real course: a module is finished by finishing
/// its lessons, and only then does it offer anything — and only while the
/// challenge is still live.
void main() {
  setUp(useInMemoryDatabase);

  Widget app({Widget? child}) => MaterialApp(
    theme: AppTheme.darkRoast,
    home: Scaffold(
      body: child ?? const ModuleChallengeOffer(moduleId: 'm1'),
    ),
  );

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

  Future<String?> storedActiveId(WidgetTester tester) =>
      tester.runAsync<String?>(
        () async => (await SnapshotRepository().read())
            .clearedByReset
            .activeChallenge
            .value
            ?.id,
      );

  testWidgets('offers nothing at all while the module is unfinished', (
    tester,
  ) async {
    await pump(tester);

    // Not a kicker with an empty body — nothing.
    expect(find.text(ChallengeOfferRow.kicker), findsNothing);
    expect(find.byType(ChallengeOfferRow), findsNothing);
  });

  testWidgets('offers the capstone once every lesson is finished', (
    tester,
  ) async {
    await completeModuleOne(tester);
    await pump(tester);

    expect(find.text(ChallengeOfferRow.kicker), findsOneWidget);
    // Title and how long it takes, in the design's one muted line.
    expect(find.text('Two cups, two ratios (5 min)'), findsOneWidget);
  });

  testWidgets('starting it puts the challenge in play', (tester) async {
    await completeModuleOne(tester);
    await pump(tester);

    await tester.tap(find.byType(ChallengeOfferRow));
    await settleLoaders(tester);

    expect(await storedActiveId(tester), 'bc-m1');
  });

  // The row must not vanish at the moment it has something to say: starting
  // the challenge is exactly what stops it being a live offer.
  testWidgets('and confirms where it went, without leaving the screen', (
    tester,
  ) async {
    await completeModuleOne(tester);
    await pump(tester);

    await tester.tap(find.byType(ChallengeOfferRow));
    await settleLoaders(tester);

    expect(find.byType(ChallengeStartedRow), findsOneWidget);
    expect(find.text(ChallengeOfferRow.kicker), findsNothing);
  });

  // A bank whose only entry is lesson-scoped: the module is finished, and
  // there is still nothing to offer.
  //
  // The override goes on the **root** container rather than in a nested
  // `ProviderScope`. A generated `@riverpod` provider declares no
  // `dependencies`, so `moduleChallengeOffer` resolves at the root however
  // deeply the widget reading it is nested — a scoped override would reach
  // widgets that read the bank directly and nothing else, and the offer built
  // on top of it would quietly keep the real bank.
  testWidgets('a module with no capstone offers nothing', (tester) async {
    await completeModuleOne(tester);

    final container = ProviderContainer(
      overrides: [
        challengeBankProvider.overrideWith(
          (ref) async => <BrewChallenge>[testChallenge(lessonId: 'm1l1')],
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: app()),
    );
    await settleLoaders(tester);

    expect(find.byType(ChallengeOfferRow), findsNothing);
  });

  testWidgets('nothing once the challenge is already in play', (tester) async {
    await completeModuleOne(tester);
    await tester.runAsync(
      () => startChallenge(
        SnapshotRepository(),
        id: 'bc-m1',
        now: DateTime.now(),
      ),
    );
    await pump(tester);

    expect(find.byType(ChallengeOfferRow), findsNothing);
  });

  testWidgets('and nothing once it has been brewed', (tester) async {
    await completeModuleOne(tester);
    await tester.runAsync(
      () => logChallenge(
        SnapshotRepository(),
        id: 'bc-m1',
        reaction: 'Preferred 1:15',
        now: DateTime.now(),
      ),
    );
    await pump(tester);

    expect(find.byType(ChallengeOfferRow), findsNothing);
  });

  // Parking it was *not yet*, not *no* — the offer is still live.
  testWidgets('but a saved challenge is still offered', (tester) async {
    await completeModuleOne(tester);
    // Parked the way a learner parks one: started, then set aside from the
    // log sheet on Today. The offer that parked a challenge never started was
    // retired with the lesson ending's *Save for later* (#490), so reaching
    // this state through it would test a path nothing can walk.
    await tester.runAsync(() async {
      final snapshots = SnapshotRepository();
      await startChallenge(snapshots, id: 'bc-m1', now: DateTime.now());
      await saveActiveChallengeForLater(
        snapshots,
        id: 'bc-m1',
        now: DateTime.now(),
      );
    });
    await pump(tester);

    expect(find.byType(ChallengeOfferRow), findsOneWidget);
  });
}
