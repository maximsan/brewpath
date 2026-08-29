import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/bean_gauge.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/path/domain/lesson_node_gauge.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A lesson row under its module on Path. Completed lessons expose a `Review`
/// action; what a finished run pays is decided by the service, not by the row
/// that opened it.
///
/// Moved here from the deleted module-detail screen rather than rewritten
/// ([#394](https://github.com/maximsan/brewpath/issues/394)): it already drew a
/// lesson at each status, and Path is now the only screen that lists lessons.
/// Its **chrome** is still the module screen's card rather than the design's
/// flat `.lesson-row` on the path spine — see
/// [#435](https://github.com/maximsan/brewpath/issues/435).
class PathLessonRow extends StatelessWidget {
  /// Creates a [PathLessonRow].
  const PathLessonRow({required this.entry, super.key});

  /// The lesson and the learner's progress through it.
  final PathLesson entry;

  static const double _cardRadius = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final lesson = entry.lesson;
    final destination = lessonRun(lesson.id);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.goTo(destination),
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _LessonBadge(
                isCompleted: entry.isCompleted,
                isCurrent: entry.isCurrent,
                mastery: entry.mastery,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lesson.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      // Inside its own module the label would repeat the
                      // header, so the row carries the lesson's own estimate.
                      '~${lesson.time} min',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: mood.inkMute,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _PointsInline(points: lesson.points),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (entry.isCompleted)
                TextButton(
                  onPressed: () => context.goTo(destination),
                  child: const Text('Review'),
                )
              else
                IconMark(AppIcon.chevron, color: mood.inkMute),
            ],
          ),
        ),
      ),
    );
  }
}

/// The lesson node: a coffee bean on the page canvas, filled to the lesson's
/// best-score ratio.
///
/// The bean *is* the gauge, so mastery reads as "how full" instead of a word in
/// the margin. Which tone and how full is decided by [lessonNodeGauge]; this
/// widget only turns that decision into mood colours.
class _LessonBadge extends StatelessWidget {
  const _LessonBadge({
    required this.isCompleted,
    required this.isCurrent,
    required this.mastery,
  });

  final bool isCompleted;
  final bool isCurrent;
  final MasteryResult mastery;

  /// The design's `.path-node`: a 32-px well in the page canvas colour, so the
  /// bean sits on `bg` rather than on the card's surface. The bean inside keeps
  /// [BeanGauge]'s own default, which is the design's 20 px.
  static const double _nodeSize = 32;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final gauge = lessonNodeGauge(
      isComplete: isCompleted,
      isCurrent: isCurrent,
      mastery: mastery,
    );
    final color = switch (gauge.tone) {
      LessonNodeTone.muted => mood.inkMute,
      LessonNodeTone.accent => mood.accent,
      LessonNodeTone.sage => mood.sage,
    };

    return Container(
      width: _nodeSize,
      height: _nodeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: mood.bg, shape: BoxShape.circle),
      child: BeanGauge(
        fill: gauge.fill,
        color: color,
        muted: mood.inkMute,
        ink: mood.ink,
      ),
    );
  }
}

/// Inline `+N PTS` label shown beneath each lesson row.
class _PointsInline extends StatelessWidget {
  const _PointsInline({required this.points});

  final int points;

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconMark(AppIcon.bean, size: _iconSize, color: mood.inkMute),
        const SizedBox(width: 2),
        Text(
          '+$points PTS',
          style: theme.textTheme.labelSmall?.copyWith(
            color: mood.inkMute,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
