import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/cards/presentation/reward_card.dart';
import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/presentation/roasty_moment.dart';
import 'package:brew_path/features/learn/domain/module_flip.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/features/learn/presentation/module_complete_screen.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/growing_tree.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

final ModuleModel _module = testModule(lessonIds: const ['m1l1']);
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
  bool hasNextModule = true,
  CoffeeCardModel? reward,
}) => ModuleSummary(
  module: _module,
  earnedCards: const [],
  moduleReward: reward ?? _moduleReward,
  hasNextModule: hasNextModule,
  treeStage: 3,
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
  Widget harness(ModuleSummary summary, {bool reducedMotion = false}) =>
      ProviderScope(
        overrides: [
          moduleSummaryProvider('module_beans').overrideWith((ref) => summary),
          streakProvider.overrideWith((ref) => 0),
          companionLinesProvider.overrideWith(
            (ref) => CompanionLines.fromJson(const {
              'moduleComplete': ['Whole module brewed!'],
            }),
          ),
        ],
        child: _app(
          const ModuleCompleteScreen(moduleId: 'module_beans'),
          reducedMotion: reducedMotion,
        ),
      );

  // ⚠️ **Never `pumpAndSettle` on this screen.** The coffee tree sways for as
  // long as it is on screen, so nothing on the celebration face ever settles.
  // Each step pumps the duration it actually waits on.

  /// Taps a face's action and lets the turn finish.
  Future<void> turn(WidgetTester tester, Finder control) async {
    await tester.tap(control);
    await tester.pump();
    await tester.pump(flipDuration);
    await tester.pump();
  }

  /// Plays the opening beat out, leaving the celebration face on screen.
  Future<void> pastTheBeat(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(RoastyMoment.moduleHold);
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

      await tester.pump(RoastyMoment.moduleHold - RoastyMoment.defaultHold);
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
      expect(find.text(AppLabels.rewardUnlocked.toUpperCase()), findsOneWidget);
      expect(find.text(AppLabels.newCollectibleCard), findsOneWidget);
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
      await tester.pumpWidget(harness(_summary(hasNextModule: false)));
      await pastTheBeat(tester);
      await turn(tester, find.text(AppLabels.turnItOver));

      expect(find.text(AppLabels.backToPath), findsOneWidget);
      expect(find.text(AppLabels.beginNextModule), findsNothing);
    });
  });
}
