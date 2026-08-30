/// The Coffee Tree's growth beat: the timings and curves, as pure functions.
///
/// Separated from the widget so every value below is unit-testable without
/// pumping a frame — the same split `coffee_tree_animation.dart` makes for the
/// sway. Transcribed from the design's `AnimatedTree`
/// (`prototype/flavor-wheel.jsx:211-322`), with the multi-stage walk cut per
/// ADR-0011: thresholds sit at least three lessons apart, so normal play never
/// advances more than one stage.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How long the beat waits before anything moves — the design's `delay`.
const Duration treeGrowthDelay = Duration(milliseconds: 250);

/// The cross-fade from the old frame to the new one.
const Duration treeCrossfadeDuration = Duration(milliseconds: 360);

/// The settle the new frame lands with.
const Duration treeBounceDuration = Duration(milliseconds: 600);

/// The ring that blooms out of the tree as it lands.
const Duration treeGlowDuration = Duration(milliseconds: 900);

/// How long a leaf takes to drift out and fade.
const Duration treeLeafDuration = Duration(milliseconds: 1200);

/// How long after the bounce starts the leaves begin.
const Duration treeLeafLead = Duration(milliseconds: 80);

/// The gap between one leaf's start and the next.
const Duration treeLeafStagger = Duration(milliseconds: 60);

/// How long after the bounce starts the beat hands over.
///
/// Not the end of the leaves: the design calls back while the last of them are
/// still drifting, so the content behind arrives without a dead pause.
const Duration treeGrowthHandover = Duration(milliseconds: 900);

/// Leaves thrown by one growth.
const int treeLeafCount = 7;

/// The pivot everything turns about: the trunk meeting the ground, not the
/// middle of the picture. The design's `transform-origin: 50% 86%`, and the
/// same pivot the sway already uses.
const Alignment treeGrowthOrigin = Alignment(0, 0.72);

/// The design's `cubic-bezier(0.2, 0.9, 0.3, 1.0)` — the cross-fade's motion.
const Curve treeCrossfadeCurve = Cubic(0.2, 0.9, 0.3, 1);

/// How far the arriving frame rises, in logical pixels.
const double treeCrossfadeRise = 8;

/// The scale the arriving frame grows from.
const double treeCrossfadeScaleFrom = 0.94;

/// The bounce, as the design's four keyframes:
/// `0.85 → 1.06 (55%) → 0.98 (80%) → 1`.
///
/// Written as a table rather than a spring so it is the design's curve rather
/// than an approximation of it.
double treeBounceScaleAt(double progress) {
  final phase = progress.clamp(0.0, 1.0);
  const stops = [0.0, 0.55, 0.8, 1.0];
  const scales = [0.85, 1.06, 0.98, 1.0];
  for (var index = 1; index < stops.length; index++) {
    if (phase > stops[index]) continue;
    final span = stops[index] - stops[index - 1];
    final within = span == 0 ? 0.0 : (phase - stops[index - 1]) / span;
    return scales[index - 1] + (scales[index] - scales[index - 1]) * within;
  }
  return scales.last;
}

/// The glow ring's opacity: `0 → 0.8 at 40% → 0`.
double treeGlowOpacityAt(double progress) {
  final phase = progress.clamp(0.0, 1.0);
  const peak = 0.4;
  const peakOpacity = 0.8;
  return phase <= peak
      ? peakOpacity * (phase / peak)
      : peakOpacity * (1 - (phase - peak) / (1 - peak));
}

/// The glow ring's scale: `0.6 → 2.2`, linear across its life.
double treeGlowScaleAt(double progress) {
  const from = 0.6;
  const to = 2.2;
  return from + (to - from) * progress.clamp(0.0, 1.0);
}

/// Where the leaf at [index] drifts to, as an offset from the tree's centre.
///
/// **Deterministic, where the design rolls dice.** `AnimatedTree` randomises
/// each leaf's distance and spin per render; a fixed spread of the same shape
/// costs the viewer nothing — no two leaves share a heading either way — and
/// buys a widget whose output can be asserted, and a golden that does not
/// flicker between runs.
({double dx, double dy, double turns}) treeLeafDrift(int index) {
  final angle = (index / treeLeafCount) * 2 * math.pi + _leafRingOffset;
  final distance = _leafNearestDrift + (index % _leafVariants) * _leafDriftStep;
  return (
    dx: math.cos(angle) * distance,
    dy: math.sin(angle) * distance - _leafRise,
    // A half turn either way, spread evenly across the spray.
    turns: -_leafHalfTurn + (index / (treeLeafCount - 1)),
  );
}

/// Where the ring of leaves starts, so no leaf leaves straight up — the
/// design's `+ 0.3`.
const double _leafRingOffset = 0.3;

/// The closest a leaf drifts. The design rolls `70 + random() * 50`; the
/// spread below walks that span instead.
const double _leafNearestDrift = 70;

/// How much further each successive variant drifts.
const double _leafDriftStep = 25;

/// How many drift distances the spray cycles through.
const int _leafVariants = 3;

/// How far the whole spray is lifted, so it leaves the canopy rather than the
/// roots — the design's `- 30`.
const double _leafRise = 30;

/// The furthest a leaf spins either way, in turns.
const double _leafHalfTurn = 0.5;

/// Whether the leaf at [index] is one of the small accent dots rather than a
/// sage leaf — the design's `i % 3 === 0`.
bool treeLeafIsDot(int index) => index % _leafVariants == 0;

/// The whole beat, from the opening delay to the last leaf settling.
///
/// What the widget's one controller runs for, so every phase below can be read
/// off a single normalised value.
Duration get treeGrowthTotal =>
    treeGrowthDelay +
    treeCrossfadeDuration +
    treeLeafLead +
    treeLeafStagger * (treeLeafCount - 1) +
    treeLeafDuration;

/// A phase's own `0..1` progress at [elapsed], given when it [starts] and how
/// long it [lasts]. Zero before it starts, one after it ends.
double phaseProgress({
  required Duration elapsed,
  required Duration starts,
  required Duration lasts,
}) {
  if (lasts.inMicroseconds <= 0) return 1;
  final into = elapsed.inMicroseconds - starts.inMicroseconds;
  if (into <= 0) return 0;
  return (into / lasts.inMicroseconds).clamp(0.0, 1.0);
}
