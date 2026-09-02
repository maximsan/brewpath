import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/features/cards/presentation/card_challenge_corner.dart';
import 'package:brew_path/features/cards/presentation/card_sheet.dart';
import 'package:brew_path/features/cards/presentation/card_tint.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

/// Four cards: two earned, then the teaser, so a gap in the numbering exists
/// to assert on.
final List<CardWithCollection> _collection = [
  testCardWithCollection('a', collected: true),
  testCardWithCollection('b', collected: true, kind: 'burrs'),
  testCardWithCollection('c', collected: false),
  testCardWithCollection('d', collected: false),
];

Future<void> _pump(
  WidgetTester tester, {
  Set<String> completedChallenges = const {},
  BrewChallenge? active,
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
        activeChallengeProvider.overrideWith((ref) async => active),
      ],
      child: MaterialApp(
        theme: AppTheme.cupping,
        home: const CardsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The surface a tile is actually painted on.
Color _surfaceOf(WidgetTester tester, String title) {
  final material = tester.widget<Material>(
    find.ancestor(of: find.text(title), matching: find.byType(Material)).first,
  );
  return material.color!;
}

void main() {
  group('a locked tile', () {
    testWidgets('says which card it is, not ???', (tester) async {
      await _pump(tester);

      // The whole point: one locked tile is on screen and it is the next card
      // the learner will earn, so naming its place makes it a known gap.
      expect(find.text('03 / 4'), findsOneWidget);
      expect(find.text('???'), findsNothing);
    });

    testWidgets('draws the dash and the question mark', (tester) async {
      await _pump(tester);

      expect(find.text('—'), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('opens nothing', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('?'));
      await tester.pumpAndSettle();

      expect(find.byType(CardSheetBody), findsNothing);
    });
  });

  group('an earned tile', () {
    testWidgets('carries its place in the set', (tester) async {
      await _pump(tester);

      expect(find.text('CARD 01 / 4'), findsOneWidget);
      expect(find.text('CARD 02 / 4'), findsOneWidget);
    });

    testWidgets('wears its own kind, not one wash for all', (tester) async {
      await _pump(tester);

      // `botanical` is washed sage and `burrs` ink. Equal surfaces would mean
      // the tint is keyed by nothing.
      expect(_surfaceOf(tester, 'Card a'), isNot(_surfaceOf(tester, 'Card b')));
    });

    testWidgets('takes the tint the design gives its kind', (tester) async {
      await _pump(tester);

      final mood = AppTheme.cupping.extension<MoodColors>()!;
      expect(_surfaceOf(tester, 'Card a'), cardTint(mood, 'botanical'));
    });

    testWidgets('opens its card', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Card a'));
      await tester.pumpAndSettle();

      expect(find.byType(CardSheetBody), findsOneWidget);
    });
  });

  group('the challenge corner', () {
    testWidgets('is absent when no challenge is in play', (tester) async {
      await _pump(tester);

      expect(find.byType(CardChallengeCorner), findsNothing);
    });

    testWidgets('stamps a card whose challenge is brewed', (tester) async {
      await _pump(tester, completedChallenges: const {'bc-m1'});

      final corner = tester.widget<CardChallengeCorner>(
        find.byType(CardChallengeCorner),
      );
      expect(corner.state, CardChallengeState.tried);
    });

    testWidgets('rings a card whose challenge is waiting', (tester) async {
      await _pump(tester, active: testChallenge(cardId: 'a'));

      final corner = tester.widget<CardChallengeCorner>(
        find.byType(CardChallengeCorner),
      );
      expect(corner.state, CardChallengeState.open);
    });
  });
}
