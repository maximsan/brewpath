import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/progress/domain/tree_growth.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// `CORE LESSONS COMPLETED`, the count, the bar, and the stage after this one.
///
/// One widget rather than three, because the three are one statement: how far
/// through the course you are, and what that is growing toward. The bar
/// animates its width on the way in, which is the design's own behaviour — it
/// fills rather than appearing full.
class TreeProgressBar extends StatelessWidget {
  /// Creates a [TreeProgressBar].
  const TreeProgressBar({
    required this.completed,
    required this.total,
    required this.nextStageName,
    super.key,
  });

  /// The design's label above the bar.
  static const _label = 'Core lessons completed';

  /// How long the bar takes to fill. The design's 900 ms.
  static const _fillDuration = Duration(milliseconds: 900);

  /// The design's easing for that fill — `cubic-bezier(0.2, 0.9, 0.3, 1)`,
  /// which is a decelerate: quick to commit, slow to settle.
  static const _fillCurve = Cubic(0.2, 0.9, 0.3, 1);

  /// The bar's thickness.
  static const double _trackHeight = 8;

  /// Core lessons finished.
  final int completed;

  /// Core lessons in the course.
  final int total;

  /// The stage this progress is growing toward, or null at full growth — the
  /// design omits the line rather than showing it empty.
  final String? nextStageName;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final fraction = treeProgressFraction(completed: completed, total: total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SmallcapsLabel(_label),
            Text(
              '$completed / $total',
              style: AppText.label(mood: mood, face: AppFace.mono),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          // The bar and its two labels are one fact to a screen reader, and
          // the fact is the count — not a percentage nobody was shown.
          label: '$completed of $total core lessons completed',
          excludeSemantics: true,
          child: _Track(
            fraction: fraction,
            duration: _fillDuration,
            curve: _fillCurve,
            height: _trackHeight,
          ),
        ),
        if (nextStageName case final next?) ...[
          const SizedBox(height: AppSpacing.xs),
          SmallcapsLabel('Next · $next'),
        ],
      ],
    );
  }
}

/// The track and the accent fill that grows across it.
class _Track extends StatelessWidget {
  const _Track({
    required this.fraction,
    required this.duration,
    required this.curve,
    required this.height,
  });

  final double fraction;
  final Duration duration;
  final Curve curve;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    // Reduced motion takes the fill straight to its width. The bar still says
    // the same thing; it just stops being an animation about saying it.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(AppRadii.pill);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        child: ColoredBox(
          color: mood.surface2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: reduceMotion ? Duration.zero : duration,
              curve: curve,
              builder: (context, filled, _) => FractionallySizedBox(
                widthFactor: filled,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: mood.accent,
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
