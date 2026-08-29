import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:brew_path/features/profile/presentation/widgets/stat_tile.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/find_mark.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> openProfile(WidgetTester tester) async {
    // Tall surface so the Profile slivers lay out the full grid inside the
    // viewport — otherwise virtualization keeps tiles out of the widget tree.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
  }

  testWidgets('renders header and stat grid for a fresh user', (
    tester,
  ) async {
    await openProfile(tester);

    // Header icons.
    expect(findMark(AppIcon.gear), findsOneWidget);

    // 2x2 stats grid.
    expect(find.byType(StatTile), findsNWidgets(4));
    expect(find.text('Total points'), findsOneWidget);
    expect(find.text('Day streak'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);
    // "Cards" also appears as the bottom-nav tab label — scope to the tile.
    expect(
      find.descendant(of: find.byType(StatTile), matching: find.text('Cards')),
      findsOneWidget,
    );

    // Customize tiles.
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);
    expect(find.text('Daily reminder'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
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

  testWidgets('the Day streak tile opens the streak screen', (tester) async {
    await openProfile(tester);

    await tester.tap(find.text('Day streak'));
    await settleLoaders(tester);

    expect(find.text('Your streak'), findsOneWidget);
    // A fresh user: no qualifying day yet, the full earn ahead.
    expect(find.text('Next freeze in 7 days'), findsOneWidget);
  });

  testWidgets('the Day streak tile carries the small week strip', (
    tester,
  ) async {
    await openProfile(tester);

    expect(
      find.descendant(
        of: find.byType(StatTile),
        matching: find.byType(WeekStrip),
      ),
      findsOneWidget,
    );
  });

  testWidgets('header gear opens the Settings screen', (tester) async {
    await openProfile(tester);

    await tester.tap(findMark(AppIcon.gear));
    await settleLoaders(tester);

    expect(find.text(SettingsCopy.title), findsOneWidget);
    expect(find.text(SettingsCopy.resetProgressRow), findsOneWidget);
  });
}
