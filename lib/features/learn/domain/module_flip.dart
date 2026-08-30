/// The module ending's card flip, as arithmetic.
///
/// The screen turns over on a 3D Y-rotation — the design's most distinctive
/// moment (`rewards.jsx:236-241`). The maths lives here so the turn can be
/// reasoned about and tested without pumping a screen, and so the one rule
/// that is easy to get wrong — when the faces swap — is stated once.
library;

import 'dart:math' as math;

/// The design's `transition: transform 820ms`.
const Duration flipDuration = Duration(milliseconds: 820);

/// Where in the turn the faces swap.
///
/// The edge-on frame: the card is side-on to the viewer and neither face has
/// any width, so this is the only moment a swap cannot be seen.
const double flipHalfway = 0.5;

/// The resting turn for each side, in whole rotations.
///
/// Used for the reduced-motion path, which has no tween to sample: it jumps
/// between the two rest positions.
double flipTurns({required bool showingBack}) => showingBack ? flipHalfway : 0;

/// The Y-rotation, in radians, at [progress] through the turn.
///
/// Half a rotation end to end: the back face is drawn already turned, so the
/// pair reads as one card rather than two.
double flipAngle(double progress) => progress * math.pi;

/// Which face is the visible one at [progress].
///
/// **Exactly one face may be built.** Both occupy the same box, and a face
/// left in the tree past the midpoint is seen mirror-imaged through the rest
/// of the turn — the artefact the design's own `backfaceVisibility` prevents,
/// which Flutter has no equivalent of.
bool flipShowsBack(double progress) => progress >= flipHalfway;
