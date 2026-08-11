import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
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
    final mood = context.mood;
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
                  color: locked ? mood.surface2 : mood.accent,
                  borderRadius: BorderRadius.circular(_badgeRadius),
                ),
                child: Icon(
                  locked ? Icons.lock_outline : moduleIcon(module.iconName),
                  size: _iconSize,
                  color: locked ? mood.inkMute : mood.accentInk,
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
                        color: locked ? mood.inkMute : mood.ink,
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
                  color: item.isComplete ? mood.accent : mood.inkMute,
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
    final mood = context.mood;
    final mutedText = theme.textTheme.bodySmall?.copyWith(
      color: mood.inkMute,
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
          backgroundColor: mood.surface2,
          color: mood.accent,
        ),
      ],
    );
  }
}
