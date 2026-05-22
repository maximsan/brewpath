import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/features/mini_games/domain/mini_game_result.dart';
import 'package:coffee_quest/shared/models/lesson_step_model.dart';

class TapOrderGame extends StatefulWidget {
  const TapOrderGame({super.key, required this.step, required this.onResult});

  final TapOrderStep step;
  final void Function(MiniGameResult) onResult;

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
  }

  void _reset() {
    setState(() {
      _selected.clear();
      _pool = _shuffledPool();
      _answered = false;
    });
  }

  void _onContinue() {
    widget.onResult(
      _correct
          ? const MiniGameCorrect()
          : MiniGameIncorrect(hint: widget.step.explanation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.step.instruction, style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final item in _selected) Chip(label: Text(item))],
        ),
        const Divider(height: 32),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
              color: _correct ? Colors.green.shade600 : colors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.step.explanation),
          const SizedBox(height: 16),
          if (_correct)
            FilledButton(
              onPressed: _onContinue,
              child: const Text(AppStrings.continueLabel),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _onContinue,
                    child: const Text(AppStrings.tryAgainLabel),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
