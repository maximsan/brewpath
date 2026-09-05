import 'dart:async';
import 'dart:math' as math;

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty_animation.dart';
import 'package:brew_path/features/companion/presentation/roasty_body.dart';
import 'package:brew_path/features/companion/presentation/roasty_faces.dart';
import 'package:brew_path/features/companion/presentation/roasty_particles.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/material.dart';

/// Animated Roasty mascot. Reproduces the design's geometry + per-state
/// animations using Flutter's Canvas + a single [AnimationController]. Public
/// API: `Roasty(state: …, size: …, replayKey: …, plate: …, pointsAmount: …)`.
/// The `replayKey`
/// mimics the design's `key={state + ':' + replayKey}` so one-shot animations
/// restart on demand.
class Roasty extends StatefulWidget {
  /// Creates a [Roasty].
  const Roasty({
    required this.state,
    this.size = 160,
    this.replayKey,
    this.sproutScale,
    this.animate = true,
    this.plate = false,
    this.pointsAmount,
    super.key,
  }) : assert(
         (state == RoastyState.points) == (pointsAmount != null),
         'the points pose is the wink and the amount together: the mascot '
         'names no payout of its own (#16), and a burst with nothing in it is '
         'half the pose',
       );

  /// The mascot's current visual state.
  final RoastyState state;

  /// Rendered width/height in logical pixels.
  final double size;

  /// Changing this restarts one-shot animations (mirrors the design's key).
  final Object? replayKey;

  /// Whether the mascot animates. When false — or when the platform requests
  /// reduced motion ([MediaQueryData.disableAnimations]) — Roasty paints a
  /// single held frame ([roastyStaticFrame]) and the controller stays idle.
  final bool animate;

  /// Overrides the sprout's scale when non-null, letting a host (e.g. the
  /// loading screen) drive the wake-up grow. When null the sprout follows the
  /// state-based default (shrunk while sleeping, full otherwise).
  final double? sproutScale;

  /// Whether Roasty sits on a paper plate. The plate keeps the bean readable
  /// on a dark or accent-filled ground, and is pinned to one tone
  /// ([RoastyColors.plate]) so it never follows the mood into the bean's own
  /// browns.
  final bool plate;

  /// What the points burst says, for [RoastyState.points] and no other state.
  ///
  /// Passed in rather than known here: a lesson pays what it authors and a
  /// challenge pays its own rule (§5.1, #16), so a number the mascot held
  /// would be right about neither. Required with the pose and rejected without
  /// it — see the assert on the constructor.
  final int? pointsAmount;

  @override
  State<Roasty> createState() => _RoastyState();
}

class _RoastyState extends State<Roasty> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: roastyDuration(widget.state))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed &&
                roastyLoops(widget.state)) {
              unawaited(_controller.repeat());
            }
          });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced-motion lives in MediaQuery, so first available here.
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant Roasty oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stateChanged = oldWidget.state != widget.state;
    final replayChanged = oldWidget.replayKey != widget.replayKey;
    final animateChanged = oldWidget.animate != widget.animate;
    if (stateChanged || replayChanged || animateChanged) {
      _controller.duration = roastyDuration(widget.state);
      _syncAnimation(forceRestart: stateChanged || replayChanged);
    }
  }

  /// Reconciles the controller with the effective animate flag — the widget's
  /// [Roasty.animate] AND platform reduced-motion. When animating, (re)starts
  /// the state's motion; otherwise stops on the static frame.
  void _syncAnimation({bool forceRestart = false}) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldAnimate = widget.animate && !reduceMotion;
    if (shouldAnimate) {
      if (!_animating || forceRestart) {
        _animating = true;
        _startForState(widget.state);
      }
    } else {
      _animating = false;
      _controller
        ..stop()
        ..value = roastyStaticFrame(widget.state);
    }
  }

  void _startForState(RoastyState state) {
    _controller.reset();
    if (roastyLoops(state)) {
      unawaited(_controller.repeat());
    } else {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size * 1.4,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _RoastyPainter(
              state: widget.state,
              progress: _controller.value,
              sproutScale: widget.sproutScale,
              plate: widget.plate,
              pointsAmount: widget.pointsAmount,
              mood: context.mood,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the bean body, current-state face, sprout, and the state-specific
/// particle layer onto a 200x280 logical canvas (the design's SVG
/// `viewBox="0 0 200 280"`, so geometry copies 1:1). Drawing is delegated
/// to the sibling `roasty_body` / `roasty_faces` / `roasty_particles` modules;
/// the animation math lives in `roasty_animation`.
class _RoastyPainter extends CustomPainter {
  _RoastyPainter({
    required this.state,
    required this.progress,
    required this.plate,
    required this.mood,
    this.sproutScale,
    this.pointsAmount,
  });

  final RoastyState state;
  final double progress;
  final bool plate;

  /// What the points burst says; null for every other state.
  final int? pointsAmount;

  /// The ambient mood, for the marks the design gives to the theme rather
  /// than to the mascot's palette: the celebration warn, the wrong badge's
  /// berry, the sleeping `z`s' muted ink.
  final MoodColors mood;

  /// When non-null, overrides the state-derived sprout scale (used by the
  /// loading screen to grow the sprout out of Roasty's head during wake-up).
  final double? sproutScale;

  static const double _vbW = 200;
  static const double _vbH = 280;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final sx = size.width / _vbW;
    final sy = size.height / _vbH;
    final scale = math.min(sx, sy);
    canvas.translate(
      (size.width - _vbW * scale) / 2,
      (size.height - _vbH * scale) / 2,
    );
    canvas.scale(scale, scale);

    if (plate) paintRoastyPlate(canvas);
    paintRoastyParticlesBack(canvas, state, progress, mood);
    paintRoastySprout(canvas, state, progress, sproutScale);
    paintRoastyBody(canvas, state, progress);
    _paintFace(canvas);
    paintRoastyParticlesFront(
      canvas,
      state,
      progress,
      mood,
      pointsAmount: pointsAmount,
    );

    canvas.restore();
  }

  /// Faces ride along with the body transform, so apply it before drawing.
  void _paintFace(Canvas canvas) {
    canvas.save();
    final offset = roastyBodyOffset(state, progress);
    canvas.translate(100 + offset.dx, 158 + offset.dy);
    canvas.rotate(roastyBodyRotation(state, progress));
    canvas.scale(roastyBodyScale(state, progress));
    canvas.translate(-100, -158);
    paintRoastyFace(canvas, state, mood);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoastyPainter old) =>
      old.state != state ||
      old.progress != progress ||
      old.sproutScale != sproutScale ||
      old.plate != plate ||
      old.pointsAmount != pointsAmount ||
      old.mood != mood;
}
