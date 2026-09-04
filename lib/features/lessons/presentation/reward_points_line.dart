import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What a run paid, under the tree it fed.
///
/// **Its own beat, directly beneath the tree** — *"what you earned feeds what
/// grows"*. It used to be the first row of a bordered receipt, which read as
/// bookkeeping beside the thing it was supposed to explain.
///
/// Borderless on both endings: no pill, no well, no panel. A run that paid
/// nothing draws nothing, which is every replay.
class RewardPointsLine extends StatelessWidget {
  /// Creates a [RewardPointsLine].
  const RewardPointsLine({required this.points, super.key});

  /// Points this run paid. Zero draws nothing.
  final int points;

  /// The design's `PointsBean size={18}`.
  static const double beanSize = 18;

  @override
  Widget build(BuildContext context) {
    if (points <= 0) return const SizedBox.shrink();
    final mood = context.mood;

    return Semantics(
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
            ),
          ),
        ],
      ),
    );
  }
}
