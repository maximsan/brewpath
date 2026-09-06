import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/reward_flip.dart';
import 'package:brew_path/features/cards/presentation/reward_card.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_offer_row.dart';
import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/presentation/roasty_moment.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/features/learn/presentation/module_complete_screen.dart';
import 'package:brew_path/features/learn/presentation/module_ending_marks.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/growing_tree.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

final ModuleModel _module = testModule(lessonIds: const ['m1l1']);

/// The beat's hold, as the screen sets it (`rewards.jsx:225`). Restated here
/// rather than imported: it is private to the screen, and a test that reached
/// for it would be asserting the screen against itself.
const Duration _moduleHold = Duration(milliseconds: 2200);
// The title is the one the bundled bank actually ships. A card's name is
// authored content and stays as authored; Module Reward is the category,
// not the title (CONTEXT.md).
final CoffeeCardModel _moduleReward = testCoffeeCard(
  id: 'cM1',
  title: 'Beans Field Guide',
  lessonId: null,
  moduleId: 'm1',
);

ModuleSummary _summary({
  String? nextLessonId = 'm2l1',
  CoffeeCardModel? reward,
}) => ModuleSummary(
  module: _module,
  moduleReward: reward ?? _moduleReward,
  nextLessonId: nextLessonId,
);

/// Pumped with animations **on** by default: the flip is the subject, and a
/// harness that disabled them everywhere could not tell a turn from a jump.
Widget _app(Widget home, {bool reducedMotion = false}) => MaterialApp(
  home: home,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
    child: child!,
  ),
);

