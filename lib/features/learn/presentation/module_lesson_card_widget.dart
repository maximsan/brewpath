import 'package:coffee_quest/core/constants/app_routes.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A lesson row in the module's lesson list. Completed lessons re-open in
/// review mode and expose a `Review` action; new lessons start fresh.
class ModuleLessonCardWidget extends StatelessWidget {
  /// Creates a [ModuleLessonCardWidget].
  const ModuleLessonCardWidget({
    required this.lesson,
    required this.index,
    required this.isCompleted,
    super.key,
  });

  /// The lesson to render.
  final LessonModel lesson;

  /// 1-based position of the lesson within its module.
  final int index;

  /// Whether the user has already completed this lesson.
  final bool isCompleted;

  static const double _cardRadius = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lessonParams = {'lessonId': lesson.id};
    // Completed lessons re-open in review mode; new ones start fresh.
    final lessonQuery = isCompleted
        ? const {'review': 'true'}
        : const <String, String>{};

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.goNamed(
          AppRoutes.lesson.name,
          pathParameters: lessonParams,
          queryParameters: lessonQuery,
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _LessonBadge(index: index, isCompleted: isCompleted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lesson.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      lesson.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _XpInline(xp: lesson.xpReward),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isCompleted)
                TextButton(
                  onPressed: () => context.goNamed(
                    AppRoutes.lesson.name,
                    pathParameters: lessonParams,
                    queryParameters: lessonQuery,
                  ),
                  child: const Text('Review'),
                )
              else
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Numbered/check badge on the leading edge of a lesson card.
class _LessonBadge extends StatelessWidget {
  const _LessonBadge({required this.index, required this.isCompleted});

  final int index;
  final bool isCompleted;

  static const double _size = 36;
  static const double _checkIconSize = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = isCompleted ? colors.primary : colors.primaryContainer;
    final foreground = isCompleted
        ? colors.onPrimary
        : colors.onPrimaryContainer;

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: isCompleted
          ? Icon(Icons.check, size: _checkIconSize, color: foreground)
          : Text(
              '$index',
              style: theme.textTheme.titleSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// Inline `+N XP` label shown beneath each lesson row.
class _XpInline extends StatelessWidget {
  const _XpInline({required this.xp});

  final int xp;

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt, size: _iconSize, color: colors.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(
          '+$xp XP',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
