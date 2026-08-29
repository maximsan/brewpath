import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The header above a playing lesson: which module it belongs to, its title,
/// and how far through it the learner is.
///
/// The position is a [RoastMeter] — the same bean the mini-game player shows.
/// It deliberately carries **no percentage and no bar**: this header says where
/// the learner is, and a filling bar with a figure beside it reads as how well
/// they are doing. That is the completion screen's job, not this one's.
class LessonProgressHeader extends StatelessWidget {
  /// Creates a [LessonProgressHeader].
  const LessonProgressHeader({
    required this.eyebrow,
    required this.title,
    required this.current,
    required this.total,
    super.key,
  });

  /// The module label the design prints above the title.
  final String eyebrow;

  /// The lesson's title.
  final String title;

  /// The card being played, 1-based.
  final int current;

  /// How many cards this attempt plays.
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          eyebrow,
          style: theme.textTheme.labelSmall?.copyWith(color: mood.inkMute),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: RoastMeter(
            position: current,
            total: total,
            semanticsLabel: 'Card $current of $total',
          ),
        ),
      ],
    );
  }
}
