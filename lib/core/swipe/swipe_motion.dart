import 'package:flutter/animation.dart';

/// How one surface's swipe moves: its thresholds, its flight and its tilt.
///
/// A value object rather than five parameters, so a surface states its feel in
/// one place and the two that must agree — the threshold and the flight — are
/// never split across a call site.
class SwipeMotion {
  /// Creates a [SwipeMotion]. The defaults are a list row's: it commits at
  /// 70px, moves at most 170, and snaps back rather than flying off.
  const SwipeMotion({
    this.commitThreshold = _defaultCommitThreshold,
    this.maxDrag = _defaultMaxDrag,
    this.exitDistance = 0,
    this.exitDuration = const Duration(milliseconds: 230),
    this.tiltDegreesPer100px = 0,
  });

  static const double _defaultCommitThreshold = 70;
  static const double _defaultMaxDrag = 170;

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

  /// Degrees of tilt per 100px moved. A card that pivots as it leaves reads
  /// as a physical object being thrown; pure translation reads as a slider.
  final double tiltDegreesPer100px;

  /// The flight's ease-in — the design's `cubic-bezier(0.32,0,0.67,0)`.
  static const Curve exitCurve = Cubic(0.32, 0, 0.67, 0);

  /// The spring back to centre: `240ms cubic-bezier(0.22,0.61,0.36,1)`.
  static const Duration settleDuration = Duration(milliseconds: 240);

  /// The spring's easing.
  static const Curve settleCurve = Cubic(0.22, 0.61, 0.36, 1);
}
