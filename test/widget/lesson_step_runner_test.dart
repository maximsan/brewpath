import 'package:brew_path/features/mini_games/presentation/drag_drop_game.dart';
import 'package:brew_path/features/mini_games/presentation/lesson_step_runner.dart';
import 'package:brew_path/features/mini_games/presentation/multiple_choice_game.dart';
import 'package:brew_path/features/mini_games/presentation/slider_game.dart';
import 'package:brew_path/features/mini_games/presentation/tap_order_game.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, LessonStepModel step) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LessonStepRunner(
              step: step,
              onSolved: () {},
              onContinue: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('dispatches each step type to its game widget', (tester) async {
    await pump(
      tester,
      const MultipleChoiceStep(
        question: 'Q',
        options: ['a', 'b'],
        correctIndex: 0,
        explanation: 'e',
      ),
    );
    expect(find.byType(MultipleChoiceGame), findsOneWidget);

    await pump(
      tester,
      const DragDropStep(instruction: 'i', terms: ['t1'], definitions: ['d1']),
    );
    expect(find.byType(DragDropGame), findsOneWidget);

    await pump(
      tester,
      const SliderStep(
        instruction: 'i',
        minValue: 0,
        maxValue: 10,
        targetMin: 4,
        targetMax: 6,
        unit: 'x',
        explanation: 'e',
      ),
    );
    expect(find.byType(SliderGame), findsOneWidget);

    await pump(
      tester,
      const TapOrderStep(instruction: 'i', items: ['x', 'y'], explanation: 'e'),
    );
    expect(find.byType(TapOrderGame), findsOneWidget);
  });
}
