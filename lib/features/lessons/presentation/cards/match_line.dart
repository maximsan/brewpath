/// The connector a match board draws from a trait to the answer it landed on,
/// with no canvas attached.
///
/// Geometry and timing both live here because the board's painter is the only
/// thing that consumes them, and neither can be checked by pumping a board:
/// a line is one stroke among several on one canvas (#566).
library;

import 'dart:ui';

import 'package:brew_path/shared/theme/app_motion.dart';
import 'package:flutter/animation.dart';

/// The design's `strokeWidth="2.5"` on the connector.
const double matchLineStroke = 2.5;

/// The design's arrowhead `size = 11`.
const double matchArrowSize = 11;

/// The design's arrowhead `spread = 0.44`, in radians off the line.
const double matchArrowSpread = 0.44;

/// The design's `stroke-dashoffset 360ms` — the line drawing itself in.
const Duration matchLineDrawDuration = Duration(milliseconds: 360);

/// The design's `cubic-bezier(.3,1,.4,1)` on that draw.
const Curve matchLineDrawCurve = Cubic(0.3, 1, 0.4, 1);

/// The design's `opacity 180ms ease 240ms` on the arrowhead.
const Duration matchArrowFadeDuration = Duration(milliseconds: 180);

/// How long the arrowhead waits before it fades in.
const Duration matchArrowFadeDelay = Duration(milliseconds: 240);

/// One run of the whole connector: the draw, then the delayed head.
///
/// The head outlasts the line — 240 + 180 against 360 — so the run is the
/// later of the two rather than the line's own duration.
const Duration matchLineRunDuration = Duration(milliseconds: 420);

/// The design's own transition on `.match-item`: `border-color 150ms ease,
/// box-shadow 150ms ease, background 150ms ease, transform 150ms ease`.
const Duration matchTileTransition = Duration(milliseconds: 150);

/// The design's `matchSnap 320ms` on an answer that just locked.
const Duration matchSnapDuration = AppMotion.expand;

/// The design's `cubic-bezier(.3,1.3,.5,1)` on that snap. It overshoots, which
/// is what makes the tile read as caught rather than resized.
const Curve matchSnapCurve = Cubic(0.3, 1.3, 0.5, 1);

/// The design's `matchWrongShake 400ms ease` on both tiles of a bad drop.
const Duration matchWrongShakeDuration = Duration(milliseconds: 400);

/// How long the design leaves a wrong pair marked: `setTimeout(…, 480)`.
const Duration matchWrongHoldDuration = Duration(milliseconds: 480);

/// The design's `matchSnap`: `scale(1)` → `1.06` at 45% → `1`.
const List<double> _snapStops = [1, 1.06, 1];

/// Where each of [_snapStops] sits in the run.
const List<double> _snapStopsAt = [0, 0.45, 1];

/// The design's `matchWrongShake`: `translateX` 0, -5, 5, -3, 3, 0 at every
/// fifth of the run.
const List<double> _shakeStops = [0, -5, 5, -3, 3, 0];

/// How large a snapping answer is drawn [progress] through its animation,
/// which is already eased by [matchSnapCurve].
double matchSnapScale(double progress) =>
    _atStops(_snapStops, _snapStopsAt, progress, atRest: 1);

/// How far a wrong tile has slid sideways [progress] through its shake.
double matchShakeOffset(double progress) =>
    _atStops(_shakeStops, _evenly(_shakeStops.length), progress, atRest: 0);

/// How much of the line is drawn [elapsed] into the run, eased.
double matchLineDrawFraction(Duration elapsed) => matchLineDrawCurve.transform(
  _fraction(elapsed.inMicroseconds / matchLineDrawDuration.inMicroseconds),
);

/// How opaque the arrowhead is [elapsed] into the run, after its delay.
double matchArrowOpacity(Duration elapsed) => _fraction(
  (elapsed - matchArrowFadeDelay).inMicroseconds /
      matchArrowFadeDuration.inMicroseconds,
);

/// The two barbs of the arrowhead landing at [to], coming from [from].
///
/// A zero-length connector has no direction to point along, so it takes the
/// tip twice rather than a NaN angle — a trait cannot be dropped on itself,
/// but a board measured mid-layout can hand back two equal anchors.
List<Offset> matchArrowBarbs({
  required Offset from,
  required Offset to,
  double size = matchArrowSize,
  double spread = matchArrowSpread,
}) {
  final line = to - from;
  if (line.distance == 0) return [to, to];
  final angle = line.direction;
  return [
    to - Offset.fromDirection(angle - spread, size),
    to - Offset.fromDirection(angle + spread, size),
  ];
}

/// [count] stop positions spread evenly from 0 to 1.
List<double> _evenly(int count) => [
  for (var index = 0; index < count; index++) index / (count - 1),
];

/// Clamps a raw ratio into the 0–1 a keyframe reads.
double _fraction(double ratio) => ratio.clamp(0.0, 1.0);

/// Reads [stops] placed at [positions] at [progress], holding [atRest] off
/// either end so an animation that has not started draws its resting frame.
double _atStops(
  List<double> stops,
  List<double> positions,
  double progress, {
  required double atRest,
}) {
  if (progress <= 0 || progress >= 1) return atRest;
  for (var index = 0; index < stops.length - 1; index++) {
    final from = positions[index];
    final to = positions[index + 1];
    if (progress > to) continue;
    final within = (progress - from) / (to - from);
    return lerpDouble(stops[index], stops[index + 1], within)!;
  }
  return atRest;
}
