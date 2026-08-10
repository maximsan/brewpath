import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Browse-all section that lists every lesson grouped by its module, so the
/// user can pick any lesson to practice without first opening a module.
class PracticeAnyLessonWidget extends StatefulWidget {
  /// Creates a [PracticeAnyLessonWidget].
  const PracticeAnyLessonWidget({
    required this.lessons,
    required this.completedIds,
    super.key,
  });

  /// Every lesson (with its module) available to practice.
  final List<LessonWithModule> lessons;

  /// Ids of lessons the user has already completed.
  final Set<String> completedIds;

  @override
  State<PracticeAnyLessonWidget> createState() =>
      _PracticeAnyLessonWidgetState();
}

class _PracticeAnyLessonWidgetState extends State<PracticeAnyLessonWidget> {
  /// Collapsed view shows the first few lessons; expanding reveals the rest, so
  /// the section never dominates the screen on first paint.
  static const int _previewCount = 4;
  static const double _iconSm = 18;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.lessons.isEmpty) {
      return const _SectionPlaceholder(text: 'No lessons available yet.');
    }
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final list = _expanded
        ? widget.lessons
        : widget.lessons.take(_previewCount).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.outlineVariant),
            _LessonRow(
              entry: list[i],
              completed: widget.completedIds.contains(list[i].lesson.id),
            ),
          ],
          if (widget.lessons.length > _previewCount)
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: _iconSm,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _expanded
                          ? 'Show fewer'
                          : 'Show all ${widget.lessons.length} lessons',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.entry, required this.completed});

  final LessonWithModule entry;
  final bool completed;

  static const double _rowBadgeSize = 36;
  static const double _rowBadgeRadius = 10;
  static const double _iconSm = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ListTile(
      leading: Container(
        width: _rowBadgeSize,
        height: _rowBadgeSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(_rowBadgeRadius),
        ),
        child: Icon(
          moduleIcon(entry.module.iconName),
          size: _iconSm,
          color: colors.onPrimaryContainer,
        ),
      ),
      title: Text(entry.lesson.title),
      subtitle: Text(
        entry.module.title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        completed ? Icons.check_circle : Icons.fitness_center,
        color: completed ? colors.primary : colors.onSurfaceVariant,
      ),
      onTap: () => context.go('/learn/practice/lesson/${entry.lesson.id}'),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
