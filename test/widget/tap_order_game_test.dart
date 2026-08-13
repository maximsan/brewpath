import 'package:brew_path/features/mini_games/domain/mini_game_result.dart';
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
  testWidgets('tapping items in correct order emits MiniGameCorrect', (
    tester,
  ) async {
    MiniGameResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TapOrderGame(step: _step, onResult: (r) => result = r),
        ),
      ),
    );

    for (final item in _step.items) {
      await tester.tap(find.widgetWithText(ActionChip, item));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byType(FilledButton)); // Continue
    await tester.pumpAndSettle();

    expect(result, isA<MiniGameCorrect>());
  });
}
