import 'dart:async';
import 'dart:math' as math;

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/companion_outfit_scope.dart';
import 'package:brew_path/features/companion/presentation/roasty_animation.dart';
import 'package:brew_path/features/companion/presentation/roasty_body.dart';
import 'package:brew_path/features/companion/presentation/roasty_faces.dart';
import 'package:brew_path/features/companion/presentation/roasty_gear.dart';
import 'package:brew_path/features/companion/presentation/roasty_hats.dart';
import 'package:brew_path/features/companion/presentation/roasty_particles.dart';
import 'package:brew_path/features/companion/presentation/roasty_sprouts.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/material.dart';

/// How much taller than wide a Roasty is — the design's 200x280 box, which a
/// host sizing a box around one has to reserve.
const double roastyAspect = 1.4;

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
    this.outfit,
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
  /// challenge pays its own rule (§5.1, #16). Required with the pose and
  /// rejected without it — see the assert on the constructor. A caller
  /// reaching the pose through `roastyStateFor` has no channel for this.
  final int? pointsAmount;

  /// The outfit to draw, overriding what the learner has on.
  ///
  /// Only the Studio passes one, so it can preview a pick before it is
  /// confirmed. Everywhere else this is null and the mascot dresses itself
  /// from the ambient [CompanionOutfitScope] — which is what stops a screen
  /// showing the wrong Roasty by forgetting to thread it through.
  final CompanionConfig? outfit;

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
    final outfit = widget.outfit ?? CompanionOutfitScope.of(context);
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size * roastyAspect,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _RoastyPainter(
              state: widget.state,
              progress: _controller.value,
              sproutScale: widget.sproutScale,
              plate: widget.plate,
              pointsAmount: widget.pointsAmount,
              outfit: outfit,
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
    required this.outfit,
    required this.mood,
    this.sproutScale,
    this.pointsAmount,
  });

  final RoastyState state;
  final double progress;
  final bool plate;

  /// What the mascot is wearing, already resolved past the gate.
  final CompanionConfig outfit;

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
    // Bare-headed, the sprout nestles on the bean and sways on its own. Under
    // a hat it moves inside the body group instead, drawn over the crown.
    if (hatIsBare(outfit.hat)) {
      paintRoastySprout(
        canvas,
        state,
        progress,
        sproutScale,
        sprout: outfit.sprout,
      );
    }
    paintRoastyBody(canvas, state, progress, roast: outfit.roast);
    _paintFaceAndOutfit(canvas);
    paintRoastyParticlesFront(
      canvas,
      state,
      progress,
      mood,
      pointsAmount: pointsAmount,
    );

    canvas.restore();
  }

  /// The face and everything worn ride the body transform, so apply it once
  /// and draw them all inside it — the order the design draws them in.
  void _paintFaceAndOutfit(Canvas canvas) {
    canvas.save();
    final offset = roastyBodyOffset(state, progress);
    canvas.translate(100 + offset.dx, 158 + offset.dy);
    canvas.rotate(roastyBodyRotation(state, progress));
    canvas.scale(roastyBodyScale(state, progress));
    canvas.translate(-100, -158);
    paintRoastyFace(canvas, state, mood);
    paintRoastyGear(canvas, outfit.gear);
    paintRoastyHat(canvas, outfit.hat);
    if (!hatIsBare(outfit.hat)) {
      // The design lifts it 13 up so it clears the crown it grows through.
      canvas.translate(0, -_sproutOverHat);
      paintRoastySproutArt(canvas, outfit.sprout);
    }
    canvas.restore();
  }

  /// How far the sprout rises to grow through a hat, in canvas units.
  static const double _sproutOverHat = 13;

  @override
  bool shouldRepaint(covariant _RoastyPainter old) =>
      old.state != state ||
      old.progress != progress ||
      old.sproutScale != sproutScale ||
      old.plate != plate ||
      old.pointsAmount != pointsAmount ||
      old.outfit != outfit ||
      old.mood != mood;
}
