import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
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
    final mood = context.mood;
    final destination = isCompleted
        ? '/learn/lesson/${lesson.id}?review=true'
        : '/learn/lesson/${lesson.id}';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.go(destination),
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
                        color: mood.inkMute,
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
                  onPressed: () => context.go(destination),
                  child: const Text('Review'),
                )
              else
                Icon(Icons.chevron_right, color: mood.inkMute),
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
    final mood = context.mood;
    // One fill for both states; the check-vs-number glyph is the distinction.
    final background = mood.accent;
    final foreground = mood.accentInk;

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
    final mood = context.mood;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt, size: _iconSize, color: mood.inkMute),
        const SizedBox(width: 2),
        Text(
          '+$xp XP',
          style: theme.textTheme.labelSmall?.copyWith(
            color: mood.inkMute,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
