/// The module ending's card flip, as arithmetic.
///
/// The screen turns over on a 3D Y-rotation — the design's most distinctive
/// moment (`rewards.jsx:236-241`). The maths lives beside the screen rather
/// than inside it so the turn can be reasoned about and tested without pumping
/// a widget.
library;

import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// The design's `transition: transform 820ms`.
const Duration flipDuration = Duration(milliseconds: 820);

/// The design's `cubic-bezier(.62, .04, .2, 1)` — a turn that leaves quickly
/// and arrives slowly, so the card lands rather than stops.
const Cubic flipCurve = Cubic(0.62, 0.04, 0.2, 1);

/// **The turn's own progress**, `0` face-on to `1` fully over.
///
/// Not rotations: half a rotation *is* the whole turn here, so a value of
/// `0.5` is the card side-on to the viewer and invisible. Conflating the two
/// is what once left reduced-motion users looking at a blank screen.
const double flipFaceOn = 0;

/// The far side's resting progress. See [flipFaceOn] for why it is `1`.
const double flipTurnedOver = 1;

/// Where in the turn the faces swap — the edge-on frame, the only moment a
/// swap cannot be seen.
const double flipSwapPoint = 0.5;

/// Where the turn rests for each side.
///
/// Used by the reduced-motion path, which has no tween to sample: it jumps
/// straight to the rest position rather than playing a faster rotation.
double flipRestValue({required bool showingBack}) =>
    showingBack ? flipTurnedOver : flipFaceOn;

/// The Y-rotation, in radians, at [progress] through the turn.
double flipAngle(double progress) => progress * math.pi;

/// How much of a face's width still faces the viewer at [progress].
///
/// `1` face-on, `0` edge-on. Exposed so a test can assert that a face the
/// learner is meant to be reading is actually readable, rather than merely
/// present in the tree.
double flipVisibleFraction(double progress) =>
    math.cos(flipAngle(progress)).abs();

/// Which face is the visible one at [progress].
///
/// **Exactly one face may be built.** Both occupy the same box, and a face
/// left in the tree past the swap is seen mirror-imaged through the rest of
/// the turn — the artefact the design's `backfaceVisibility` prevents, which
/// Flutter has no equivalent of.
bool flipShowsBack(double progress) => progress >= flipSwapPoint;
