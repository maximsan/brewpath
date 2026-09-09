import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What a run paid, under the tree it fed.
///
/// **Its own beat, directly beneath the tree** — *"what you earned feeds what
/// grows"* — and borderless on both endings: no pill, no well, no panel.
/// **Zero draws nothing**: `+0 PTS` under a tree that did not move announces
/// the absence, and only a run that paid ever reaches the module ending.
class RewardPointsLine extends StatelessWidget {
  /// Creates a [RewardPointsLine].
  const RewardPointsLine({required this.points, super.key});

  /// Points this run paid. Zero draws nothing.
  final int points;

  /// The design's `PointsBean size={18}`.
  static const double beanSize = 18;

  /// The room the design leaves between the tree and this line
  /// (`marginTop: 14`), carried here rather than by the caller: a gap left
  /// outside survives the line it belongs to, and a replay's collapsed line
  /// would leave its space behind.
  static const double gapAbove = AppSpacing.base;

  @override
  Widget build(BuildContext context) {
    if (points <= 0) return const SizedBox.shrink();
    final mood = context.mood;

    return Padding(
      padding: const EdgeInsets.only(top: gapAbove),
      child: Semantics(
        label: '$points points earned',
        excludeSemantics: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconMark(AppIcon.bean, size: beanSize, color: mood.accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '+$points PTS',
              style: AppText.support(
                mood: mood,
                color: mood.ink,
                face: AppFace.mono,
                tracking: AppTracking.count,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