void main() {
  Widget harness(
    ModuleSummary summary, {
    bool reducedMotion = false,
    ModuleEndingRun run = noModuleEndingRun,
    String? runLessonId,
    bool freezeEarned = false,
    int? fromStage,
    int? toStage,
    BrewChallenge? offer,
  }) => ProviderScope(
    overrides: [
      moduleSummaryProvider('module_beans').overrideWith((ref) => summary),
      moduleEndingRunProvider(runLessonId).overrideWith((ref) => run),
      // The module's capstone, or none — the common case. Overridden rather
      // than read, because the gate behind it is the offer's own test.
      liveModuleChallengeOfferProvider(
        _module.id,
      ).overrideWith((ref) async => offer),
      streakProvider.overrideWith((ref) => 0),
      companionLinesProvider.overrideWith(
        (ref) => CompanionLines.fromJson(const {
          'moduleComplete': ['Whole module brewed!'],
        }),
      ),
    ],
    child: _app(
      ModuleCompleteScreen(
        moduleId: 'module_beans',
        runLessonId: runLessonId,
        freezeEarned: freezeEarned,
        fromStage: fromStage,
        toStage: toStage,
      ),
      reducedMotion: reducedMotion,
    ),
  );

  // ⚠️ **Never `pumpAndSettle` on this screen.** The coffee tree sways for as
  // long as it is on screen, so nothing on the celebration face ever settles.
  // Each step pumps the duration it actually waits on.

  /// How much of the reward card's width the viewer actually sees, `0` edge-on
  /// to `1` face-on.
  ///
  /// Read off the composed paint transform rather than the layout box: the
  /// card lays out at full size whatever angle it is turned to.
  double paintedWidthFraction(WidgetTester tester) {
    final card = tester.renderObject(find.byType(RewardCard)) as RenderBox;
    final screen = tester.renderObject(find.byType(MaterialApp)) as RenderBox;
    final toScreen = card.getTransformTo(screen);
    final left = MatrixUtils.transformPoint(toScreen, Offset.zero);
    final right = MatrixUtils.transformPoint(
      toScreen,
      Offset(card.size.width, 0),
    );
    return ((right.dx - left.dx) / card.size.width).abs();
  }

  /// Taps a face's action and lets the turn finish.
  Future<void> turn(WidgetTester tester, Finder control) async {
    await tester.tap(control);
    await tester.pump();
    await tester.pump(rewardFlipDuration);
    await tester.pump();
  }

  /// Plays the opening beat out, leaving the celebration face on screen.
  Future<void> pastTheBeat(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(_moduleHold);
    await tester.pump();
  }

  group('beat 1 — the opener', () {
    testWidgets('opens on the moment, not on the celebration', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await tester.pump();

      expect(find.byType(RoastyMoment), findsOneWidget);
      expect(find.text(AppLabels.moduleCompleteTitle), findsOneWidget);
      expect(find.byType(GrowingTree), findsNothing);
    });

    testWidgets('holds for the module beat, longer than the default', (
      tester,
    ) async {
      await tester.pumpWidget(harness(_summary()));
      await tester.pump();

      // Still holding at the default — this beat is the one that overrides it.
      await tester.pump(RoastyMoment.defaultHold);
      expect(find.byType(RoastyMoment), findsOneWidget);

      await tester.pump(_moduleHold - RoastyMoment.defaultHold);
      await tester.pump();
      expect(find.byType(RoastyMoment), findsNothing);
    });
  });

  group('beat 2 — the celebration', () {
    testWidgets('the module is the headline, not the word "complete"', (
      tester,
    ) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);

      expect(find.text(_module.title), findsOneWidget);
      expect(
        find.text(AppLabels.moduleCompleteKicker.toUpperCase()),
        findsOneWidget,
      );
      // The old screen's headline, which demoted the module's own name.
      expect(find.text('Module complete!'), findsNothing);
    });

    testWidgets('the tree is here, and it is the design size', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);

      final tree = tester.widget<GrowingTree>(find.byType(GrowingTree));
      expect(tree.size, 250);
      // Still: the growth belonged to the lesson that caused it (#458).
      expect(tree.fromStage, tree.toStage);
    });

    testWidgets('no points line — the module pays nothing', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);

      // §5.1, #16. Audit E cleared this as *not* a divergence.
      expect(find.textContaining('PTS'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
    });

    testWidgets('the card is on the other side, and says so', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);

      expect(find.text(AppLabels.rewardWaiting), findsOneWidget);
      expect(find.text(AppLabels.turnItOver), findsOneWidget);
      expect(find.byType(RewardCard), findsNothing);
    });
  });

  group('beat 3 — the turn', () {
    testWidgets('turning it over shows the reward card', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);

      await turn(tester, find.text(AppLabels.turnItOver));

      expect(find.byType(RewardCard), findsOneWidget);
    });

    testWidgets('and the card is all the back face carries', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);

      await turn(tester, find.text(AppLabels.turnItOver));

      // The face drew `REWARD UNLOCKED` over a generic `New collectible card`,
      // directly above the card's own title. The design draws the card alone,
      // and so does the lesson ending's back — one anatomy, both endings.
      expect(find.text('REWARD UNLOCKED'), findsNothing);
      expect(find.text('New collectible card'), findsNothing);
      expect(find.text(_moduleReward.title), findsOneWidget);
    });

    testWidgets('exactly one face is built at a time', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);

      // Front only.
      expect(find.text(AppLabels.turnItOver), findsOneWidget);
      expect(find.byType(RewardCard), findsNothing);

      await turn(tester, find.text(AppLabels.turnItOver));

      // Back only — a face left in the tree would be seen mirrored.
      expect(find.byType(RewardCard), findsOneWidget);
      expect(find.text(AppLabels.turnItOver), findsNothing);
    });

    testWidgets('and turning back returns to the celebration', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);

      await turn(tester, find.text(AppLabels.turnItOver));
      await turn(tester, find.bySemanticsLabel(AppLabels.flipBack));

      expect(find.text(_module.title), findsOneWidget);
      expect(find.byType(RewardCard), findsNothing);
    });

    testWidgets('reduced motion still turns it over, without the turn', (
      tester,
    ) async {
      await tester.pumpWidget(harness(_summary(), reducedMotion: true));
      await pastTheBeat(tester);

      await tester.tap(find.text(AppLabels.turnItOver));
      await tester.pump();

      // ⚠️ **Readable, not merely present.** Resting the turn at its swap
      // point once left the card face-on to nobody, and `findsOneWidget` was
      // happy with it — so was `getSize`, because a `Transform` does not
      // change layout size. This measures what is actually painted: how much
      // of the card's width survives the rotation it is drawn under.
      expect(paintedWidthFraction(tester), closeTo(1, 0.01));

      // One pump, no settle: the result is there immediately rather than
      // after 820 ms of rotation.
      expect(find.byType(RewardCard), findsOneWidget);
    });
  });

  group('the way out', () {
    testWidgets('offers the next module when one follows', (tester) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);
      await turn(tester, find.text(AppLabels.turnItOver));

      expect(find.text(AppLabels.beginNextModule), findsOneWidget);
    });

    testWidgets('and the Path when none does', (tester) async {
      await tester.pumpWidget(harness(_summary(nextLessonId: null)));
      await pastTheBeat(tester);
      await turn(tester, find.text(AppLabels.turnItOver));

      expect(find.text(AppLabels.backToPath), findsOneWidget);
      expect(find.text(AppLabels.beginNextModule), findsNothing);
    });
  });

  // **This ending is the closing lesson's ending too** (#458). The design
  // branches rather than chaining, so nothing else reports what that lesson
  // paid — and what the restyled ending reports of it is the points and the
  // freeze, on one centred line each (#490).
  group('what the closing lesson paid', () {
    Future<void> pumpFront(
      WidgetTester tester, {
      ModuleEndingRun run = noModuleEndingRun,
      bool freezeEarned = false,
    }) async {
      await tester.pumpWidget(
        harness(
          _summary(),
          reducedMotion: true,
          runLessonId: 'm1l7',
          run: run,
          freezeEarned: freezeEarned,
        ),
      );
      await tester.pump();
      await tester.pump(_moduleHold);
      await tester.pump();
    }

    testWidgets('the points the lesson paid are on the front', (tester) async {
      await pumpFront(
        tester,
        run: (pointsEarned: 10),
      );

      expect(find.text('+10 PTS'), findsOneWidget);
    });

    // The collectible the closing lesson handed over is **not** announced
    // here. The restyled ending has no reward list, and its one card is the
    // module's on the other face — the lesson's is still collected, and is on
    // the Cards tab.
    testWidgets('but not the collectible it handed over', (tester) async {
      await pumpFront(tester, run: (pointsEarned: 10));

      expect(find.text('Washed Process'), findsNothing);
    });

    // The finding the audit called sharpest, and the one thing here that
    // cannot be recovered later: the freeze is a transition, true only on the
    // run that crossed it.
    testWidgets('and the freeze, when that run earned one', (tester) async {
      await pumpFront(
        tester,
        run: (pointsEarned: 10),
        freezeEarned: true,
      );

      expect(
        find.text(FreezeEarnedLine.label.toUpperCase()),
        findsOneWidget,
      );
    });

    // The module's own card lives on the other face. Drawing it here as well
    // would show the same collectible twice in one turn.
    testWidgets('the module reward stays on the back', (tester) async {
      await pumpFront(
        tester,
        run: (pointsEarned: 10),
      );

      expect(find.text('Beans Field Guide'), findsNothing);
    });

    // Opened outside the flow — a review, a deep link — there is no run to
    // report, and the rail must not appear as an empty box.
    testWidgets('nothing at all when no run is being reported', (tester) async {
      await pumpFront(tester);

      expect(find.textContaining('PTS'), findsNothing);
      expect(find.byType(FreezeEarnedLine), findsNothing);
    });
  });

  // The module's optional Coffee Challenge is offered here and nowhere else:
  // the design deleted the separate hand-off screen and made the offer a row
  // above the exit CTA, *"no separate step"* (#464).
  group('the challenge it unlocks', () {
    final capstone = testChallenge(scope: ChallengeScope.module);

    testWidgets('is offered on the reward face, above the way out', (
      tester,
    ) async {
      await tester.pumpWidget(harness(_summary(), offer: capstone));
      await pastTheBeat(tester);
      await turn(tester, find.text(AppLabels.turnItOver));

      expect(find.text(ChallengeOfferRow.kicker), findsOneWidget);
      expect(find.text(AppLabels.beginNextModule), findsOneWidget);
      // Above it, not merely present with it: the offer is met on the way to
      // the exit, and an offer under the CTA is one nobody reads.
      expect(
        tester.getBottomLeft(find.byType(ChallengeOfferRow)).dy,
        lessThanOrEqualTo(
          tester.getTopLeft(find.text(AppLabels.beginNextModule)).dy,
        ),
      );
    });

    // The offer belongs to the reward beat, not to the celebration: the
    // learner meets it once, on the face that hands things over.
    testWidgets('and not on the celebration face', (tester) async {
      await tester.pumpWidget(harness(_summary(), offer: capstone));
      await pastTheBeat(tester);

      expect(find.byType(ChallengeOfferRow), findsNothing);
    });

    testWidgets('a module with no live challenge advances exactly as before', (
      tester,
    ) async {
      await tester.pumpWidget(harness(_summary()));
      await pastTheBeat(tester);
      await turn(tester, find.text(AppLabels.turnItOver));

      expect(find.byType(ChallengeOfferRow), findsNothing);
      expect(find.text(AppLabels.beginNextModule), findsOneWidget);
    });
  });

  group('the tree', () {
    testWidgets('grows, because this is the ending of the run that grew it', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          _summary(),
          reducedMotion: true,
          runLessonId: 'm1l7',
          fromStage: 2,
          toStage: 3,
        ),
      );
      await tester.pump();
      await tester.pump(_moduleHold);
      await tester.pump();

      final tree = tester.widget<GrowingTree>(find.byType(GrowingTree));
      expect(tree.fromStage, 2);
      expect(tree.toStage, 3);
      expect(tree.grows, isTrue);
    });

    // The workaround this replaced: the ending used to draw the tree at rest,
    // because the lesson ending had already played the growth by the time it
    // opened. With one ending there is no earlier screen to have played it.
    testWidgets('and rests only when no run is being reported', (tester) async {
      await tester.pumpWidget(harness(_summary(), reducedMotion: true));
      await tester.pump();
      await tester.pump(_moduleHold);
      await tester.pump();

      expect(
        tester.widget<GrowingTree>(find.byType(GrowingTree)).grows,
        isFalse,
      );
    });
  });
}
