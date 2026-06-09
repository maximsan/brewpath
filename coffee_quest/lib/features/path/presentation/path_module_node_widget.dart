import 'package:coffee_quest/core/constants/app_strings.dart';
import 'package:coffee_quest/core/utils/module_icons.dart';
import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A single node in the vertical learning path: a state-colored circle on the
/// connecting rail plus a content card with the module icon, title, and
/// progress. Locked taps surface the unlock hint instead of navigating.
class PathModuleNodeWidget extends StatelessWidget {
  const PathModuleNodeWidget({
    required this.item, required this.isFirst, required this.isLast, super.key,
  });

  final ModuleWithProgress item;

  /// Whether this is the first/last node — the rail trims its connector there.
  final bool isFirst;
  final bool isLast;

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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NodeRail(item: item, isFirst: isFirst, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: _NodeCard(item: item, onTap: () => _onTap(context)),
            ),
          ),
        ],
      ),
    );
  }
}

/// The left rail: connector segments above and below a state-colored node
/// circle. Connectors are hidden at the path's ends and "light up" through
/// modules the user has already reached.
class _NodeRail extends StatelessWidget {
  const _NodeRail({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  final ModuleWithProgress item;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lit = colors.primary;
    final dim = colors.surfaceContainerHighest;
    final reached = !item.isLocked;

    return SizedBox(
      width: 32,
      child: Column(
        children: [
          Expanded(
            child: _Connector(
              color: isFirst ? Colors.transparent : (reached ? lit : dim),
            ),
          ),
          _NodeCircle(item: item),
          Expanded(
            child: _Connector(
              color: isLast
                  ? Colors.transparent
                  : (item.isComplete ? lit : dim),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single vertical trail segment.
class _Connector extends StatelessWidget {
  const _Connector({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(width: 3, color: color));
  }
}

/// The node marker: filled when complete, outlined when current/available,
/// muted with a lock when locked.
class _NodeCircle extends StatelessWidget {
  const _NodeCircle({required this.item});

  final ModuleWithProgress item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const size = 36.0;

    final (
      Color background,
      Color foreground,
      IconData icon,
      Border? border,
    ) = switch (item) {
      _ when item.isLocked => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
        Icons.lock_outline,
        null,
      ),
      _ when item.isComplete => (
        colors.primary,
        colors.onPrimary,
        Icons.check,
        null,
      ),
      _ => (
        colors.primaryContainer,
        colors.primary,
        Icons.play_arrow,
        Border.all(color: colors.primary, width: 2),
      ),
    };

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Icon(icon, size: 18, color: foreground),
    );
  }
}

/// The content panel beside a node: module icon, title, and progress.
class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.item, required this.onTap});

  final ModuleWithProgress item;
  final VoidCallback onTap;

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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: locked
                      ? colors.surfaceContainerHighest
                      : colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  locked ? Icons.lock_outline : moduleIcon(module.iconName),
                  size: 22,
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
          minHeight: 5,
          borderRadius: BorderRadius.circular(3),
          backgroundColor: colors.surfaceContainerHighest,
          color: colors.primary,
        ),
      ],
    );
  }
}
