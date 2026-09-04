import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/cards/presentation/reward_card.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

final CoffeeCardModel _card = testCoffeeCard().copyWith(
  title: 'Washed Process',
  description: 'Fruit stripped, then fermented and rinsed.',
  fact: 'A washed coffee tastes of the bean, not the fruit around it.',
  moduleTag: 'Processing',
);

Widget _host(Widget child, {bool reducedMotion = true}) => MaterialApp(
  theme: AppTheme.cupping,
  home: Scaffold(body: Center(child: child)),
  builder: (context, inner) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
    child: inner!,
  ),
);

void main() {
  group('the card is the guide', () {
    testWidgets('it carries the badge, the name, the summary and the fact', (
      tester,
    ) async {
      await tester.pumpWidget(_host(RewardCard(card: _card)));
      await tester.pumpAndSettle();

      expect(find.text(_card.moduleTag.toUpperCase()), findsOneWidget);
      expect(find.text(_card.title), findsOneWidget);
      expect(find.text(_card.description), findsOneWidget);
      // The keepsake line the app assembled and rendered nowhere.
      expect(find.text(_card.fact), findsOneWidget);
      expect(
        find.text(RewardCard.memorableLabel.toUpperCase()),
        findsOneWidget,
      );
    });

    // "Deliberately no points total: points are paid per lesson and reported
    // by the completion chip."
    testWidgets('and pointedly no points', (tester) async {
      await tester.pumpWidget(_host(RewardCard(card: _card)));
      await tester.pumpAndSettle();

      expect(find.textContaining('PTS'), findsNothing);
    });

    testWidgets('it lands at rest under reduced motion', (tester) async {
      await tester.pumpWidget(_host(RewardCard(card: _card)));
      await tester.pump();

      final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
      expect(opacity.opacity, 1);
    });
  });
}
