import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
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
              _ModuleBadge(
                icon: locked ? Icons.lock_outline : moduleIcon(module.iconName),
                locked: locked,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      module.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: locked ? mood.inkMute : mood.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ModuleStatus(item: item),
                  ],
                ),
              ),
              if (!locked) ...[
                const SizedBox(width: 8),
                Icon(
                  complete ? Icons.check_circle : Icons.chevron_right,
                  color: complete ? mood.accent : mood.inkMute,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded leading badge whose color signals the module state: muted when
/// locked, accent-filled otherwise. Complete and in-progress share the fill —
/// the design has no soft accent tone to separate them with.
class _ModuleBadge extends StatelessWidget {
  const _ModuleBadge({required this.icon, required this.locked});

  final IconData icon;
  final bool locked;

  static const double _size = 48;
  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final background = locked ? mood.surface2 : mood.accent;
    final foreground = locked ? mood.inkMute : mood.accentInk;

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Icon(icon, color: foreground),
    );
  }
}

/// Secondary line under the module title: a `Locked` hint, a completion line,
/// or a `done / total` count above a rounded progress bar.
class _ModuleStatus extends StatelessWidget {
  const _ModuleStatus({required this.item});

  final ModuleWithProgress item;

  static const double _barHeight = 6;
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

    final label = item.isComplete
        ? 'All ${item.totalCount} lessons complete'
        : '${item.completedCount} / ${item.totalCount} lessons';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: mutedText),
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
