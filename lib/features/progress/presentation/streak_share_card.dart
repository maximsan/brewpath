import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The shareable streak card: wordmark, count, the small week strip, and the
/// tagline (#237).
///
/// Composed off-screen at [logicalSize] and exported at [exportPixelRatio],
/// so the same streak produces the same artifact on every device — capturing
/// an on-screen preview would make the image vary with device width (#26).
/// The card carries an image only, no URL: a link would be a deep link, and
/// #34 owns whether one exists.
class StreakShareCard extends StatelessWidget {
  /// Creates a [StreakShareCard].
  const StreakShareCard({required this.streak, required this.days, super.key});

  /// Fixed logical size the card is composed at.
  static const Size logicalSize = Size(360, 360);

  /// Export scale: lands the PNG at 1080 px wide — the resolution social
  /// surfaces expect (#26).
  static const double exportPixelRatio = 3;

  /// The day count.
  final int streak;

  /// The card's week strip cells.
  final List<StreakDay> days;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Container(
      width: logicalSize.width,
      height: logicalSize.height,
      color: mood.bg,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'BREWPATH',
            style: AppText.label(mood: mood, color: mood.accent),
          ),
          Column(
            children: [
              Text('$streak', style: AppText.hero(mood: mood)),
              const SizedBox(height: AppSpacing.xxs),
              Text('DAY STREAK', style: AppText.label(mood: mood)),
              const SizedBox(height: AppSpacing.md),
              WeekStrip(days: days, size: WeekStripSize.small),
            ],
          ),
          Text(
            'Learning coffee, one cup at a time',
            style: AppText.support(mood: mood),
          ),
        ],
      ),
    );
  }
}
