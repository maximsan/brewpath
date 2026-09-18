import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:flutter/material.dart';

/// How one surface's swipe moves: its thresholds, its flight and its tilt.
///
/// A value object rather than five parameters, so a surface states its feel in
/// one place and the two that must agree — the threshold and the flight — are
/// never split across a call site.
class SwipeMotion {
  /// Creates a [SwipeMotion]. The defaults are a list row's: it commits at
  /// 70px, moves at most 170, and snaps back rather than flying off.
  const SwipeMotion({
    this.commitThreshold = 70,
    this.maxDrag = 170,
    this.exitDistance = 0,
    this.exitDuration = const Duration(milliseconds: 230),
    this.tiltDegreesPer100px = 0,
  });

  /// How far the element must be on release for the swipe to commit.
  final double commitThreshold;

  /// How far it may move at all, in either direction.
  final double maxDrag;

  /// How far a committed swipe flies past the edge before the content changes.
  ///
  /// `0` keeps the snap back, which is what a list row wants: it is still in
  /// the list afterwards. A deck opts in, because a card that snaps back with
  /// new content inside it reads as a jump cut.
  final double exitDistance;

  /// How long the flight takes.
  final Duration exitDuration;

  /// Degrees of tilt per 100px moved. See [swipeTilt].
  final double tiltDegreesPer100px;

  /// The flight's ease-in — the design's `cubic-bezier(0.32,0,0.67,0)`.
  static const Curve exitCurve = Cubic(0.32, 0, 0.67, 0);

  /// The spring back to centre: `240ms cubic-bezier(0.22,0.61,0.36,1)`.
  static const Duration settleDuration = Duration(milliseconds: 240);

  /// The spring's easing.
  static const Curve settleCurve = Cubic(0.22, 0.61, 0.36, 1);
}

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

  SwipeDrag _dragAt({
    required double offset,
    required double travel,
    required SwipePhase phase,
  }) => SwipeDrag(
    offset: offset,
    travel: travel,
    progress: swipeCommitProgress(
      offset: offset,
      commitThreshold: widget.motion.commitThreshold,
    ),
    phase: phase,
  );

  void _onReleaseTick() {
    final eased = _releaseCurve.transform(_release.value);
    final exiting = _committed != null;
    setState(() {
      _drag = _dragAt(
        offset: lerpDouble(_fromOffset, _toOffset, eased)!,
        travel: exiting ? _fromTravel : _fromTravel * (1 - eased),
        phase: exiting ? SwipePhase.exiting : SwipePhase.rest,
      );
    });
  }

  void _onReleaseStatus(AnimationStatus status) {
    final aim = _committed;
    if (status == AnimationStatus.completed && aim != null) _land(aim);
  }

  /// Puts the element back at centre and only then changes the content, so the
  /// incoming card is already in place rather than flying in from the edge.
  void _land(SwipeAim aim) {
    _committed = null;
    _distance = 0;
    setState(() => _drag = const SwipeDrag());
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
      () => _drag = _dragAt(offset: 0, travel: 0, phase: SwipePhase.dragging),
    );
  }

  /// How far the element may be for the finger distance now recorded.
  double get _offsetNow => swipeOffset(
    distance: _distance,
    blocked: swipeIsBlocked(
      distance: _distance,
      canAdvance: widget.canAdvance,
      canBack: widget.canBack,
    ),
    maxDrag: widget.motion.maxDrag,
  );

  void _onDragUpdate(DragUpdateDetails details) {
    _distance += details.delta.dx;
    setState(
      () => _drag = _dragAt(
        offset: _offsetNow,
        travel: swipeTravel(
          distance: _distance,
          maxDrag: widget.motion.maxDrag,
        ),
        phase: SwipePhase.dragging,
      ),
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final aim = swipeCommit(
      offset: _offsetNow,
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
      _land(aim);
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
    if (MediaQuery.disableAnimationsOf(context)) {
      _distance = 0;
      setState(() => _drag = const SwipeDrag());
      return;
    }
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
