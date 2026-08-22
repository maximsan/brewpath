import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/profile/presentation/widgets/premium_card.dart';
import 'package:brew_path/features/profile/presentation/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    await tester.tap(find.byIcon(Icons.person_outline));
    await settleLoaders(tester);
  }

  testWidgets('renders header, premium card, and stat grid for a fresh user', (
    tester,
  ) async {
    await openProfile(tester);

    // Header icons.
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // Premium hero card.
    expect(find.byType(PremiumCard), findsOneWidget);

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

  testWidgets('header gear opens the Settings screen', (tester) async {
    await openProfile(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settleLoaders(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Reset Progress'), findsOneWidget);
  });
}
