import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/presentation/keep_sharp_card_body.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Hero card for the day's primary action. Renders the next lesson with a
/// prominent `Start` CTA, or — when every available lesson is done — the
/// Keep Sharp recommendation for the day.
class TodayCardWidget extends StatelessWidget {
  /// Creates a [TodayCardWidget].
  const TodayCardWidget({
    required this.today,
    this.keepSharp,
    this.keepSharpDone = false,
    super.key,
  });

  /// The lesson due today, or `null` when the user is caught up.
  final LessonModel? today;

  /// The day's Keep Sharp pick, shown when [today] is null. Null means no
  /// registered practice type has material (the quiet degenerate state).
  final KeepSharpRecommendation? keepSharp;

  /// Whether today's recommendation already met its own completion rule.
  final bool keepSharpDone;

  static const double _heroRadius = 12;
  static const double _heroLetterSpacing = 0.6;
  static const double _mutedAlpha = 0.8;
  static const double _iconSm = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final lesson = today;

    return Card(
      margin: EdgeInsets.zero,
      color: mood.accent,
      child: lesson == null
          ? KeepSharpCardBody(
              recommendation: keepSharp,
              acknowledged: keepSharpDone,
            )
          : _buildLesson(context, theme, mood, lesson),
    );
  }

  Widget _buildLesson(
    BuildContext context,
    ThemeData theme,
    MoodColors mood,
    LessonModel lesson,
  ) {
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
                Icon(
                  Icons.local_cafe,
                  size: _iconSm,
                  color: mood.accentInk,
                ),
                const SizedBox(width: 8),
                Text(
                  "Today's lesson",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: mood.accentInk,
                    letterSpacing: _heroLetterSpacing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lesson.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: mood.accentInk,
                fontWeight: FontWeight.w700,
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
          IconMark(AppIcon.bolt, size: _iconMd, color: mood.accentInk),
          const SizedBox(width: 4),
          Text(
            '+$points PTS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: mood.accentInk,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
