import 'package:brew_path/features/mini_games/presentation/slider_game.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Midpoint = 90, which falls inside the 85–96 target range.
const _step = SliderStep(
  instruction: 'Set the brew water temperature',
  minValue: 80,
  maxValue: 100,
  targetMin: 85,
  targetMax: 96,
  unit: '°C',
  explanation: 'Ideal extraction is 90–96°C.',
);

void main() {
  testWidgets('a value inside the target range reports success once', (
    tester,
  ) async {
    var solved = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SliderGame(
            step: _step,
            onSolved: () => solved++,
            onContinue: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(solved, 1);
  });
}
