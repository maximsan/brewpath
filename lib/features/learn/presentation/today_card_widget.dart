import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hero card for the day's primary action. Renders the next lesson with a
/// prominent `Start` CTA, or a friendly caught-up state when nothing is due.
class TodayCardWidget extends StatelessWidget {
  /// Creates a [TodayCardWidget].
  const TodayCardWidget({required this.today, super.key});

  /// The lesson due today, or `null` when the user is caught up.
  final LessonModel? today;

  static const double _heroRadius = 12;
  static const double _heroLetterSpacing = 0.6;
  static const double _mutedAlpha = 0.8;
  static const double _iconSm = 18;
  static const double _iconLg = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final lesson = today;

    return Card(
      margin: EdgeInsets.zero,
      color: mood.accent,
      child: lesson == null
          ? _buildCaughtUp(theme, mood)
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
      onTap: () => context.go('/learn/lesson/${lesson.id}'),
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
              lesson.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mood.accentInk.withValues(alpha: _mutedAlpha),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _XpPill(xp: lesson.xpReward),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.go('/learn/lesson/${lesson.id}'),
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

  Widget _buildCaughtUp(ThemeData theme, MoodColors mood) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: _iconLg,
            color: mood.accentInk,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You're all caught up!",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: mood.accentInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No lessons left to study.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: mood.accentInk.withValues(
                      alpha: _mutedAlpha,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact `+XP` reward chip shown on the hero card.
class _XpPill extends StatelessWidget {
  const _XpPill({required this.xp});

  final int xp;

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
          Icon(Icons.bolt, size: _iconMd, color: mood.accentInk),
          const SizedBox(width: 4),
          Text(
            '+$xp XP',
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
