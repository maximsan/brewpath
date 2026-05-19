import 'package:flutter/material.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/features/mini_games/domain/mini_game_result.dart';
import 'package:coffee_quest/shared/models/lesson_step_model.dart';

class MultipleChoiceGame extends StatefulWidget {
  const MultipleChoiceGame({
    super.key,
    required this.step,
    required this.onResult,
  });

  final MultipleChoiceStep step;
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

  Color? _borderColor(int index) {
    if (!_answered) return null;
    if (index == widget.step.correctIndex) return Colors.green;
    if (index == _selectedIndex) return Colors.red;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect =
        _answered && _selectedIndex == widget.step.correctIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.step.question,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < widget.step.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: _answered ? null : () => _onOptionTap(i),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _borderColor(i) ??
                      Theme.of(context).colorScheme.outline,
                  width: _borderColor(i) != null ? 2 : 1,
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
              isCorrect
                  ? AppStrings.continueLabel
                  : AppStrings.tryAgainLabel,
            ),
          ),
        ],
      ],
    );
  }
}
