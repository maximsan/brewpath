/// The one horizontal swipe, as arithmetic.
///
/// The direction contract, the damped block, the commit decision, the tilt and
/// the deck's rise, with no widget around them — so a gesture the whole app
/// shares can be reasoned about and tested without pumping anything
/// ([#610](https://github.com/maximsan/brewpath/issues/610)).
library;

import 'dart:math' as math;

/// Which way a swipe is heading. **Direction is a contract, app-wide.**
///
/// A destructive action gets no swipe at all: the same motion must never mean
/// "keep this for later" on one screen and "destroy it" on another.
enum SwipeAim {
  /// Left — next card, next step.
  advance,

  /// Right — back, or set aside.
  back,
}

/// What the gesture is doing right now.
enum SwipePhase {
  /// Still, or settling back to centre after a release that did not commit.
  rest,

  /// Following a finger.
  dragging,

  /// Flying off after a committed swipe.
  exiting,
}

/// What a caller paints against while the gesture runs.
class SwipeDrag {
  /// Creates a [SwipeDrag]. The default is the gesture at rest.
  const SwipeDrag({
    this.offset = 0,
    this.travel = 0,
    this.progress = 0,
    this.phase = SwipePhase.rest,
  });

  /// A drag of [offset] with [travel] of finger behind it, carrying the
  /// progress [commitThreshold] makes of it.
  factory SwipeDrag.at({
    required double offset,
    required double travel,
    required double commitThreshold,
    required SwipePhase phase,
  }) => SwipeDrag(
    offset: offset,
    travel: travel,
    progress: swipeCommitProgress(
      offset: offset,
      commitThreshold: commitThreshold,
    ),
    phase: phase,
  );

  /// How far the element has actually moved — damped on a blocked direction.
  final double offset;

  /// The finger's own distance, undamped. What a blocked direction's caption
  /// is driven from; see [swipeCaptionOpacity].
  final double travel;

  /// Signed `-1..1`: how much of the commit threshold [offset] has covered.
  final double progress;

  /// What the gesture is doing right now.
  final SwipePhase phase;

  /// Whether a finger is on the element.
  bool get isDragging => phase == SwipePhase.dragging;

  /// Whether a committed swipe is flying off.
  bool get isExiting => phase == SwipePhase.exiting;
}

/// How much of a blocked direction's travel the element may actually move.
///
/// The design's 22%: an element that resists reads as "nothing that way", one
/// that freezes reads as broken.
const double swipeBlockedDamping = 0.22;

/// The finger distance at which a blocked direction's caption is fully opaque.
const double swipeCaptionTravel = 30;

/// Which way [distance] is heading, or `null` before the finger has moved.
SwipeAim? swipeAimOf(double distance) {
  if (distance == 0) return null;
  return distance < 0 ? SwipeAim.advance : SwipeAim.back;
}

/// Whether the surface refuses the direction [distance] is heading in.
bool swipeIsBlocked({
  required double distance,
  required bool canAdvance,
  required bool canBack,
}) => switch (swipeAimOf(distance)) {
  SwipeAim.advance => !canAdvance,
  SwipeAim.back => !canBack,
  null => false,
};

/// How far the element may be for [distance] of finger on this surface.
///
/// The block and the damping in one step, so no caller can apply one without
/// the other.
double swipeOffsetFor({
  required double distance,
  required bool canAdvance,
  required bool canBack,
  required double maxDrag,
}) => swipeOffset(
  distance: distance,
  blocked: swipeIsBlocked(
    distance: distance,
    canAdvance: canAdvance,
    canBack: canBack,
  ),
  maxDrag: maxDrag,
);

/// How far the element moves for [distance] of finger.
double swipeOffset({
  required double distance,
  required bool blocked,
  required double maxDrag,
}) => (blocked ? distance * swipeBlockedDamping : distance).clamp(
  -maxDrag,
  maxDrag,
);

/// The finger's own distance, held to the same ceiling as the movement.
double swipeTravel({required double distance, required double maxDrag}) =>
    distance.clamp(-maxDrag, maxDrag);

/// A blocked direction's caption opacity at [travel] of finger.
///
/// Driven by the gesture, never by the damped movement: keyed to the 22%
/// offset, a 60px swipe captioned itself at 0.3 over 13px of travel, which
/// read as a dead list.
double swipeCaptionOpacity(double travel) =>
    (travel.abs() / swipeCaptionTravel).clamp(0.0, 1.0);

/// Which way a release at [offset] commits, or `null` for a snap back.
SwipeAim? swipeCommit({
  required double offset,
  required double commitThreshold,
  required bool canAdvance,
  required bool canBack,
}) {
  if (offset <= -commitThreshold && canAdvance) return SwipeAim.advance;
  if (offset >= commitThreshold && canBack) return SwipeAim.back;
  return null;
}

/// Signed `-1..1`: how much of [commitThreshold] the element has covered.
double swipeCommitProgress({
  required double offset,
  required double commitThreshold,
}) => (offset / commitThreshold).clamp(-1.0, 1.0);

/// The tilt, in radians, of an element [offset] from centre.
///
/// A card that pivots as it leaves reads as a physical object being thrown;
/// pure translation reads as a slide control.
double swipeTilt({required double offset, required double degreesPer100px}) =>
    (offset / _tiltSpan) * degreesPer100px * _radiansPerDegree;

/// The span the design states a tilt over: so many degrees per 100px moved.
const double _tiltSpan = 100;

/// Degrees are what the design writes; radians are what Flutter turns in.
const double _radiansPerDegree = math.pi / 180;

/// Where a committed swipe flies to, off the side it is heading for.
double swipeExitOffset({required SwipeAim aim, required double exitDistance}) =>
    aim == SwipeAim.advance ? -exitDistance : exitDistance;

/// How far the sliver that [reveals] brings in has risen, `0`–`1`.
///
/// It follows [offset] the whole way, so the exit — which carries the card far
/// past [riseDistance] — drives it to full size as the old card leaves.
double deckSliverRise({
  required SwipeAim reveals,
  required double offset,
  required double riseDistance,
}) {
  final toward = reveals == SwipeAim.advance ? -offset : offset;
  return (toward / riseDistance).clamp(0.0, 1.0);
}

/// The sliver's horizontal offset at [rise] — [inset] out at rest, home at 1.
double deckSliverOffset({
  required SwipeAim reveals,
  required double inset,
  required double rise,
}) => (reveals == SwipeAim.advance ? inset : -inset) * (1 - rise);

/// The sliver's scale at [rise]. Depth comes from offset and scale, which cost
/// no contrast — unlike the dimmed copy that measured 1.09:1 and vanished.
double deckSliverScale({required double restScale, required double rise}) =>
    restScale + (1 - restScale) * rise;
