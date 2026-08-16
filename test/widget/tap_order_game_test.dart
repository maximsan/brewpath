import 'package:brew_path/features/mini_games/presentation/tap_order_game.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _step = TapOrderStep(
  instruction: 'Order roast levels light → dark',
  items: ['Light', 'Medium', 'Dark'],
  explanation: 'Roast darkens with time.',
);

void main() {
  testWidgets('the correct order reports success once', (tester) async {
    var solved = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TapOrderGame(
            step: _step,
            onSolved: () => solved++,
            onContinue: () {},
          ),
        ),
      ),
    );

    for (final item in _step.items) {
      await tester.tap(find.widgetWithText(ActionChip, item));
      await tester.pumpAndSettle();
    }

    expect(solved, 1);
  });
}
