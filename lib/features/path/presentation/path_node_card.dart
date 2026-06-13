import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:flutter/material.dart';

/// The content panel beside a path node: module icon, title, and progress.
class PathNodeCard extends StatelessWidget {
  /// Creates a [PathNodeCard].
  const PathNodeCard({required this.item, required this.onTap, super.key});

  /// The module paired with its progress.
  final ModuleWithProgress item;

  /// Invoked when the card is tapped.
  final VoidCallback onTap;

  static const double _cardRadius = 12;
  static const double _badgeSize = 40;
  static const double _badgeRadius = 10;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final module = item.module;
    final locked = item.isLocked;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: locked
                      ? colors.surfaceContainerHighest
                      : colors.primaryContainer,
                  borderRadius: BorderRadius.circular(_badgeRadius),
                ),
                child: Icon(
                  locked ? Icons.lock_outline : moduleIcon(module.iconName),
                  size: _iconSize,
                  color: locked
                      ? colors.onSurfaceVariant
                      : colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      module.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: locked
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _NodeStatus(item: item),
                  ],
                ),
              ),
              if (!locked) ...[
                const SizedBox(width: 8),
                Icon(
                  item.isComplete ? Icons.check_circle : Icons.chevron_right,
                  color: item.isComplete
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress line under the module title: a `Locked` hint, a `Complete`
/// label, or a `done / total` count above a slim progress bar.
class _NodeStatus extends StatelessWidget {
  const _NodeStatus({required this.item});

  final ModuleWithProgress item;

  static const double _barHeight = 5;
  static const double _barRadius = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mutedText = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    if (item.isLocked) {
      return Text('Locked', style: mutedText);
    }
    if (item.isComplete) {
      return Text('Complete', style: mutedText);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${item.completedCount} / ${item.totalCount} lessons',
          style: mutedText,
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: item.progress,
          minHeight: _barHeight,
          borderRadius: BorderRadius.circular(_barRadius),
          backgroundColor: colors.surfaceContainerHighest,
          color: colors.primary,
        ),
      ],
    );
  }
}
