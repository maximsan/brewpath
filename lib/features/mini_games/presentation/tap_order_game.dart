import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/shared/models/lesson_step_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Tap-order mini-game: tap items into the correct sequence.
class TapOrderGame extends StatefulWidget {
  /// Creates a [TapOrderGame].
  const TapOrderGame({
    required this.step,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The tap-order step's content/config.
  final TapOrderStep step;

  /// Fired once, only when the answer is correct.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<TapOrderGame> createState() => _TapOrderGameState();
}

class _TapOrderGameState extends State<TapOrderGame> {
  static const _eq = ListEquality<String>();

  late List<String> _pool;
  final List<String> _selected = [];
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _pool = _shuffledPool();
  }

  List<String> _shuffledPool() {
    final items = widget.step.items;
    if (items.length < 2) return List.of(items);
    var shuffled = List.of(items)..shuffle();
    // Avoid handing the user the answer already in order.
    while (_eq.equals(shuffled, items)) {
      shuffled = List.of(items)..shuffle();
    }
    return shuffled;
  }

  bool get _correct => _eq.equals(_selected, widget.step.items);

  void _onTap(String item) {
    if (_answered) return;
    setState(() {
      _selected.add(item);
      _pool.remove(item);
      if (_selected.length == widget.step.items.length) _answered = true;
    });
    // Latched above, so this can only ever fire once.
    if (_answered && _correct) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.step.instruction, style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [for (final item in _selected) Chip(label: Text(item))],
        ),
        const Divider(height: 32),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final item in _pool)
              ActionChip(
                label: Text(item),
                onPressed: _answered ? null : () => _onTap(item),
              ),
          ],
        ),
        const SizedBox(height: 24),
        if (_answered) ...[
          Text(
            _correct
                ? 'Correct!'
                : 'Correct order: ${widget.step.items.join(' → ')}',
            style: TextStyle(
              color: _correct ? mood.sage : mood.berry,
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
