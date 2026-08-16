import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Slider mini-game: the user drags a value into the target range.
class SliderGame extends StatefulWidget {
  /// Creates a [SliderGame].
  const SliderGame({
    required this.step,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The slider step's content/config.
  final SliderStep step;

  /// Fired once, only when the answer is correct.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

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
    // Latched above, so this can only ever fire once.
    if (_inRange) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
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
              color: _inRange ? mood.sage : mood.berry,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.step.explanation),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.onContinue,
            child: const Text(AppLabels.continueLabel),
          ),
        ],
      ],
    );
  }
}
