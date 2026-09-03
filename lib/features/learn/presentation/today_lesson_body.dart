import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The Today card when the lesson is the learner's to open: what it is, where
/// it sits in the course, what finishing it pays, and a way in.
class TodayLessonBody extends StatelessWidget {
  /// Creates a [TodayLessonBody] for [lesson].
  const TodayLessonBody({required this.lesson, super.key});

  /// The lesson due today.
  final LessonModel lesson;

  /// The hero card's corner, which the ink splash has to be clipped to.
  static const double _heroRadius = 12;
  static const double _mutedAlpha = 0.8;
  static const double _iconSm = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return InkWell(
      onTap: () => context.goTo(lessonRun(lesson.id)),
      borderRadius: BorderRadius.circular(_heroRadius),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconMark(
                  AppIcon.cup,
                  size: _iconSm,
                  color: mood.accentInk,
                ),
                const SizedBox(width: 8),
                Text(
                  "Today's lesson",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: mood.accentInk,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lesson.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: mood.accentInk,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              // Where in the course this sits. The lessons bank authors no
              // blurb, and the module label is what the design prints here.
              lesson.moduleLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mood.accentInk.withValues(alpha: _mutedAlpha),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _PointsPill(points: lesson.points),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.goTo(lessonRun(lesson.id)),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact `+PTS` reward chip shown on the hero card.
class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.points});

  final int points;

  static const double _pillRadius = 20;
  static const double _pillAlpha = 0.12;
  static const double _iconMd = 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: mood.accentInk.withValues(alpha: _pillAlpha),
        borderRadius: BorderRadius.circular(_pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconMark(AppIcon.bean, size: _iconMd, color: mood.accentInk),
          const SizedBox(width: 4),
          Text(
            '+$points PTS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: mood.accentInk,
            ),
          ),
        ],
      ),
    );
  }
}
