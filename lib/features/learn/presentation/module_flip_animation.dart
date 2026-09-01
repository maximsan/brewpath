/// The module ending's card flip: how long it takes, and how it eases.
///
/// The screen turns over on a 3D Y-rotation — the design's most distinctive
/// moment (`rewards.jsx:236-241`). The geometry of that turn is shared with
/// the flashcard drill and lives in `flip_geometry.dart`; what is here is the
/// half this screen owns, because the two turn at deliberately different
/// speeds.
///
/// Re-exported so the screen and its tests keep reading one import: the split
/// is about where the maths lives, not about making every caller name two
/// files.
library;

import 'package:flutter/animation.dart';

export 'package:brew_path/core/widgets/flip_geometry.dart';

/// The design's `transition: transform 820ms`.
const Duration flipDuration = Duration(milliseconds: 820);

/// The design's `cubic-bezier(.62, .04, .2, 1)` — a turn that leaves quickly
/// and arrives slowly, so the card lands rather than stops.
const Cubic flipCurve = Cubic(0.62, 0.04, 0.2, 1);
