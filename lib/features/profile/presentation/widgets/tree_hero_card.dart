import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_card.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/domain/tree_stage_names.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Profile's opening card: the tree, the stage it has reached, and how far
/// through the course that is.
///
/// The tree art itself is #136's; this is the card the design puts around it,
/// replacing a bare centred illustration.
class TreeHeroCard extends StatelessWidget {
  /// Creates a [TreeHeroCard].
  const TreeHeroCard({
    required this.stage,
    required this.treatment,
    required this.completed,
    required this.total,
    required this.onTap,
    super.key,
  });

  /// The design's art well: a square of `bg` inside its own hairline.
  static const double _wellSize = 96;

  /// The tree inside that well.
  static const double _treeSize = 82;

  /// The progress track's thickness.
  static const double _trackHeight = 6;

  /// Gap between the well and the text column.
  static const double _columnGap = 18;

  /// The stored highest-ever stage. Zero on a fresh install, which is why the
  /// card shows [_displayedStage] rather than this — the number beside the name
  /// has to be the stage the art is drawing.
  final int stage;

  /// The planted grove's treatment, already resolved.
  final GroveTreatment treatment;

  /// Core lessons finished.
  final int completed;

  /// Core lessons in the course.
  final int total;

  /// Opens the tree's own screen.
  final VoidCallback onTap;

  /// The stage the art is drawing — clamped the same way, so the number and
  /// the name can never disagree.
  int get _displayedStage => displayedTreeStage(stage);

  /// Fraction of the course finished, clamped so a bank edited between runs
  /// cannot overfill the track.
  double get _progress =>
      total <= 0 ? 0 : (completed / total).clamp(0, 1).toDouble();

  /// The line under the track. The design swaps the count for a plain
  /// statement once there is nothing left to count.
  String get _countLine => completed >= total && total > 0
      ? 'Fully grown'
      : '$completed / $total core lessons';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ProfileCard(
      radius: ProfileCard.heroRadius,
      onTap: onTap,
      padding: ProfileCard.headlinePadding,
      semanticLabel:
          'Your coffee tree. Stage $_displayedStage, ${treeStageName(stage)}. '
          '$_countLine.',
      child: Row(
        children: [
          _ArtWell(stage: stage, treatment: treatment),
          const SizedBox(width: _columnGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SmallcapsLabel('Your coffee tree', color: mood.accentText),
                const SizedBox(height: AppSpacing.xxs + 2),
                Text(
                  'Stage $_displayedStage · ${treeStageName(stage)}',
                  style: AppText.title(mood: mood),
                ),
                const SizedBox(height: AppSpacing.base),
                _ProgressTrack(progress: _progress),
                const SizedBox(height: AppSpacing.xs + 1),
                Text(
                  _countLine.toUpperCase(),
                  style: AppText.label(mood: mood, face: AppFace.mono),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The square the tree sits in — `bg` behind its own hairline, so the tree
/// reads as mounted rather than floating on the card.
class _ArtWell extends StatelessWidget {
  const _ArtWell({required this.stage, required this.treatment});

  final int stage;
  final GroveTreatment treatment;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Container(
      width: TreeHeroCard._wellSize,
      height: TreeHeroCard._wellSize,
      decoration: BoxDecoration(
        color: mood.bg,
        border: Border.all(color: mood.rule),
        borderRadius: BorderRadius.circular(AppRadii.chrome),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: CoffeeTree(
          stage: stage,
          treatment: treatment,
          size: TreeHeroCard._treeSize,
          // Frozen on the tab: the design animates the tree on its own screen,
          // not behind everything else the learner came here to read.
          animate: false,
        ),
      ),
    );
  }
}

/// The course-progress track: a `rule` groove filled to `accent`.
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: TreeHeroCard._trackHeight,
        child: ColoredBox(
          color: mood.rule,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: ColoredBox(color: mood.accent),
          ),
        ),
      ),
    );
  }
}
