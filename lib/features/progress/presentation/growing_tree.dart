import 'dart:async';

import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/progress/presentation/tree_growth_animation.dart';
import 'package:brew_path/features/progress/presentation/tree_growth_frames.dart';
import 'package:brew_path/features/progress/presentation/tree_growth_painters.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The Coffee Tree getting bigger — the payoff for the metaphor the Welcome
/// screen sells.
///
/// **Growth wraps [CoffeeTree]; it is never a mode on it.** The sway is
/// ambient identity and lives inside the tree so a screen added later cannot
/// forget it; growth is an event with a lifecycle — a from/to pair, a
/// callback — and lives out here, which keeps the Profile hero's contract at
/// "a stage in, a frame out" (ADR-0011).
///
/// **Single-stage only.** The design walks every stage between `from` and
/// `to`; that walk is cut, because the thresholds sit at least three lessons
/// apart and one completion advances the count by one. The multi-stage case is
/// reachable only by a CloudKit merge, and that lands without animating — the
/// growth belongs to the moment you earned it, not the moment a sync told you
/// about it.
///
/// ⚠️ **[onDone] fires exactly once, and fires under reduced motion**, where
/// the cross-fade survives and everything that moves is dropped. Both reward
/// screens sequence their content behind it.
class GrowingTree extends StatefulWidget {
  /// Creates a [GrowingTree].
  const GrowingTree({
    required this.fromStage,
    required this.toStage,
    this.treatment = GroveTreatment.identity,
    this.size = CoffeeTree.defaultSize,
    this.onDone,
    super.key,
  });

  /// The stage the tree stood at before this run.
  final int fromStage;

  /// The stage it stands at now. Equal to [fromStage] on the completions that
  /// cross no threshold, which is most of them — the tree then holds still and
  /// still calls back.
  final int toStage;

  /// The planted species' silhouette and the light it stands in.
  final GroveTreatment treatment;

  /// Square edge the tree renders at.
  final double size;

  /// Called once, when the beat is over.
  final VoidCallback? onDone;

  /// Whether [fromStage] → [toStage] is a rise the tree should play.
  bool get grows => treeStageRises(from: fromStage, to: toStage);

  @override
  State<GrowingTree> createState() => _GrowingTreeState();
}

class _GrowingTreeState extends State<GrowingTree>
    with SingleTickerProviderStateMixin {
  /// Built here rather than lazily. A tree that never grows never touches the
  /// controller, so a `late final` initialiser would run for the first time
  /// inside `dispose` — and creating a ticker there is an inherited lookup on
  /// an element that is already deactivated.
  late final AnimationController _controller;

  /// The hand-over is a timer's, not the controller's, so stillness cannot
  /// take it away — the failure ADR-0011 calls out by name.
  Timer? _handover;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: treeGrowthTotal);
    _handover = Timer(_handoverDelay, _finish);
  }

  @override
  void dispose() {
    _handover?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// When the beat is over. A tree that does not grow holds no beat at all, so
  /// it hands over as soon as it is on screen.
  Duration get _handoverDelay => widget.grows
      ? treeGrowthDelay + treeCrossfadeDuration + treeGrowthHandover
      : Duration.zero;

  void _finish() {
    if (_done) return;
    _done = true;
    _handover?.cancel();
    widget.onDone?.call();
  }

  /// Runs the beat's clock.
  ///
  /// **It runs under reduced motion too**, because the cross-fade is on that
  /// clock and the cross-fade survives: a hard cut loses the fact that the
  /// tree grew, which is the payoff. What stillness drops is everything that
  /// *moves* — the rise, the bounce, the ring, the leaves — and that is
  /// decided when the frame is built, not by stopping time.
  void _startBeat() {
    if (!widget.grows) return;
    if (_controller.isAnimating || _controller.isCompleted) return;
    unawaited(_controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    _startBeat();

    // Resolved once, here, and handed down. An inherited lookup inside the
    // animation builder can run against a deactivated element on the frame the
    // tree is torn down, which is an error rather than a stale colour.
    final mood = context.mood;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Always drawn, growth or not — the design's `.at-ground`, the disc
          // the tree stands on rather than part of the beat.
          Positioned.fill(
            child: CustomPaint(painter: TreeGroundPainter(mood)),
          ),
          Positioned.fill(
            child: _beat(mood: mood, animate: animate),
          ),
        ],
      ),
    );
  }

  Widget _beat({required MoodColors mood, required bool animate}) {
    // A tree that did not grow is simply the tree. Under reduced motion the
    // cross-fade still plays — a hard cut loses the fact that it grew, which
    // is the whole payoff — but nothing translates, bounces, rings or drifts.
    if (!widget.grows) return _tree(widget.toStage);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final elapsed = treeGrowthTotal * _controller.value;
        return TreeGrowthFrames(
          from: widget.fromStage,
          to: widget.toStage,
          treatment: widget.treatment,
          size: widget.size,
          elapsed: elapsed,
          mood: mood,
          animate: animate,
        );
      },
    );
  }

  /// One frame of the tree. The sway is left on: it is ambient identity, and a
  /// tree that stopped swaying to grow would read as a stall.
  Widget _tree(int stage) => Center(
    child: CoffeeTree(
      stage: stage,
      treatment: widget.treatment,
      size: widget.size,
    ),
  );
}
