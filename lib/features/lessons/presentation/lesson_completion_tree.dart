import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/presentation/growing_tree.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The Coffee Tree on the completion screen, and the line under it that speaks
/// for a tree which did not move.
///
/// **The tree is the point of the screen.** It is where the living-tree
/// metaphor the Welcome screen sells actually pays off, and the app used to
/// show a celebrating mascot here and never mention the tree at all.
class LessonCompletionTree extends StatelessWidget {
  /// Creates a [LessonCompletionTree].
  const LessonCompletionTree({
    required this.fromStage,
    required this.toStage,
    required this.lessonsToNextStage,
    super.key,
  });

  /// Where the tree stood before this run.
  final int fromStage;

  /// Where it stands now.
  final int toStage;

  /// Core lessons still needed for the next stage, or null at the end of the
  /// climb.
  final int? lessonsToNextStage;

  /// The size the design draws the tree at on this screen.
  static const double treeSize = 240;

  /// What a still tree says. The design states the reason: *"Most completions
  /// do not cross a stage threshold. Say how far the next one is, so a still
  /// tree reads as progress rather than nothing."*
  static String stillTreeLine(int lessons) =>
      '$lessons ${lessons == 1 ? 'lesson' : 'lessons'} to the next stage';

  /// Whether the run moved the tree — the *picture*, not the stored number.
  bool get _grew => treeStageRises(from: fromStage, to: toStage);

  @override
  Widget build(BuildContext context) {
    final toNext = lessonsToNextStage;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: _grew
              ? 'Your coffee tree grew to stage $toStage'
              : 'Your coffee tree, stage $toStage',
          excludeSemantics: true,
          child: GrowingTree(
            fromStage: fromStage,
            toStage: toStage,
            size: treeSize,
          ),
        ),
        // Only when the tree held still, and only while there is a next stage
        // to reach: a finished climb has nothing to count down to.
        if (!_grew && toNext != null) ...[
          const SizedBox(height: AppSpacing.xs),
          SmallcapsLabel(
            stillTreeLine(toNext),
            color: context.mood.inkMute,
          ),
        ],
      ],
    );
  }
}
