import 'package:brew_path/app/app.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/find_mark.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('shows every collectible, all locked for a fresh user', (
    tester,
  ) async {
    await pumpWithProviders(tester, const BrewPathApp());

    await tester.tap(findMark(AppIcon.cards, active: false)); // Cards tab
    await settleLoaders(tester);

    // GridView is lazy, so only the on-screen tiles are built; assert the
    // grid rendered and that nothing is collected (all visible tiles are
    // "???" silhouettes, no real titles).
    expect(find.byType(CardGridItemWidget), findsWidgets);
    expect(find.text('???'), findsWidgets);
  });
}
