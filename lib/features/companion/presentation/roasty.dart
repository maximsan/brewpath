import 'dart:async';
import 'dart:math' as math;

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty_animation.dart';
import 'package:brew_path/features/companion/presentation/roasty_body.dart';
import 'package:brew_path/features/companion/presentation/roasty_faces.dart';
import 'package:brew_path/features/companion/presentation/roasty_particles.dart';
import 'package:flutter/material.dart';

/// Animated Roasty mascot. Reproduces the geometry + per-state animations
/// from the design bundle (`brew-path/roasty.jsx`)
/// using Flutter's Canvas + a single [AnimationController]. Public API:
/// `Roasty(state: …, size: …, replayKey: …)`. The `replayKey` mimics the
/// prototype's `key={state + ':' + replayKey}` so one-shot animations
/// restart on demand.
class Roasty extends StatefulWidget {
  /// Creates a [Roasty].
  const Roasty({
    required this.state,
    this.size = 160,
    this.replayKey,
    this.sproutScale,
    this.animate = true,
    super.key,
  });

  /// The mascot's current visual state.
  final RoastyState state;

  /// Rendered width/height in logical pixels.
  final double size;

  /// Changing this restarts one-shot animations (mirrors the prototype key).
  final Object? replayKey;

  /// Whether the mascot animates. When false — or when the platform requests
  /// reduced motion ([MediaQueryData.disableAnimations]) — Roasty paints a
  /// single held frame ([roastyStaticFrame]) and the controller stays idle.
  final bool animate;

  /// Overrides the sprout's scale when non-null, letting a host (e.g. the
  /// loading screen) drive the wake-up grow. When null the sprout follows the
  /// state-based default (shrunk while sleeping, full otherwise).
  final double? sproutScale;

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
              t: _controller.value,
              sproutScale: widget.sproutScale,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the bean body, current-state face, sprout, and the state-specific
/// particle layer onto a 200x280 logical canvas (matches the prototype's
/// SVG viewBox so geometry copies 1:1 from roasty.jsx). Drawing is delegated
/// to the sibling `roasty_body` / `roasty_faces` / `roasty_particles` modules;
/// the animation math lives in `roasty_animation`.
class _RoastyPainter extends CustomPainter {
  _RoastyPainter({required this.state, required this.t, this.sproutScale});

  final RoastyState state;
  final double t;

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
    final s = math.min(sx, sy);
    canvas.translate((size.width - _vbW * s) / 2, (size.height - _vbH * s) / 2);
    canvas.scale(s, s);

    paintRoastyParticlesBack(canvas, state, t);
    paintRoastySprout(canvas, state, t, sproutScale);
    paintRoastyBody(canvas, state, t);
    _paintFace(canvas);
    paintRoastyParticlesFront(canvas, state, t);

    canvas.restore();
  }

  /// Faces ride along with the body transform, so apply it before drawing.
  void _paintFace(Canvas canvas) {
    canvas.save();
    final offset = roastyBodyOffset(state, t);
    canvas.translate(100 + offset.dx, 158 + offset.dy);
    canvas.rotate(roastyBodyRotation(state, t));
    canvas.scale(roastyBodyScale(state, t));
    canvas.translate(-100, -158);
    paintRoastyFace(canvas, state);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoastyPainter old) =>
      old.state != state || old.t != t || old.sproutScale != sproutScale;
}
