import 'package:brew_path/features/mini_games/domain/mini_game_result.dart';
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

Future<MiniGameResult?> _play(WidgetTester tester, String option) async {
  MiniGameResult? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MultipleChoiceGame(step: _step, onResult: (r) => result = r),
      ),
    ),
  );
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(FilledButton)); // Continue / Try Again
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('renders question and all options', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceGame(step: _step, onResult: (_) {}),
        ),
      ),
    );
    expect(find.text('Where is the Bean Belt?'), findsOneWidget);
    expect(find.text('Tropics'), findsOneWidget);
  });

  testWidgets('correct answer emits MiniGameCorrect', (tester) async {
    final result = await _play(tester, 'Tropics');
    expect(result, isA<MiniGameCorrect>());
  });

  testWidgets('wrong answer emits MiniGameIncorrect', (tester) async {
    final result = await _play(tester, 'Poles');
    expect(result, isA<MiniGameIncorrect>());
  });
}
