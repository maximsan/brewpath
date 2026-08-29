import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/features/cards/presentation/cards_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/find_mark.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  // The tab against the real content bank and a real empty user, under the
  // shell — which is what this file is for. What the screen does with an
  // arbitrary collection is `features/cards/cards_collection_test.dart`'s.
  testWidgets('a fresh user meets one teaser and the whole remainder', (
    tester,
  ) async {
    // Tall enough that the footer below the grid is laid out: a
    // `CustomScrollView` builds its slivers lazily, so at the default 800×600
    // it exists and is never built.
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const BrewPathApp());

    await tester.tap(findMark(AppIcon.cards, active: false)); // Cards tab
    await settleLoaders(tester);

    // This used to assert the grid drew every collectible. It draws one now:
    // nothing is earned, so the teaser is the only tile and the footer names
    // the rest (#396).
    expect(find.byType(CardGridItemWidget), findsOneWidget);
    expect(find.text('???'), findsOneWidget);
    expect(find.byType(CardsFooter), findsOneWidget);
  });

  testWidgets('the tab is titled once, by the shared header', (tester) async {
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithProviders(tester, const BrewPathApp());
    await tester.tap(findMark(AppIcon.cards, active: false));
    await settleLoaders(tester);

    // The screen used to draw a second "Collection" under the header's. This
    // needs the shell to mean anything — under a bare `CardsScreen` there is
    // no header to duplicate, so the assertion could not fail.
    expect(find.text('Collection'), findsOneWidget);
  });
}
