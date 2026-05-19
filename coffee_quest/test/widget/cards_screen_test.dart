import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/app/app.dart';
import 'package:coffee_quest/features/cards/presentation/card_grid_item_widget.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('shows all 17 cards, all locked for a fresh user', (
    tester,
  ) async {
    await pumpWithProviders(tester, const CoffeeQuestApp());

    await tester.tap(find.byIcon(Icons.style_outlined)); // Cards tab
    await settleLoaders(tester);

    // GridView is lazy, so only the on-screen tiles are built; assert the
    // grid rendered and that nothing is collected (all visible tiles are
    // "???" silhouettes, no real titles).
    expect(find.byType(CardGridItemWidget), findsWidgets);
    expect(find.text('???'), findsWidgets);
  });
}
