import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_card.dart';
import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/steam_mark.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The streak, full width, as a preview of its own screen.
///
/// It was one tile of a 2×2 stat grid; the design gives it a card of its own
/// (`prototype/screens.jsx:2604-2637`) carrying the mark, the count and the
/// week strip — the streak is the thing a learner opens Profile to check.
class StreakCard extends StatelessWidget {
  /// Creates a [StreakCard].
  const StreakCard({
    required this.days,
    required this.weekDays,
    required this.onTap,
    super.key,
  });

  /// The design's radius for the cards under the hero.
  static const double _radius = 16;

  /// The circle the mark sits in.
  static const double _markWellSize = 46;

  /// The mark inside it.
  static const double _markWidth = 22;

  /// How much of the tint the well carries when the streak is alive.
  static const double _liveTint = 0.13;

  /// And when it is not — quieter, because a cold streak is not an alert.
  static const double _coldTint = 0.10;

  /// Gap between the mark and the count.
  static const double _markGap = 13;

  /// Days in the current streak.
  final int days;

  /// The week strip's days, or null while they load.
  final List<StreakDay>? weekDays;

  /// Opens the streak screen.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final isLive = days > 0;
    final markColour = isLive ? mood.accent : mood.inkMute;
    final strip = weekDays;

    return ProfileCard(
      radius: _radius,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      semanticLabel: 'Current streak, $days ${days == 1 ? 'day' : 'days'}.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _MarkWell(
                colour: markColour,
                tint: isLive ? _liveTint : _coldTint,
              ),
              const SizedBox(width: _markGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$days ${days == 1 ? 'day' : 'days'}',
                      style: AppText.title(mood: mood, face: AppFace.mono),
                    ),
                    const SizedBox(height: AppSpacing.xxs + 1),
                    const SmallcapsLabel('Current streak'),
                  ],
                ),
              ),
              IconMark(AppIcon.chevron, color: mood.inkMute),
            ],
          ),
          if (strip != null) ...[
            const SizedBox(height: AppSpacing.md + 2),
            WeekStrip(days: strip, size: WeekStripSize.small),
          ],
        ],
      ),
    );
  }
}

/// The tinted circle holding the steam mark.
class _MarkWell extends StatelessWidget {
  const _MarkWell({required this.colour, required this.tint});

  final Color colour;
  final double tint;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Container(
      width: StreakCard._markWellSize,
      height: StreakCard._markWellSize,
      decoration: BoxDecoration(
        color: Color.alphaBlend(colour.withValues(alpha: tint), mood.surface),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Center(
        child: SteamMark(color: colour, width: StreakCard._markWidth),
      ),
    );
  }
}
