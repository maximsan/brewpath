import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Row of chips, one per supported game type. Each chip is enabled only when
/// at least one step of that type lives in a completed lesson.
class PracticeByGameTypeWidget extends StatelessWidget {
  /// Creates a [PracticeByGameTypeWidget].
  const PracticeByGameTypeWidget({required this.counts, super.key});

  /// `gameType` discriminator → number of practiceable steps in completed
  /// lessons.
  final Map<String, int> counts;

  static const double _chipGap = 8;
  static const double _iconSm = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Wrap(
      spacing: _chipGap,
      runSpacing: _chipGap,
      children: [
        for (final entry in gameTypeLabels)
          () {
            final key = entry.$1;
            final label = entry.$2;
            final count = counts[key] ?? 0;
            final enabled = count > 0;
            return ActionChip(
              avatar: Icon(
                _iconFor(key),
                size: _iconSm,
                color: enabled ? mood.accent : mood.inkMute,
              ),
              label: Text(
                enabled ? '$label ($count)' : label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: enabled ? mood.ink : mood.inkMute,
                ),
              ),
              onPressed: enabled
                  ? () => context.go('/learn/practice/game-type/$key')
                  : null,
            );
          }(),
      ],
    );
  }

  IconData _iconFor(String gameType) => switch (gameType) {
    'multiple_choice' => Icons.check_box_outlined,
    'drag_drop' => Icons.compare_arrows,
    'tap_order' => Icons.format_list_numbered,
    'slider' => Icons.tune,
    _ => Icons.extension_outlined,
  };
}
