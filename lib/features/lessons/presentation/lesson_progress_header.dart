import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

const double _pillRadius = 20;
const int _percentScale = 100;
const double _progressBarHeight = 6;
const double _progressBarRadius = 3;
const double _pillGapH = 10;
const double _pillGapV = 4;

/// The header above a playing lesson: which module it belongs to, its title,
/// and how far through it the learner is.
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
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CardProgress(current: current, total: total),
      ],
    );
  }
}

/// A pill on the left (`Step X of Y`), percent on the right, bar beneath.
class _CardProgress extends StatelessWidget {
  const _CardProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final progress = total == 0 ? 0.0 : current / total;

    return Semantics(
      label: 'Step $current of $total',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _pillGapH,
                  vertical: _pillGapV,
                ),
                decoration: BoxDecoration(
                  color: mood.accent,
                  borderRadius: BorderRadius.circular(_pillRadius),
                ),
                child: Text(
                  'Step $current of $total',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: mood.accentInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(progress * _percentScale).round()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: mood.inkMute,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(
            value: progress,
            minHeight: _progressBarHeight,
            borderRadius: BorderRadius.circular(_progressBarRadius),
            backgroundColor: mood.surface2,
            color: mood.accent,
          ),
        ],
      ),
    );
  }
}
