import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/reward_flip_view.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/roasty_moment.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/features/learn/presentation/module_complete_faces.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The module ending: **one route, three beats.**
///
/// 1. A full-screen [RoastyMoment] — `MODULE COMPLETE` over *"Look how far
///    you've come."*, held 2200 ms.
/// 2. The celebration face — the module's name, and the tree.
/// 3. The same screen turned over, showing the collectible it paid out.
///
/// The reward is the **back of the flip**, not a route after it. An earlier
/// reading had this as two routes chaining into a separate `module-card`; the
/// running prototype never reaches that screen — the only thing that would
/// navigate there is never called — so the card ships here (#384, and #230's
/// finding).
class ModuleCompleteScreen extends ConsumerStatefulWidget {
  /// Creates a [ModuleCompleteScreen].
  const ModuleCompleteScreen({
    required this.moduleId,
    this.runLessonId,
    this.freezeEarned = false,
    this.fromStage,
    this.toStage,
    super.key,
  });

  /// Id of the module that just closed.
  final String moduleId;

  /// The lesson that closed it, when this ending was reached by finishing one.
  ///
  /// **This ending is that lesson's ending too** (#458): the design branches
  /// rather than chaining, so nothing else will report what the lesson paid.
  final String? runLessonId;

  /// Whether that run is the one that earned the streak freeze.
  final bool freezeEarned;

  /// Where the tree stood before the run, and after it. Null when the ending
  /// was opened outside the flow, which draws the tree at rest.
  final int? fromStage;

  /// See [fromStage].
  final int? toStage;

  @override
  ConsumerState<ModuleCompleteScreen> createState() =>
      _ModuleCompleteScreenState();
}

class _ModuleCompleteScreenState extends ConsumerState<ModuleCompleteScreen>
    with SingleTickerProviderStateMixin, RewardFlipController {
  /// The module ending's longer hold — the one beat that overrides the
  /// default. It lives here, with the beat that asks for it, rather than in
  /// the shared widget.
  static const Duration _hold = Duration(milliseconds: 2200);

  /// The stage a tree stands at before any lesson has moved it — what the
  /// screen draws while the real stage is still loading.
  static const int _firstStage = 1;

  /// Whether the opening beat has handed over.
  bool _beatDone = false;

  /// Leaves for the Path — the way out when the course has nothing queued.
  void _backToPath() => context.goNamed(AppRoutes.path.name);

  /// Follows the action the learner was offered.
  ///
  /// *Begin next module* opens that module's first lesson; whether they may
  /// play it is the router's redirect to decide, not this screen's. The label
  /// and the destination are read from the same field so they cannot drift
  /// apart.
  void _continue(ModuleSummary summary) {
    final next = summary.nextLessonId;
    if (next == null) {
      _backToPath();
      return;
    }
    context.goTo(lessonRun(next));
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(moduleSummaryProvider(widget.moduleId));
    // Progress, read separately from the content join so a tree that grows
    // does not re-run it. It stands in for both ends when the ending was
    // opened outside the flow and no run is being reported.
    final treeStage = ref.watch(treeStageProvider).asData?.value ?? _firstStage;
    final run =
        ref.watch(moduleEndingRunProvider(widget.runLessonId)).asData?.value ??
        noModuleEndingRun;

    return Scaffold(
      body: SafeArea(
        child: summary.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(message: '$error'),
          data: (data) => _beatDone
              ? RewardFlipView(
                  turn: flipProgress,
                  front: (context) => ModuleCompleteFront(
                    summary: data,
                    run: run,
                    freezeEarned: widget.freezeEarned,
                    fromStage: widget.fromStage ?? treeStage,
                    toStage: widget.toStage ?? treeStage,
                    onClose: _backToPath,
                    onTurnOver: () => turnTo(showCard: true),
                  ),
                  back: (context) => ModuleCompleteBack(
                    summary: data,
                    onFlipBack: () => turnTo(showCard: false),
                    onContinue: () => _continue(data),
                  ),
                )
              : RoastyMoment(
                  reaction: CompanionReaction.moduleComplete,
                  eyebrow: AppLabels.moduleCompleteKicker,
                  title: AppLabels.moduleCompleteTitle,
                  hold: _hold,
                  onDone: () => setState(() => _beatDone = true),
                ),
        ),
      ),
    );
  }
}
