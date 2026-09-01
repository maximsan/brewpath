import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/widgets/lesson_progress_rollup.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_progress_line.dart';
import 'package:brew_path/features/profile/presentation/widgets/streak_card.dart';
import 'package:brew_path/features/profile/presentation/widgets/tree_hero_card.dart';
import 'package:brew_path/features/progress/presentation/tree_ladder.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:brew_path/features/studio/presentation/studio_door_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/find_mark.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> openProfile(WidgetTester tester) async {
    // Tall surface so the Profile slivers lay out inside the viewport —
    // otherwise virtualization keeps the lower cards out of the widget tree.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
  }

  testWidgets('opens with the tree hero, then the streak', (tester) async {
    await openProfile(tester);

    expect(find.byType(TreeHeroCard), findsOneWidget);
    expect(find.byType(StreakCard), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(TreeHeroCard)).dy,
      lessThan(tester.getTopLeft(find.byType(StreakCard)).dy),
      reason: 'the design leads with the tree — it is the "I am growing" cue',
    );
  });

  testWidgets('the hero names the stage and the course position', (
    tester,
  ) async {
    await openProfile(tester);

    // A fresh learner: stage 1, nothing finished yet.
    expect(find.textContaining('Stage 1 · '), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'0 / \d+ CORE LESSONS')),
      findsOneWidget,
    );
  });

  testWidgets('carries no settings — the gear is the only way to them', (
    tester,
  ) async {
    await openProfile(tester);

    // The design keeps no preferences on Profile at all (#429). The app had
    // grown a `Customize` grid of them beside the heading of that name.
    expect(find.text('Customize'), findsNothing);
    for (final tile in ['Sound', 'Haptics', 'Daily reminder', 'Theme']) {
      expect(
        find.text(tile),
        findsNothing,
        reason: '$tile belongs to Settings',
      );
    }
    // Every shape a preference control comes in: the Material switch, the
    // Cupertino one `Switch.adaptive` becomes on iOS, and the settings row
    // that carries its own toggle. Guarding only the first would let the
    // grid back in wearing either of the other two.
    for (final control in [Switch, CupertinoSwitch, SettingsNavRow]) {
      expect(
        find.byType(control),
        findsNothing,
        reason: "a $control changes a preference, and that is Settings' work",
      );
    }
  });

  testWidgets('keeps the Studio door the heading used to sit over', (
    tester,
  ) async {
    // Deleting the grid takes its heading with it, not the door beneath —
    // that entry is #428's to redraw, not this slice's to remove.
    await openProfile(tester);

    expect(find.byType(StudioDoorTile), findsOneWidget);
  });

  testWidgets('the three stat tiles become one line', (tester) async {
    await openProfile(tester);

    expect(find.byType(ProfileProgressLine), findsOneWidget);
    expect(find.text('0 LESSONS · 0 POINTS'), findsOneWidget);
    expect(
      find.text('Total points'),
      findsNothing,
      reason: 'the stat grid is gone; the design counts in one quiet line',
    );
  });

  testWidgets('the rollup stays away until a lesson holds a score', (
    tester,
  ) async {
    await openProfile(tester);

    expect(
      find.byType(LessonProgressRollup),
      findsNothing,
      reason:
          'an empty bar under a heading reads as "you are behind" to someone '
          'who has simply not started',
    );
  });

  testWidgets('the streak card carries the mark, the count and the week', (
    tester,
  ) async {
    await openProfile(tester);

    expect(find.text('0 days'), findsOneWidget);
    expect(find.text('CURRENT STREAK'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(StreakCard),
        matching: find.byType(WeekStrip),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the streak card opens the streak screen', (tester) async {
    await openProfile(tester);

    await tester.tap(find.byType(StreakCard));
    await settleLoaders(tester);

    expect(find.text('Your streak'), findsOneWidget);
    // A fresh user: no qualifying day yet, the full earn ahead.
    expect(find.text('Next freeze in 7 days'), findsOneWidget);
  });

  testWidgets('the hero opens the tree screen', (tester) async {
    await openProfile(tester);

    await tester.tap(find.byType(TreeHeroCard));
    // The tree sways for as long as it is on screen, so `pumpAndSettle` spins
    // forever there. Long enough to cover the route transition.
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // The ladder of ten stages belongs to that screen and nowhere else.
    expect(find.byType(TreeLadder), findsOneWidget);
  });

  testWidgets('carries no paywall pitch — the design has no slot for one', (
    tester,
  ) async {
    await openProfile(tester);

    // Three rulings broke in one card, so three things to stay gone:
    // "Premium" where the glossary says Plus, subscription language against
    // the one-time purchase (#55), and an ads promise the design never makes.
    // Matched case-insensitively — sentence-case copy is the same pitch.
    for (final copy in ['premium', 'subscription', 'remove ads']) {
      expect(
        find.textContaining(RegExp(copy, caseSensitive: false)),
        findsNothing,
        reason: '"$copy" is paywall copy the Profile design does not carry',
      );
    }
  });

  testWidgets('header gear opens the Settings screen', (tester) async {
    await openProfile(tester);

    await tester.tap(findMark(AppIcon.gear));
    await settleLoaders(tester);

    // Twice: the bar, and the display heading the sections hang under — which
    // is how the design draws every one of these screens
    // (`prototype/screens.jsx:523`).
    expect(find.text(SettingsCopy.title), findsNWidgets(2));
    expect(find.text(SettingsCopy.resetProgressRow), findsOneWidget);
  });
}
