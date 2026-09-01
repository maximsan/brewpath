import 'dart:async';

import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/roasty_moment.dart';
import 'package:brew_path/features/learn/domain/module_summary_provider.dart';
import 'package:brew_path/features/learn/presentation/module_complete_faces.dart';
import 'package:brew_path/features/learn/presentation/module_flip_animation.dart';
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
  const ModuleCompleteScreen({required this.moduleId, super.key});

  /// Id of the module that just closed.
  final String moduleId;

  @override
  ConsumerState<ModuleCompleteScreen> createState() =>
      _ModuleCompleteScreenState();
}

class _ModuleCompleteScreenState extends ConsumerState<ModuleCompleteScreen>
    with SingleTickerProviderStateMixin {
  /// The module ending's longer hold (`rewards.jsx:225`) — the one beat that
  /// overrides the default. It lives here, with the beat that asks for it,
  /// rather than in the shared widget.
  static const Duration _hold = Duration(milliseconds: 2200);

  /// The stage a tree stands at before any lesson has moved it — what the
  /// screen draws while the real stage is still loading.
  static const int _firstStage = 1;

  /// Whether the opening beat has handed over.
  bool _beatDone = false;

  /// Built in [initState], not lazily: a `late final` controller that the
  /// learner never turns is first created by `dispose()` calling it, and
  /// `createTicker` then looks up an ancestor of a widget that is already
  /// deactivated.
  late final AnimationController _flip;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(vsync: this, duration: flipDuration);
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _turnOver({required bool toBack}) {
    if (MediaQuery.disableAnimationsOf(context)) {
      // Reduced motion gets the *result* of the turn, not a faster turn: the
      // flip is a rotation in depth, and there is no gentle version of it.
      _flip.value = flipRestValue(showingBack: toBack);
      return;
    }
    // The turn is fire-and-forget: nothing waits on it finishing, and the
    // faces swap off the controller's value rather than off its future.
    unawaited(toBack ? _flip.forward() : _flip.reverse());
  }

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
    // does not re-run it.
    final treeStage = ref.watch(treeStageProvider).asData?.value ?? _firstStage;

    return Scaffold(
      body: SafeArea(
        child: summary.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(message: '$error'),
          data: (data) => _beatDone
              ? _Flip(
                  summary: data,
                  treeStage: treeStage,
                  flip: _flip,
                  onTurn: _turnOver,
                  onClose: _backToPath,
                  onContinue: () => _continue(data),
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

/// The two faces, and the turn between them.
class _Flip extends StatelessWidget {
  const _Flip({
    required this.summary,
    required this.treeStage,
    required this.flip,
    required this.onTurn,
    required this.onClose,
    required this.onContinue,
  });

  final ModuleSummary summary;
  final int treeStage;
  final AnimationController flip;
  final void Function({required bool toBack}) onTurn;
  final VoidCallback onClose;
  final VoidCallback onContinue;

  /// The design's `perspective: 1800` — the depth that makes the turn read as
  /// a card rather than a squash. Matrix4 wants its reciprocal.
  static const double _perspective = 1 / 1800;

  /// `perspectiveOrigin: 50% 42%` — slightly above centre, so the turn pivots
  /// about the celebration rather than about the footer.
  static const Alignment _origin = Alignment(0, -0.16);

  @override
  Widget build(BuildContext context) {
    // The design's own easing. Read through a curve rather than baked into the
    // controller so `flip.value` stays the plain 0→1 the maths is written in.
    final turn = CurvedAnimation(parent: flip, curve: flipCurve);

    return AnimatedBuilder(
      animation: turn,
      builder: (context, _) {
        final showsBack = flipShowsBack(turn.value);

        return Transform(
          alignment: _origin,
          transform: flipTransform(
            progress: turn.value,
            perspective: _perspective,
          ),
          child: showsBack
              // Turned again so the back reads upright rather than mirrored:
              // it is drawn on the far side of a card that is already half
              // way round.
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateY(flipAngle(flipTurnedOver)),
                  child: ModuleCompleteBack(
                    summary: summary,
                    onFlipBack: () => onTurn(toBack: false),
                    onContinue: onContinue,
                  ),
                )
              : ModuleCompleteFront(
                  summary: summary,
                  treeStage: treeStage,
                  onClose: onClose,
                  onTurnOver: () => onTurn(toBack: true),
                ),
        );
      },
    );
  }
}
