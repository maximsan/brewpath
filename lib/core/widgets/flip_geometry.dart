/// A card turning over on a 3D Y-rotation, as arithmetic.
///
/// The geometry only — how far round the card is, how much of a face still
/// points at the viewer, and which face that is. **How long the turn takes and
/// how it eases are the caller's**, because two surfaces turn cards at
/// deliberately different speeds: the module ending's is the app's most
/// distinctive moment at 820ms, a flashcard flips in 480 because the learner
/// is about to do it a dozen more times.
///
/// Pure, and beside no screen, so a turn can be reasoned about and tested
/// without pumping a widget.
library;

import 'dart:math' as math;

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
