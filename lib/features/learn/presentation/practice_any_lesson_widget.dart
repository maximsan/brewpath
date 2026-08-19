import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Browse-all section that lists every lesson grouped by its module, so the
/// user can pick any lesson to practice without first opening a module.
class PracticeAnyLessonWidget extends StatefulWidget {
  /// Creates a [PracticeAnyLessonWidget].
  const PracticeAnyLessonWidget({
    required this.lessons,
    super.key,
  });

  /// Every lesson (with its module) available to practice.
  final List<LessonWithModule> lessons;

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
    final mood = context.mood;
    final list = _expanded
        ? widget.lessons
        : widget.lessons.take(_previewCount).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) Divider(height: 1, color: mood.rule),
            _LessonRow(entry: list[i]),
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
                      color: mood.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _expanded
                          ? 'Show fewer'
                          : 'Show all ${widget.lessons.length} lessons',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: mood.accent,
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
  const _LessonRow({required this.entry});

  final LessonWithModule entry;
  static const double _rowBadgeSize = 36;
  static const double _rowBadgeRadius = 10;
  static const double _iconSm = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return ListTile(
      leading: IconBadge.rounded(
        icon: moduleIcon(entry.module.iconName),
        size: _rowBadgeSize,
        radius: _rowBadgeRadius,
        iconSize: _iconSm,
      ),
      title: Text(entry.lesson.title),
      subtitle: Text(
        entry.module.title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: mood.inkMute,
        ),
      ),
      trailing: Icon(Icons.check_circle, color: mood.accent),
      // A replay, not a throwaway run: reaching the final card records the day
      // (§3), exactly as replaying from the course path does. Where the learner
      // started it has never been what decides whether it counts.
      onTap: () => context.goTo(lessonReplay(entry.lesson.id)),
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
            color: context.mood.inkMute,
          ),
        ),
      ),
    );
  }
}
