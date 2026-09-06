/// The Coffee Tree's sway — the one motion that lives on the tree itself.
///
/// Pure, so the curve is unit-testable without pumping a widget, the way
/// `roasty_animation.dart` holds Roasty's timings. Transcribed from the
/// design's `personaSway` keyframes and ruled in scope by ADR-0011.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// One full there-and-back sway. Slower than Roasty's 3200 ms breathe, which
/// is the comparison ADR-0011 used to settle the battery question.
const Duration treeSwayPeriod = Duration(seconds: 6);

/// How far the tree leans either side of upright, in degrees.
const double treeSwayDegrees = 0.8;

/// The pivot: `transform-origin: 50% 86%` in the design, which is the trunk
/// meeting the ground rather than the middle of the picture. `Alignment` runs
/// -1 (top) to 1 (bottom), so 86% down is `2 × 0.86 - 1`.
const Alignment treeSwayOrigin = Alignment(0, 0.72);

/// Radians per degree, so the conversion is named rather than inlined twice.
const double _radiansPerDegree = math.pi / 180;

/// The tree's lean at [progress] through one [treeSwayPeriod], in radians.
///
/// A cosine *is* the design's curve rather than an approximation of it: the
/// keyframes hold `-0.8°` at 0% and 100% and `+0.8°` at 50% under
/// `ease-in-out`, which is the shape `-cos` traces between its extremes — so
/// the ends are still and the middle is quickest, with no easing curve to
/// apply on top.
double treeSwayRadiansAt(double progress) =>
    -treeSwayDegrees * math.cos(progress * 2 * math.pi) * _radiansPerDegree;

/// The lean a still tree holds: upright.
///
/// Not the curve's own starting value, which is a visible `-0.8°` tilt. A tree
/// frozen mid-lean reads as a rendering bug rather than as stillness, and
/// upright is also exactly what the tree rendered before the sway existed — so
/// reduced motion and every pre-sway screenshot agree.
const double treeSwayHeldRadians = 0;
