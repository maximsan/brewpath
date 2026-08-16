import 'package:brew_path/features/mini_games/presentation/multiple_choice_game.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _step = MultipleChoiceStep(
  question: 'Where is the Bean Belt?',
  options: ['Poles', 'Tropics', 'Deserts'],
  correctIndex: 1,
  explanation: 'Coffee grows in the tropics.',
);

/// Answers the step and reports how many times success crossed the boundary.
Future<int> _solvedBy(WidgetTester tester, String option) async {
  var solved = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MultipleChoiceGame(
          step: _step,
          onSolved: () => solved++,
          onContinue: () {},
        ),
      ),
    ),
  );
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
  return solved;
}

void main() {
  testWidgets('renders question and all options', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceGame(
            step: _step,
            onSolved: () {},
            onContinue: () {},
          ),
        ),
      ),
    );
    expect(find.text('Where is the Bean Belt?'), findsOneWidget);
    expect(find.text('Tropics'), findsOneWidget);
  });

  testWidgets('a correct answer reports success once', (tester) async {
    expect(await _solvedBy(tester, 'Tropics'), 1);
  });

  testWidgets('a wrong answer reports nothing', (tester) async {
    expect(await _solvedBy(tester, 'Poles'), 0);
  });

  testWidgets('continue is separate from success', (tester) async {
    var advanced = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceGame(
            step: _step,
            onSolved: () {},
            onContinue: () => advanced++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Poles'));
    await tester.pumpAndSettle();
    expect(advanced, 0);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(advanced, 1);
  });
}
