import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/features/cards/presentation/card_sheet.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/tried_seal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// One earned card and one still locked, so both tap rules can be checked.
final List<CardWithCollection> _collection = [
  testCardWithCollection('a', collected: true),
  testCardWithCollection('b', collected: false),
];

Future<void> _pump(
  WidgetTester tester, {
  String? openCardId,
  Set<String> completedChallenges = const {},
}) async {
  tester.view.physicalSize = const Size(420, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cardsWithCollectionProvider.overrideWith((ref) async => _collection),
        challengeBankProvider.overrideWith(
          (ref) async => [testChallenge(cardId: 'a')],
        ),
        completedChallengesProvider.overrideWith(
          (ref) async => completedChallenges,
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkRoast,
        home: CardsScreen(openCardId: openCardId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('a card opens over the collection', () {
    testWidgets('tapping an earned tile raises the sheet, grid intact', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.text('Card a'));
      await tester.pumpAndSettle();

      expect(find.byType(CardSheetBody), findsOneWidget);
      // The point of a sheet: the collection is still there behind it, so
      // closing costs the learner nothing.
      expect(find.byType(CardGridItemWidget), findsWidgets);
    });

    testWidgets('closing puts the learner back on the grid', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Card a'));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(CardSheetBody))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(CardSheetBody), findsNothing);
      expect(find.byType(CardGridItemWidget), findsWidgets);
    });

    testWidgets('a locked tile opens nothing', (tester) async {
      await _pump(tester);

      await tester.tap(find.byType(CardGridItemWidget).last);
      await tester.pumpAndSettle();

      expect(find.byType(CardSheetBody), findsNothing);
    });

    testWidgets('the card route lands on the grid with the sheet up', (
      tester,
    ) async {
      // #171 scopes universal links to the card route, so the link has to
      // keep resolving even though the screen it pointed at is gone.
      await _pump(tester, openCardId: 'a');

      expect(find.byType(CardSheetBody), findsOneWidget);
      expect(find.byType(CardGridItemWidget), findsWidgets);
    });

    testWidgets('an unknown card id lands on the grid alone', (tester) async {
      await _pump(tester, openCardId: 'no-such-card');

      expect(find.byType(CardSheetBody), findsNothing);
      expect(find.byType(CardGridItemWidget), findsWidgets);
    });
  });

  group('what the sheet says', () {
    testWidgets('the keepsake line renders, under its label', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Card a'));
      await tester.pumpAndSettle();

      // Assembled and documented as the keepsake line, and drawn nowhere
      // until now — the whole reason a collectible is worth keeping.
      expect(find.text('Something true about it.'), findsOneWidget);
      expect(find.text('FACT'), findsOneWidget);
    });

    testWidgets('no category line under the title', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Card a'));
      await tester.pumpAndSettle();

      // The tile still names the module; the sheet does not repeat it, which
      // is the design's header exactly.
      expect(find.text('Beans'), findsOneWidget);
    });

    testWidgets('a brewed challenge stamps the card', (tester) async {
      await _pump(tester, completedChallenges: const {'bc-m1'});
      await tester.tap(find.text('Card a'));
      await tester.pumpAndSettle();

      expect(find.byType(TriedSeal), findsOneWidget);
    });

    testWidgets('an unbrewed challenge leaves no stamp', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Card a'));
      await tester.pumpAndSettle();

      expect(find.byType(TriedSeal), findsNothing);
    });
  });
}
