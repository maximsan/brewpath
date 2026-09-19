import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_geometry.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The destination behind the challenge card, uncovered as it slides aside.
///
/// The label is left-aligned and a size up: the card parks after ~104px, so
/// only the strip nearest the left edge is ever uncovered, and a centred label
/// would stay under the card for the whole gesture.
class ChallengeParkTrack extends StatelessWidget {
  /// Creates a [ChallengeParkTrack] uncovered by [offset], at the card's
  /// [radius].
  const ChallengeParkTrack({
    required this.offset,
    required this.radius,
    super.key,
  });

  /// One label for every case, including a challenge already completed and
  /// being brewed again: you only see one because you chose to brew it again,
  /// so *later* is a real intent.
  static const String label = 'For later';

  /// The design's `color-mix(in oklab, var(--accent) 9%, var(--surface))`.
  static const double _fillShare = 0.09;

  /// The design's `color-mix(in oklab, var(--accent) 30%, var(--rule))`.
  static const double _ruleShare = 0.30;

  /// How far the card has been slid aside — by a finger, or by the nudge.
  final double offset;

  /// The card's own corner radius, so the two cannot drift apart.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return ExcludeSemantics(
      child: Opacity(
        opacity: challengeTrackReveal(offset),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: Color.alphaBlend(
              mood.accent.withValues(alpha: _fillShare),
              mood.surface,
            ),
            shape: DashedRoundedBorder(
              radius: radius,
              side: BorderSide(
                color: Color.lerp(mood.rule, mood.accent, _ruleShare)!,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                label.toUpperCase(),
                style: AppText.support(
                  color: mood.accentText,
                  face: AppFace.control,
                  tracking: AppTracking.smallcaps,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
