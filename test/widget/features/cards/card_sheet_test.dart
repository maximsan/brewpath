import 'dart:async';

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_deep_link.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/features/cards/presentation/card_locked_face.dart';
import 'package:brew_path/features/cards/presentation/card_sheet.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/tried_seal.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// One earned card and one still locked, so both tap rules can be checked.
final List<CardWithCollection> _collection = [
  testCardWithCollection('a', collected: true),
  testCardWithCollection('b', collected: false),
];

/// The course behind the cards, so an unearned card can name the lesson that
/// earns it through the real lookup rather than a stubbed answer.
class _FakeContent extends ContentRepository {
  @override
  Future<List<LessonModel>> getLessons() async => [testLesson()];
}

final _navigatorKey = GlobalKey<NavigatorState>();

Future<void> _pump(
  WidgetTester tester, {
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
        contentRepositoryProvider.overrideWith((ref) => _FakeContent()),
        challengeBankProvider.overrideWith(
          (ref) async => [testChallenge(cardId: 'a')],
        ),
        completedChallengesProvider.overrideWith(
          (ref) async => completedChallenges,
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkRoast,
        navigatorKey: _navigatorKey,
        home: const CardsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Arrives the way the `cardDetail` route does — a transparent page pushed
/// over the grid, which is what the router builds.
Future<void> _followLink(WidgetTester tester, String cardId) async {
  await _pump(tester);
  unawaited(
    _navigatorKey.currentState!.push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, _, _) => CardDeepLink(cardId: cardId),
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
      await _followLink(tester, 'a');

      expect(find.byType(CardSheetBody), findsOneWidget);
      // The grid under the sheet is the tab's own. The link's page paints
      // nothing, so it cannot be a second copy pushed on top.
      expect(find.byType(CardsScreen), findsOneWidget);
    });

    testWidgets('closing a linked card leaves the link route behind', (
      tester,
    ) async {
      await _followLink(tester, 'a');
      Navigator.of(tester.element(find.byType(CardSheetBody))).pop();
      await tester.pumpAndSettle();

      // Otherwise the learner is left on an empty route and has to press back
      // through it to reach the collection they can already see.
      expect(find.byType(CardDeepLink), findsNothing);
      expect(find.byType(CardGridItemWidget), findsWidgets);
    });

    testWidgets('a link to an unearned card shows its face', (tester) async {
      // ADR-0015: the recipient of a shared card has usually not earned it,
      // so showing them nothing empties the feature. They get the face.
      await _followLink(tester, 'b');

      expect(find.byType(CardLockedFace), findsOneWidget);
      expect(find.text('Card b'), findsWidgets);
      expect(
        find.text('Earn this by completing What coffee actually is'),
        findsOneWidget,
      );
    });

    testWidgets('a link to an unearned card withholds its payload', (
      tester,
    ) async {
      // The other half of ADR-0015. Ids read `c1`, `c-m2l1`, so the sheet is
      // reachable by guessing — the summary and the keepsake line are the
      // lesson's reward and stay behind it.
      await _followLink(tester, 'b');

      expect(find.text('What it is.'), findsNothing);
      expect(find.text('Something true about it.'), findsNothing);
      expect(find.text('FACT'), findsNothing);
    });

    testWidgets('an unknown card id lands on the grid alone', (tester) async {
      await _followLink(tester, 'no-such-card');

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
      // is the design's header exactly. Asserted inside the sheet rather than
      // by counting: a global count passes for the wrong reason the day the
      // tile stops drawing its tag.
      expect(
        find.descendant(
          of: find.byType(CardSheetBody),
          matching: find.text('Beans'),
        ),
        findsNothing,
      );
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
