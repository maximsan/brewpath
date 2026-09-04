/// The turn a reward screen makes to show the card on its back.
///
/// **Both endings turn the same way.** The lesson ending flips on demand, when
/// the New-card row is pressed; the module ending flips as the ceremony's own
/// beat, from its primary button. The speed and the depth are the same on
/// both, so they live here rather than beside either screen — two copies of
/// 820ms is how the two moments would come to feel like different gestures.
///
/// The geometry itself is `flip_geometry.dart`, re-exported so a screen reads
/// one import: the split is about which half is shared with the flashcard
/// drill, which turns much faster.
library;

import 'package:flutter/widgets.dart';

export 'package:brew_path/core/widgets/flip_geometry.dart';

/// The design's `transition: transform 820ms`.
const Duration rewardFlipDuration = Duration(milliseconds: 820);

/// The design's `cubic-bezier(.62, .04, .2, 1)` — a turn that leaves quickly
/// and arrives slowly, so the card lands rather than stops.
const Cubic rewardFlipCurve = Cubic(0.62, 0.04, 0.2, 1);

/// The design's `perspective: 1800` — the depth that makes the turn read as a
/// card rather than a squash. Matrix4 wants its reciprocal.
const double rewardFlipPerspective = 1 / 1800;

/// `perspectiveOrigin: 50% 42%` — slightly above centre, so the turn pivots
/// about the celebration rather than about the footer.
const Alignment rewardFlipOrigin = Alignment(0, -0.16);
