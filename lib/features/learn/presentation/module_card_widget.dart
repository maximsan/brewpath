import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/module_glyph.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Module summary card for the Learn list: per-module icon, title, lesson
/// progress, and lock state. Locked taps surface the unlock hint instead of
/// navigating.
class ModuleCardWidget extends StatelessWidget {
  /// Creates a [ModuleCardWidget].
  const ModuleCardWidget({required this.item, super.key});

  /// The module paired with its derived progress state.
  final ModuleWithProgress item;

  static const double _cornerRadius = 12;

  void _onTap(BuildContext context) {
    if (item.isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(AppLabels.lockedModuleMessage)),
        );
      return;
    }
    context.go('/learn/module/${item.module.id}');
  }

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
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(_cornerRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ModuleGlyph(iconName: module.iconName, locked: locked),
              const SizedBox(width: AppSpacing.md),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: locked ? mood.inkMute : mood.ink,
                      ),
                    ),
                    // A finished module goes quiet rather than lighting up: it
                    // drops both its status line and its trailing mark, which
                    // is the design's only completion signal here.
                    if (!complete) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _ModuleStatus(item: item),
                    ],
                  ],
                ),
              ),
              if (!complete) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  locked ? Icons.lock_outline : Icons.chevron_right,
                  color: mood.inkMute,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary line under the module title: a `Locked` hint, or a `done / total`
/// count above a rounded progress bar. A complete module has no status line at
/// all, so this is never built for one.
class _ModuleStatus extends StatelessWidget {
  const _ModuleStatus({required this.item});

  final ModuleWithProgress item;

  static const double _barHeight = 6;
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
