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
/// Borderless on both endings: no pill, no well, no panel.
///
/// **Zero draws nothing on the lesson ending, and is not reached on the
/// module's.** A replay pays nothing, and a line reading `+0 PTS` under a tree
/// that did not move announces the absence; the module ending is only opened
/// by a run that closed a module, which always paid.
class RewardPointsLine extends StatelessWidget {
  /// Creates a [RewardPointsLine].
  const RewardPointsLine({required this.points, super.key});

  /// Points this run paid. Zero draws nothing.
  final int points;

  /// The design's `PointsBean size={18}`.
  static const double beanSize = 18;

  /// The room the design leaves between the tree and this line
  /// (`marginTop: 14`).
  ///
  /// **Carried here, not by the caller.** A gap left outside survives the
  /// line it belongs to: at zero the line collapsed and its space did not,
  /// pushing everything below a replay's still tree down by a line that was
  /// not there.
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
