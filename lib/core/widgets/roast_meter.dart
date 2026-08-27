import 'package:brew_path/core/widgets/roast_bean.dart';
import 'package:brew_path/core/widgets/roast_meter_math.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Where a learner is inside a run: a roasting bean and a zero-padded counter.
///
/// The one progress treatment for every run of questions — the lesson player
/// and the mini-game player both mount this, so the app cannot show two
/// unrelated ideas of "how far through am I". It reports **position only**:
/// there is no percentage and no bar, because either would be read as a score.
class RoastMeter extends StatelessWidget {
  /// Creates a [RoastMeter] showing [position] of [total].
  const RoastMeter({
    required this.position,
    required this.total,
    required this.semanticsLabel,
    super.key,
  });

  /// The card or round being played, 1-based.
  final int position;

  /// How many the run plays.
  final int total;

  /// What a screen reader announces — the caller's word for what is being
  /// counted, e.g. `Card 3 of 8`.
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    final mood = context.mood;

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoastBean(position: position, total: total),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${zeroPadded(position)} / ${zeroPadded(total)}',
            style: AppText.label(mood: mood, face: AppFace.mono),
          ),
        ],
      ),
    );
  }
}
