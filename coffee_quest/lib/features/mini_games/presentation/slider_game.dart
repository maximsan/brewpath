import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/features/mini_games/domain/mini_game_result.dart';
import 'package:coffee_quest/shared/models/lesson_step_model.dart';
import 'package:flutter/material.dart';

class SliderGame extends StatefulWidget {
  const SliderGame({required this.step, required this.onResult, super.key});

  final SliderStep step;
  final void Function(MiniGameResult) onResult;

  @override
  State<SliderGame> createState() => _SliderGameState();
}

class _SliderGameState extends State<SliderGame> {
  late double _value = (widget.step.minValue + widget.step.maxValue) / 2;
  bool _answered = false;

  bool get _inRange =>
      _value >= widget.step.targetMin && _value <= widget.step.targetMax;

  void _onCheck() {
    setState(() => _answered = true);
  }

  void _onContinue() {
    widget.onResult(
      _inRange
          ? const MiniGameCorrect()
          : MiniGameIncorrect(hint: widget.step.explanation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unit = widget.step.unit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.step.instruction, style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        Text(
          '${_value.toStringAsFixed(0)} $unit',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        Slider(
          value: _value,
          min: widget.step.minValue,
          max: widget.step.maxValue,
          onChanged: _answered ? null : (v) => setState(() => _value = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.step.minValue.toStringAsFixed(0)} $unit'),
            Text('${widget.step.maxValue.toStringAsFixed(0)} $unit'),
          ],
        ),
        const SizedBox(height: 24),
        if (!_answered)
          FilledButton(onPressed: _onCheck, child: const Text('Check'))
        else ...[
          Text(
            _inRange
                ? 'Correct!'
                : 'Target range: ${widget.step.targetMin.toStringAsFixed(0)}'
                      '–${widget.step.targetMax.toStringAsFixed(0)} $unit',
            style: TextStyle(
              color: _inRange ? Colors.green.shade600 : colors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.step.explanation),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _onContinue,
            child: Text(
              _inRange ? AppStrings.continueLabel : AppStrings.tryAgainLabel,
            ),
          ),
        ],
      ],
    );
  }
}
