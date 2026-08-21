import 'dart:math' as math;

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:flutter/material.dart';

// Animation switches handle the states with special motion and default the
// rest; enumerating every no-op state would bloat these mascot switches.
// ignore_for_file: no_default_cases

/// Controller duration for the Roasty mascot's [state] animation.
Duration roastyDuration(RoastyState state) {
  switch (state) {
    case RoastyState.idle:
      return const Duration(milliseconds: 3200); // breathe loop
    case RoastyState.correct:
      return const Duration(milliseconds: 900); // hop one-shot
    case RoastyState.wrong:
      return const Duration(milliseconds: 500); // shake one-shot
    case RoastyState.lesson:
      return const Duration(milliseconds: 1100); // jump one-shot
    case RoastyState.module:
      return const Duration(milliseconds: 900); // grow one-shot
    case RoastyState.card:
      return const Duration(milliseconds: 1600); // shimmer loop
    case RoastyState.sleep:
      return const Duration(milliseconds: 3400); // slow breathe loop
    case RoastyState.awake:
      return const Duration(milliseconds: 400); // blink-pop one-shot
  }
}

/// Controller value to hold when a [RoastyState] is painted without animation
/// (`Roasty(animate: false)` or reduced motion). A neutral resting pose: the
/// body math is at rest at `t = 0`, and the face is state-driven (not
/// `t`-driven) so the right expression still shows. Pure, so a frame can be
/// frozen without a ticker.
double roastyStaticFrame(RoastyState state) => 0;

/// Whether [state]'s animation repeats (vs. plays once).
bool roastyLoops(RoastyState state) {
  switch (state) {
    case RoastyState.idle:
    case RoastyState.card:
    case RoastyState.sleep:
      return true;
    case RoastyState.correct:
    case RoastyState.wrong:
    case RoastyState.lesson:
    case RoastyState.module:
    case RoastyState.awake:
      return false;
  }
}

/// Body translation for [state] at controller progress [t] (0..1).
Offset roastyBodyOffset(RoastyState state, double t) {
  switch (state) {
    case RoastyState.idle:
      // breathe: translateY 0 → -3 → 0
      final v = math.sin(t * math.pi * 2);
      return Offset(0, -3 * (v * 0.5 + 0.5) * math.sin(t * math.pi));
    case RoastyState.correct:
      // hop: -10 at 25% and 75%, 0 at 0/50/100%
      final hop = math.sin(t * math.pi * 2).abs();
      return Offset(0, -10 * hop);
    case RoastyState.wrong:
      // shake: ±5 → ±3
      final amp = (1 - t) * 5;
      final dx = math.sin(t * math.pi * 8) * amp;
      return Offset(dx, 0);
    case RoastyState.lesson:
      // jump: 0 → -18 → -8 → -14 → 0
      if (t < 0.3) {
        return Offset(0, -18 * (t / 0.3));
      } else if (t < 0.5) {
        final p = (t - 0.3) / 0.2;
        return Offset(0, -18 + 10 * p);
      } else if (t < 0.7) {
        final p = (t - 0.5) / 0.2;
        return Offset(0, -8 - 6 * p);
      } else {
        final p = (t - 0.7) / 0.3;
        return Offset(0, -14 + 14 * p);
      }
    default:
      return Offset.zero;
  }
}

/// Body scale for [state] at controller progress [t] (0..1).
double roastyBodyScale(RoastyState state, double t) {
  switch (state) {
    case RoastyState.module:
      // grow: 1 → 1.12 → 1.05
      if (t < 0.4) return 1 + 0.12 * (t / 0.4);
      return 1.12 - 0.07 * ((t - 0.4) / 0.6);
    case RoastyState.awake:
      // blink-pop: 0.94 → 1.04 → 1
      if (t < 0.5) return 0.94 + (1.04 - 0.94) * (t / 0.5);
      return 1.04 - (1.04 - 1.0) * ((t - 0.5) / 0.5);
    case RoastyState.idle:
      // subtle 0.5% squash on the breath beat
      final v = math.sin(t * math.pi * 2);
      return 1.0 + 0.005 * v;
    default:
      return 1;
  }
}

/// Body rotation (radians) for [state] at controller progress [t] (0..1).
double roastyBodyRotation(RoastyState state, double t) {
  switch (state) {
    case RoastyState.correct:
      // ±3° rotate on hop peaks
      final s = math.sin(t * math.pi * 2);
      return (s * 3) * math.pi / 180;
    case RoastyState.sleep:
      // permanent 6° tilt
      return 6 * math.pi / 180;
    default:
      return 0;
  }
}
