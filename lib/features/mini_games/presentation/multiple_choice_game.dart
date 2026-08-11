import 'package:brew_path/core/constants/app_strings.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_result.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Multiple-choice mini-game: pick the correct option.
class MultipleChoiceGame extends StatefulWidget {
  /// Creates a [MultipleChoiceGame].
  const MultipleChoiceGame({
    required this.step,
    required this.onResult,
    super.key,
  });

  /// The multiple-choice step's content/config.
  final MultipleChoiceStep step;

  /// Called with the [MiniGameResult] when answered.
  final void Function(MiniGameResult) onResult;

  @override
  State<MultipleChoiceGame> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame> {
  int? _selectedIndex;
  bool _answered = false;

  void _onOptionTap(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
    });
  }

  void _onContinue() {
    final isCorrect = _selectedIndex == widget.step.correctIndex;
    widget.onResult(
      isCorrect
          ? const MiniGameCorrect()
          : MiniGameIncorrect(hint: widget.step.explanation),
    );
  }

  /// Feedback border for an option after the user answers: sage for the
  /// correct option, berry for the wrong selection, default outline
  /// otherwise. Returns `null` until an answer is locked in.
  Color? _borderColor(int index, MoodColors mood) {
    if (!_answered) return null;
    if (index == widget.step.correctIndex) return mood.sage;
    if (index == _selectedIndex) return mood.berry;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final isCorrect = _answered && _selectedIndex == widget.step.correctIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.step.question, style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        for (var i = 0; i < widget.step.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: _answered ? null : () => _onOptionTap(i),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _borderColor(i, mood) ?? mood.rule,
                  width: _borderColor(i, mood) != null ? 2 : 1,
                ),
              ),
              child: Text(widget.step.options[i]),
            ),
          ),
        if (_answered) ...[
          const SizedBox(height: 8),
          Text(widget.step.explanation),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _onContinue,
            child: Text(
              isCorrect ? AppStrings.continueLabel : AppStrings.tryAgainLabel,
            ),
          ),
        ],
      ],
    );
  }
}
