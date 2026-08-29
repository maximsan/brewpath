import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/domain/tree_stage_names.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/progress/presentation/tree_ladder.dart';
import 'package:brew_path/features/progress/presentation/tree_progress_bar.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Coffee Tree's own screen, reached by tapping the tree on Profile.
///
/// The one surface where the sway is load-bearing: every other place the tree
/// appears is passed through, and this is one a learner sits on. It inherits
/// the sway from [CoffeeTree] rather than switching it on — see ADR-0011.
///
/// **Reads, never writes, and derives nothing.** The stage is the stored
/// highest-ever value; if it is wrong the fix is `treeStageForProgress`
/// ([#376](https://github.com/maximsan/brewpath/issues/376)), not a second
/// mapping here.
class TreeScreen extends ConsumerWidget {
  /// Creates a [TreeScreen].
  const TreeScreen({super.key});

  /// The screen's own title, in the app bar.
  static const title = 'Your coffee tree';

  /// The design's hero size for the tree here — larger than the Profile
  /// hero's, because on this screen the tree is the subject.
  static const double _treeSize = 236;

  static const _gutter = EdgeInsets.symmetric(horizontal: AppSpacing.md);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = ref.watch(treeStageProvider);
    final grove = ref.watch(groveTreatmentProvider);
    final progress = ref.watch(coreLessonProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        // Close, not back: the design gives this screen an X, because it is a
        // place you leave rather than a step you came through.
        leading: IconButton(
          icon: const IconMark(AppIcon.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: stage.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _TreeUnavailable(),
        data: (currentStage) => _TreeBody(
          stage: currentStage,
          treatment: grove.asData?.value ?? GroveTreatment.identity,
          progress: progress.asData?.value,
          treeSize: _treeSize,
          gutter: _gutter,
        ),
      ),
    );
  }
}

/// Everything under the bar once the stage is known.
class _TreeBody extends StatelessWidget {
  const _TreeBody({
    required this.stage,
    required this.treatment,
    required this.progress,
    required this.treeSize,
    required this.gutter,
  });

  /// The design's eyebrow, above the stage's name.
  static const _eyebrow = 'Your coffee tree';

  static const _explainer =
      'Your tree grows when you complete new core lessons on the main path. '
      'Replaying a lesson sharpens your mastery, but the tree only grows the '
      'first time you finish one.';

  static const _backLabel = 'Back to profile';

  final int stage;
  final GroveTreatment treatment;

  /// Null while the course is still being read — the bar and its counter wait
  /// rather than announcing a `0 / 0` that is about to change.
  final CoreLessonProgress? progress;

  final double treeSize;
  final EdgeInsets gutter;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final displayed = displayedTreeStage(stage);
    final next = nextTreeStageName(stage);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        Padding(
          padding: gutter,
          child: Column(
            children: [
              SmallcapsLabel(_eyebrow, color: mood.accent),
              const SizedBox(height: AppSpacing.xs),
              Text(
                treeStageName(stage),
                style: AppText.display(mood: mood),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: CoffeeTree(
            stage: stage,
            treatment: treatment,
            size: treeSize,
          ),
        ),
        Center(
          child: Semantics(
            // Read as a sentence rather than as "stage 4 of 10" shouted in
            // smallcaps, which is what the visible label is.
            label: 'Stage $displayed of $treeStageCount',
            excludeSemantics: true,
            child: SmallcapsLabel('Stage $displayed of $treeStageCount'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // The bar and its own gap arrive together, so a course still being
        // read leaves one space here rather than two.
        if (progress case final counted?) ...[
          Padding(
            padding: gutter,
            child: TreeProgressBar(
              completed: counted.completed,
              total: counted.total,
              nextStageName: next,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Padding(
          padding: gutter,
          child: TreeLadder(stage: displayed),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: gutter,
          child: Text(_explainer, style: AppText.support(mood: mood)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: gutter,
          child: PrimaryButton(
            label: _backLabel,
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}

/// What the screen says when the stored stage cannot be read.
///
/// Says the tree is unreachable rather than drawing a seed, which would be a
/// grown learner's tree replaced by a lie about their progress.
class _TreeUnavailable extends StatelessWidget {
  const _TreeUnavailable();

  static const _message = "Your tree can't be read right now.";

  @override
  Widget build(BuildContext context) => Semantics(
    label: _message,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          _message,
          style: AppText.support(mood: context.mood),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
