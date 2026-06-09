import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Module summary card for the Learn list: per-module icon, title, lesson
/// progress, and lock state. Locked taps surface the unlock hint instead of
/// navigating.
class ModuleCardWidget extends StatelessWidget {
  const ModuleCardWidget({required this.item, super.key});

  final ModuleWithProgress item;

  void _onTap(BuildContext context) {
    if (item.isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(AppStrings.lockedModuleMessage)),
        );
      return;
    }
    context.go('/learn/module/${item.module.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final module = item.module;
    final locked = item.isLocked;
    final complete = item.isComplete;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _ModuleBadge(
                icon: locked ? Icons.lock_outline : moduleIcon(module.iconName),
                locked: locked,
                complete: complete,
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
                        color: locked
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
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
                  color: complete ? colors.primary : colors.onSurfaceVariant,
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
/// locked, filled `primary` when complete, soft `primaryContainer` otherwise.
class _ModuleBadge extends StatelessWidget {
  const _ModuleBadge({
    required this.icon,
    required this.locked,
    required this.complete,
  });

  final IconData icon;
  final bool locked;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color background;
    final Color foreground;
    if (locked) {
      background = colors.surfaceContainerHighest;
      foreground = colors.onSurfaceVariant;
    } else if (complete) {
      background = colors.primary;
      foreground = colors.onPrimary;
    } else {
      background = colors.primaryContainer;
      foreground = colors.onPrimaryContainer;
    }

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
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
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
          backgroundColor: colors.surfaceContainerHighest,
          color: colors.primary,
        ),
      ],
    );
  }
}
