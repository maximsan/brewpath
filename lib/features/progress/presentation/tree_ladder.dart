import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The ten rungs, accent up to the stage reached and muted beyond it.
///
/// The whole course at a glance, which the counter above it cannot give: `4 of
/// 10` is a number, this is a shape. Ten equal columns rather than a bar with
/// ten marks, because the design's rungs are separated by gaps — the distance
/// between stages is part of what it says.
class TreeLadder extends StatelessWidget {
  /// Creates a [TreeLadder].
  const TreeLadder({required this.stage, super.key});

  /// Rung thickness.
  static const double _rungHeight = 4;

  /// The gap between rungs.
  static const double _rungGap = AppSpacing.xxs;

  /// The stage reached, already clamped into the shipped range.
  final int stage;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: 'Growth ladder, stage $stage of $treeStageCount',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var rung = 1; rung <= treeStageCount; rung++) ...[
            if (rung > 1) const SizedBox(width: _rungGap),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: rung <= stage ? mood.accent : mood.surface2,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const SizedBox(height: _rungHeight),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
