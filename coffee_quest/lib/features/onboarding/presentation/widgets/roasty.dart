import 'dart:async';
import 'dart:math' as math;

import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_animation.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_body.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_faces.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_particles.dart';
import 'package:coffee_quest/features/onboarding/presentation/widgets/roasty_state.dart';
import 'package:flutter/material.dart';

/// Animated Roasty mascot. Reproduces the geometry + per-state animations
/// from the design bundle (`coffee_quest/brew-path-app/project/roasty.jsx`)
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
    super.key,
  });

  /// The mascot's current visual state.
  final RoastyState state;

  /// Rendered width/height in logical pixels.
  final double size;

  /// Changing this restarts one-shot animations (mirrors the prototype key).
  final Object? replayKey;

  /// Overrides the sprout's scale when non-null, letting a host (e.g. the
  /// loading screen) drive the wake-up grow. When null the sprout follows the
  /// state-based default (shrunk while sleeping, full otherwise).
  final double? sproutScale;

  @override
  State<Roasty> createState() => _RoastyState();
}

class _RoastyState extends State<Roasty> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    _startForState(widget.state);
  }

  @override
  void didUpdateWidget(covariant Roasty oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stateChanged = oldWidget.state != widget.state;
    final replayChanged = oldWidget.replayKey != widget.replayKey;
    if (stateChanged || replayChanged) {
      _controller.stop();
      _controller.duration = roastyDuration(widget.state);
      _startForState(widget.state);
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
