import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/features/cards/presentation/cards_footer.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CardWithCollection _card(String id, {required bool collected}) =>
    CardWithCollection(
      card: CoffeeCardModel(
        id: id,
        title: 'Card $id',
        description: 'A card called $id.',
        fact: 'A fact about $id.',
        moduleTag: 'BEANS',
        iconName: 'beans',
      ),
      isCollected: collected,
    );

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
  _card('a', collected: true),
  _card('b', collected: false),
  _card('c', collected: false),
  _card('d', collected: false),
];

void main() {
  testWidgets('draws the earned cards and exactly one locked teaser', (
    tester,
  ) async {
    await _pump(tester, _mostlyLocked);

    expect(find.byType(CardGridItemWidget), findsNWidgets(2));
    expect(find.text('Card a'), findsOneWidget);
    // The teaser shows as a locked tile; the two behind it are not drawn.
    expect(find.text('???'), findsOneWidget);
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
      _card('a', collected: true),
      _card('b', collected: true),
    ]);

    expect(find.byType(CardGridItemWidget), findsNWidgets(2));
    expect(find.byType(CardsFooter), findsNothing);
    expect(find.text('???'), findsNothing);
  });

  testWidgets('a fresh collection is one teaser, not a wall of blanks', (
    tester,
  ) async {
    await _pump(tester, [
      _card('a', collected: false),
      _card('b', collected: false),
      _card('c', collected: false),
    ]);

    expect(find.byType(CardGridItemWidget), findsOneWidget);
    expect(find.text('3 more to collect'), findsOneWidget);
  });

  testWidgets('the count line is the whole header — no title, no bar', (
    tester,
  ) async {
    await _pump(tester, _mostlyLocked);

    expect(find.text('1 OF 4'), findsOneWidget);
    expect(
      find.byType(LinearProgressIndicator),
      findsNothing,
      reason: 'the grid is the progress; a bar restates it',
    );
    expect(
      find.text('Collection'),
      findsNothing,
      reason: 'the tab name is the shared header, never said twice',
    );
  });

  testWidgets('the grid is flat — no module sections above the tiles', (
    tester,
  ) async {
    await _pump(tester, [
      _card('a', collected: true),
      const CardWithCollection(
        card: CoffeeCardModel(
          id: 'z',
          title: 'Card z',
          description: 'From another module.',
          fact: 'A fact.',
          moduleTag: 'TASTE',
          iconName: 'taste',
        ),
        isCollected: true,
      ),
    ]);

    // The two cards carry different module tags; neither becomes a heading.
    expect(find.byType(CardGridItemWidget), findsNWidgets(2));
    expect(find.text('BEANS'), findsOneWidget);
    expect(find.text('TASTE'), findsOneWidget);
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
