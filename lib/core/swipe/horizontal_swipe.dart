import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/core/swipe/swipe_motion.dart';
import 'package:flutter/material.dart';

export 'package:brew_path/core/swipe/swipe_motion.dart';

/// The one horizontal swipe, for every surface that has one.
///
/// [builder] paints the element that moves; [behind] paints what stays put in
/// the same box — a deck stack, or a row's track. Keeping them apart is what
/// makes the affordance a sibling of the transform rather than a passenger
/// inside it.
class HorizontalSwipe extends StatefulWidget {
  /// Creates a [HorizontalSwipe].
  const HorizontalSwipe({
    required this.builder,
    this.behind,
    this.onAdvance,
    this.onBack,
    this.canAdvance = true,
    this.canBack = true,
    this.motion = const SwipeMotion(),
    super.key,
  });

  /// The element that carries the drag.
  final Widget Function(BuildContext context, SwipeDrag drag) builder;

  /// What sits behind it, filling the same box and never moving with it.
  final Widget Function(BuildContext context, SwipeDrag drag)? behind;

  /// Fired once a left swipe commits.
  final VoidCallback? onAdvance;

  /// Fired once a right swipe commits.
  final VoidCallback? onBack;

  /// Whether there is anything to advance to. When false a left drag damps.
  final bool canAdvance;

  /// Whether there is anything to go back to, or set aside.
  final bool canBack;

  /// How this surface's swipe moves.
  final SwipeMotion motion;

  @override
  State<HorizontalSwipe> createState() => _HorizontalSwipeState();
}

class _HorizontalSwipeState extends State<HorizontalSwipe>
    with SingleTickerProviderStateMixin {
  /// Built in `initState`, never lazily: a `late final` the gesture may never
  /// touch is created by its own `dispose`, which asserts on the unmounted
  /// tree it looks a `TickerMode` up in.
  late final AnimationController _release;

  /// The finger's own distance since the gesture began. Written by the drag
  /// callbacks and read by the commit decision, which never consults what has
  /// been painted.
  double _distance = 0;

  SwipeDrag _drag = const SwipeDrag();
  double _fromOffset = 0;
  double _fromTravel = 0;
  double _toOffset = 0;
  Curve _releaseCurve = SwipeMotion.settleCurve;
  SwipeAim? _committed;

  @override
  void initState() {
    super.initState();
    _release = AnimationController(vsync: this)
      ..addListener(_onReleaseTick)
      ..addStatusListener(_onReleaseStatus);
  }

  @override
  void dispose() {
    _release.dispose();
    super.dispose();
  }

  void _onReleaseTick() {
    final eased = _releaseCurve.transform(_release.value);
    final exiting = _committed != null;
    setState(() {
      _drag = SwipeDrag.at(
        commitThreshold: widget.motion.commitThreshold,
        offset: lerpDouble(_fromOffset, _toOffset, eased)!,
        travel: exiting ? _fromTravel : _fromTravel * (1 - eased),
        phase: exiting ? SwipePhase.exiting : SwipePhase.rest,
      );
    });
  }

  void _onReleaseStatus(AnimationStatus status) {
    final aim = _committed;
    if (status == AnimationStatus.completed && aim != null) {
      _land(aim, settle: false);
    }
  }

  /// The content changes once the element is where the learner will next see
  /// it: at centre after a flight, or springing back there after a row's
  /// commit, which stays in the list and so never teleports home.
  void _land(SwipeAim aim, {required bool settle}) {
    _committed = null;
    if (settle) {
      _settleBack();
    } else {
      _distance = 0;
      setState(() => _drag = const SwipeDrag());
    }
    if (aim == SwipeAim.advance) {
      widget.onAdvance?.call();
    } else {
      widget.onBack?.call();
    }
  }

  void _onDragStart(DragStartDetails details) {
    _release.stop();
    _committed = null;
    _distance = 0;
    setState(
      () => _drag = SwipeDrag.at(
        commitThreshold: widget.motion.commitThreshold,
        offset: 0,
        travel: 0,
        phase: SwipePhase.dragging,
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _distance += details.delta.dx;
    setState(
      () => _drag = SwipeDrag.at(
        commitThreshold: widget.motion.commitThreshold,
        offset: swipeOffsetFor(
          distance: _distance,
          canAdvance: widget.canAdvance,
          canBack: widget.canBack,
          maxDrag: widget.motion.maxDrag,
        ),
        travel: swipeTravel(
          distance: _distance,
          maxDrag: widget.motion.maxDrag,
        ),
        phase: SwipePhase.dragging,
      ),
    );
  }

  /// Reads `_drag`, which the move handler wrote imperatively — never a value
  /// the commit decision would have to wait for a frame to see.
  void _onDragEnd(DragEndDetails details) {
    final aim = swipeCommit(
      offset: _drag.offset,
      commitThreshold: widget.motion.commitThreshold,
      canAdvance: widget.canAdvance,
      canBack: widget.canBack,
    );
    if (aim == null) {
      _settleBack();
    } else {
      _commit(aim);
    }
  }

  /// The flight is dropped under reduced motion: a long tilted fling would be
  /// the loudest movement in the app and the only one ignoring the preference.
  void _commit(SwipeAim aim) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final distance = reduced ? 0.0 : widget.motion.exitDistance;
    if (distance == 0) {
      _land(aim, settle: true);
      return;
    }
    _committed = aim;
    _releaseCurve = SwipeMotion.exitCurve;
    _toOffset = swipeExitOffset(aim: aim, exitDistance: distance);
    _startRelease(widget.motion.exitDuration);
  }

  void _settleBack() {
    if (_drag.offset == 0 && _drag.travel == 0) {
      setState(() => _drag = const SwipeDrag());
      return;
    }
    _committed = null;
    _releaseCurve = SwipeMotion.settleCurve;
    _toOffset = 0;
    _startRelease(SwipeMotion.settleDuration);
  }

  void _startRelease(Duration duration) {
    _fromOffset = _drag.offset;
    _fromTravel = _drag.travel;
    _release.duration = duration;
    unawaited(_release.forward(from: 0));
  }

  @override
  Widget build(BuildContext context) {
    final drag = _drag;
    final behind = widget.behind;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onHorizontalDragCancel: _settleBack,
      child: Stack(
        children: [
          if (behind != null) Positioned.fill(child: behind(context, drag)),
          Transform.translate(
            offset: Offset(drag.offset, 0),
            child: Transform.rotate(
              angle: swipeTilt(
                offset: drag.offset,
                degreesPer100px: widget.motion.tiltDegreesPer100px,
              ),
              child: widget.builder(context, drag),
            ),
          ),
        ],
      ),
    );
  }
}
