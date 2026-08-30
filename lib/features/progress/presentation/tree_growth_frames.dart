import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/progress/presentation/tree_growth_animation.dart';
import 'package:brew_path/features/progress/presentation/tree_growth_painters.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One frame of the growth beat, at [elapsed] into it.
///
/// Split out of `GrowingTree` so that widget keeps only the lifecycle — the
/// controller, the hand-over and the motion preference — and this holds only
/// what a single frame looks like. Stateless and given its time, so a frame
/// can be built and asserted at any point in the beat.
class TreeGrowthFrames extends StatelessWidget {
  /// Creates a [TreeGrowthFrames].
  const TreeGrowthFrames({
    required this.from,
    required this.to,
    required this.treatment,
    required this.size,
    required this.elapsed,
    required this.mood,
    required this.animate,
    super.key,
  });

  /// The stage being left.
  final int from;

  /// The stage arriving.
  final int to;

  /// The planted species' silhouette and the light it stands in.
  final GroveTreatment treatment;

  /// Square edge each frame renders at.
  final double size;

  /// How far into the beat this frame is.
  final Duration elapsed;

  /// Resolved once by the host, so no inherited lookup happens mid-animation.
  final MoodColors mood;

  /// Whether anything may move. False under reduced motion, where the
  /// cross-fade still plays and everything else is dropped.
  final bool animate;

  /// When the arriving frame has landed and the celebration begins.
  Duration get _landed => treeGrowthDelay + treeCrossfadeDuration;

  double get _crossfade => phaseProgress(
    elapsed: elapsed,
    starts: treeGrowthDelay,
    lasts: treeCrossfadeDuration,
  );

  @override
  Widget build(BuildContext context) {
    if (!animate) return _still();

    final bounce = phaseProgress(
      elapsed: elapsed,
      starts: _landed,
      lasts: treeBounceDuration,
    );
    final glow = phaseProgress(
      elapsed: elapsed,
      starts: _landed,
      lasts: treeGlowDuration,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (glow > 0 && glow < 1)
          Positioned.fill(
            child: CustomPaint(
              painter: TreeGlowPainter(colour: mood.accent, progress: glow),
            ),
          ),
        Positioned.fill(child: _crossfading(bounce)),
        Positioned.fill(
          child: CustomPaint(
            painter: TreeLeafPainter(elapsed: elapsed - _landed, mood: mood),
          ),
        ),
      ],
    );
  }

  /// Reduced motion: the frames cross-fade on the same schedule and nothing
  /// else happens. The fade survives because a hard cut loses the fact that
  /// the tree grew, which is the payoff (ADR-0011).
  Widget _still() => Stack(
    alignment: Alignment.center,
    children: [
      Opacity(opacity: 1 - _crossfade, child: _tree(from)),
      Opacity(opacity: _crossfade, child: _tree(to)),
    ],
  );

  /// The old frame leaving and the new one arriving, the new one carrying the
  /// bounce once it has landed.
  Widget _crossfading(double bounce) {
    final crossfade = _crossfade;
    final eased = treeCrossfadeCurve.transform(crossfade);
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 1 - crossfade, child: _tree(from)),
        Opacity(
          opacity: crossfade,
          child: Transform.translate(
            offset: Offset(0, treeCrossfadeRise * (1 - eased)),
            child: Transform.scale(
              scale: bounce > 0
                  ? treeBounceScaleAt(bounce)
                  : treeCrossfadeScaleFrom +
                        (1 - treeCrossfadeScaleFrom) * eased,
              alignment: treeGrowthOrigin,
              child: _tree(to),
            ),
          ),
        ),
      ],
    );
  }

  /// One frame of the tree. The sway is left on: it is ambient identity, and a
  /// tree that stopped swaying to grow would read as a stall.
  Widget _tree(int stage) => Center(
    child: CoffeeTree(stage: stage, treatment: treatment, size: size),
  );
}
