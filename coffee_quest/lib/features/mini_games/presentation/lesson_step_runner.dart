import 'package:coffee_quest/features/mini_games/domain/mini_game_result.dart';
import 'package:coffee_quest/features/mini_games/presentation/drag_drop_game.dart';
import 'package:coffee_quest/features/mini_games/presentation/multiple_choice_game.dart';
import 'package:coffee_quest/features/mini_games/presentation/slider_game.dart';
import 'package:coffee_quest/features/mini_games/presentation/tap_order_game.dart';
import 'package:coffee_quest/shared/models/lesson_step_model.dart';
import 'package:flutter/material.dart';

/// Dispatches a [LessonStepModel] variant to its mini-game widget. The sealed
/// union makes the switch exhaustive — adding a variant is a compile error
/// until a case is added here.
class LessonStepRunner extends StatelessWidget {
  const LessonStepRunner({
    required this.step, required this.onResult, super.key,
  });

  final LessonStepModel step;
  final void Function(MiniGameResult result) onResult;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      final MultipleChoiceStep s => MultipleChoiceGame(
        step: s,
        onResult: onResult,
      ),
      final DragDropStep s => DragDropGame(step: s, onResult: onResult),
      final SliderStep s => SliderGame(step: s, onResult: onResult),
      final TapOrderStep s => TapOrderGame(step: s, onResult: onResult),
    };
  }
}
