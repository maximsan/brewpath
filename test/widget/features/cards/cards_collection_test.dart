import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/features/cards/presentation/cards_footer.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// Pumps the screen over a fixed collection, with no database behind it — the
/// screen's whole job here is what it does with the list it is handed.
Future<void> _pump(
  WidgetTester tester,
  List<CardWithCollection> collection,
) async {
  tester.view.physicalSize = const Size(420, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cardsWithCollectionProvider.overrideWith((ref) async => collection),
      ],
      child: MaterialApp(
        theme: AppTheme.darkRoast,
        home: const CardsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Four cards, one earned — so the grid has something to hide.
final List<CardWithCollection> _mostlyLocked = [
  testCardWithCollection('a', collected: true),
  testCardWithCollection('b', collected: false),
  testCardWithCollection('c', collected: false),
  testCardWithCollection('d', collected: false),
];

void main() {
  testWidgets('draws the earned cards and exactly one locked teaser', (
    tester,
  ) async {
    await _pump(tester, _mostlyLocked);

    expect(find.byType(CardGridItemWidget), findsNWidgets(2));
    expect(find.text('Card a'), findsOneWidget);
    // The teaser shows as a locked tile; the two behind it are not drawn.
    expect(find.text('02 / 4'), findsOneWidget);
  });

  testWidgets('the footer counts the remainder, teaser included', (
    tester,
  ) async {
    await _pump(tester, _mostlyLocked);

    // Three uncollected, one of them the tile on screen. Naming two would be
    // counting only what the learner cannot see.
    expect(find.text('3 more to collect'), findsOneWidget);
    expect(find.text('Finish lessons to reveal new cards.'), findsOneWidget);
  });

  testWidgets('a complete collection drops the footer entirely', (
    tester,
  ) async {
    await _pump(tester, [
      testCardWithCollection('a', collected: true),
      testCardWithCollection('b', collected: true),
    ]);

    expect(find.byType(CardGridItemWidget), findsNWidgets(2));
    expect(find.byType(CardsFooter), findsNothing);
    expect(find.text('?'), findsNothing);
  });

  testWidgets('a fresh collection is one teaser, not a wall of blanks', (
    tester,
  ) async {
    await _pump(tester, [
      testCardWithCollection('a', collected: false),
      testCardWithCollection('b', collected: false),
      testCardWithCollection('c', collected: false),
    ]);

    expect(find.byType(CardGridItemWidget), findsOneWidget);
    expect(find.text('3 more to collect'), findsOneWidget);
  });

  testWidgets('the count line is the whole header — no prose, no bar', (
    tester,
  ) async {
    await _pump(tester, _mostlyLocked);

    expect(find.text('1 OF 4'), findsOneWidget);
    expect(
      find.byType(LinearProgressIndicator),
      findsNothing,
      reason: 'the grid is the progress; a bar restates it',
    );
    // The prose the count replaced. That the tab's *title* is not said twice
    // needs the shell above it, so it is asserted in `cards_screen_test.dart`.
    expect(find.textContaining('cards collected'), findsNothing);
  });

  testWidgets('the grid is flat — no module sections above the tiles', (
    tester,
  ) async {
    await _pump(tester, [
      testCardWithCollection('a', collected: true),
      testCardWithCollection('z', collected: true, moduleTag: 'Taste'),
    ]);

    // The two cards carry different module tags; neither becomes a heading.
    // Stronger than it was: the design's tile prints no tag at all
    // (`screens.jsx:2447`), so a module name anywhere on this screen could
    // only be a section header — which is the thing being ruled out.
    expect(find.byType(CardGridItemWidget), findsNWidgets(2));
    expect(find.text('Card a'), findsOneWidget);
    expect(find.text('Card z'), findsOneWidget);
    expect(find.text('Beans'), findsNothing);
    expect(find.text('Taste'), findsNothing);
  });

  testWidgets('the count and the remainder are spoken', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, _mostlyLocked);

    expect(find.bySemanticsLabel('1 of 4 cards collected'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '3 more to collect. Finish lessons to reveal new cards.',
      ),
      findsOneWidget,
      reason: 'a dashed box and a lock glyph say nothing to a screen reader',
    );
    handle.dispose();
  });
}
