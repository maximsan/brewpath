import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/mini_games/presentation/drag_drop_game.dart';
import 'package:brew_path/features/mini_games/presentation/multiple_choice_game.dart';
import 'package:brew_path/features/mini_games/presentation/slider_game.dart';
import 'package:brew_path/features/mini_games/presentation/tap_order_game.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:flutter/material.dart';

/// Dispatches a [LessonStepModel] variant to its mini-game widget. The sealed
/// union makes the switch exhaustive — adding a variant is a compile error
/// until a case is added here.
class LessonStepRunner extends StatelessWidget {
  /// Creates a [LessonStepRunner].
  const LessonStepRunner({
    required this.step,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The lesson step to render.
  final LessonStepModel step;

  /// Fired once, only when the step is answered correctly.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      final MultipleChoiceStep s => MultipleChoiceGame(
        step: s,
        onSolved: onSolved,
        onContinue: onContinue,
      ),
      final DragDropStep s => DragDropGame(
        step: s,
        onSolved: onSolved,
        onContinue: onContinue,
      ),
      final SliderStep s => SliderGame(
        step: s,
        onSolved: onSolved,
        onContinue: onContinue,
      ),
      final TapOrderStep s => TapOrderGame(
        step: s,
        onSolved: onSolved,
        onContinue: onContinue,
      ),
    };
  }
}
