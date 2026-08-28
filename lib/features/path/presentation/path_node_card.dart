import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
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
  static const double _titleGap = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final module = item.module;
    final locked = item.isLocked;
    final complete = item.isComplete;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ModuleGlyph(iconName: module.iconName, locked: locked),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      module.title,
                      semanticsLabel: complete
                          ? AppLabels.moduleCompleteSemantics(module.title)
                          : null,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: locked ? mood.inkMute : mood.ink,
                      ),
                    ),
                    // A finished module goes quiet rather than lighting up: it
                    // drops both its status line and its trailing chevron,
                    // which is the design's only completion signal here.
                    if (!complete) ...[
                      const SizedBox(height: _titleGap),
                      _NodeStatus(item: item),
                    ],
                  ],
                ),
              ),
              // The rail beside this card already marks a locked module, so the
              // trailing slot stays empty there rather than doubling the lock.
              if (!locked && !complete) ...[
                const SizedBox(width: AppSpacing.xs),
                IconMark(AppIcon.chevron, color: mood.inkMute),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress line under the module title: a `Locked` hint, or a `done / total`
/// count above a slim progress bar. A complete module has no status line at
/// all, so this is never built for one.
class _NodeStatus extends StatelessWidget {
  const _NodeStatus({required this.item});

  final ModuleWithProgress item;

  static const double _barHeight = 5;
  static const double _barRadius = 3;
  static const double _labelGap = 6;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${item.completedCount} / ${item.totalCount} lessons',
          style: mutedText,
        ),
        const SizedBox(height: _labelGap),
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
