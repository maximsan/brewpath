import 'package:coffee_quest/features/mini_games/domain/mini_game_result.dart';
import 'package:coffee_quest/shared/models/lesson_step_model.dart';
import 'package:flutter/material.dart';

/// Match terms[i] ↔ definitions[i] by dragging. A drop is only accepted when
/// the term index equals the definition index; wrong drops bounce back with no
/// penalty. Auto-completes when every term is correctly placed.
class DragDropGame extends StatefulWidget {
  const DragDropGame({super.key, required this.step, required this.onResult});

  final DragDropStep step;
  final void Function(MiniGameResult) onResult;

  @override
  State<DragDropGame> createState() => _DragDropGameState();
}

class _DragDropGameState extends State<DragDropGame> {
  /// definitionIndex -> matched termIndex (absent until correctly placed).
  final Map<int, int> _placed = {};

  bool get _allMatched => _placed.length == widget.step.terms.length;

  void _onAccept(int definitionIndex, int termIndex) {
    if (definitionIndex != termIndex) return; // wrong → bounce back
    setState(() => _placed[definitionIndex] = termIndex);
    if (_allMatched) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onResult(const MiniGameCorrect()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final terms = widget.step.terms;
    final definitions = widget.step.definitions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.step.instruction, style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < terms.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _placed.containsValue(i)
                          ? Chip(
                              label: Text(
                                terms[i],
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                              backgroundColor: colors.primaryContainer,
                            )
                          : Draggable<int>(
                              data: i,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Chip(label: Text(terms[i])),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: Chip(label: Text(terms[i])),
                              ),
                              child: Chip(label: Text(terms[i])),
                            ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  for (var j = 0; j < definitions.length; j++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DragTarget<int>(
                        onAcceptWithDetails: (d) => _onAccept(j, d.data),
                        builder: (context, candidate, rejected) {
                          final done = _placed.containsKey(j);
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: done ? colors.primary : colors.outline,
                                width: done ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(definitions[j]),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
