import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/widgets/lesson_progress_rollup.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_progress_line.dart';
import 'package:brew_path/features/profile/presentation/widgets/streak_card.dart';
import 'package:brew_path/features/profile/presentation/widgets/tree_hero_card.dart';
import 'package:brew_path/features/progress/presentation/tree_ladder.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
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

  testWidgets('the preferences promise nothing Settings already has', (
    tester,
  ) async {
    await openProfile(tester);

    // The reminder and the theme used to sit here reading "Soon"; both ship in
    // Settings now, so a tile promising them would be offering a learner
    // something they already have (#395).
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);
    expect(find.text('Daily reminder'), findsNothing);
    expect(find.text('Theme'), findsNothing);
    expect(find.text('Soon'), findsNothing);
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

  testWidgets('closes with the month this install was created', (tester) async {
    // The harness builds the database inside the test, so the install stamp is
    // this run's own clock — and the line is there before any lesson is
    // finished, which is the whole change (#447).
    await openProfile(tester);

    expect(
      find.text('Joined ${monthYear(DateTime.now())}'.toUpperCase()),
      findsOneWidget,
    );
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
