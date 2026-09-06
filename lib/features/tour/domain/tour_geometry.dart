import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Where the Tour's frame and card go, as arithmetic.
///
/// Pure and separate from the layer that draws it, so every number the design
/// gives this overlay can be checked without measuring a widget — which is the
/// only way to check them at all, since a frame caught mid-animation looks the
/// same as one in the wrong place.

/// How far the frame stands off the widget it surrounds.
///
/// The design's `left: rect.x - 6 … width: rect.w + 12` — an even inset on all
/// four sides, which is what makes it read as a frame around the target rather
/// than a border on it.
const double tourFrameInset = 6;

/// The gap between the frame and the card, above or below it. The design's
/// `top: rect.y + rect.h + 20` and its mirror.
const double tourCardGap = 20;

/// How much room the card needs under a target before it will sit below it.
///
/// The design's `below = (rect.y + rect.h) < (rect.areaH - 330)`. It is a
/// measurement of the card, not a margin: a target lower than this leaves the
/// card hanging off the bottom of the screen, so the card goes above instead.
const double tourCardHeadroom = 330;

/// Where the card sits when nothing has been measured yet — the design's
/// `bottom: 140` fallback, which keeps the first frame from flashing the card
/// against the screen edge.
const double tourCardRestingBottom = 140;

/// How far below the feed's top edge a target is brought before it is framed.
///
/// The design's `140`. Less than this and the frame would be under the header
/// floating over the page.
const double tourScrollTopGap = 140;

/// How much room below a target the scroll keeps clear for the card. The
/// design's `+ 250`.
const double tourScrollCardClearance = 250;

/// The frame around [target] — the target, stood off by [tourFrameInset].
Rect tourFrameRect(Rect target) => target.inflate(tourFrameInset);

/// Whether the card sits below [target] rather than above it, on a layer
/// [areaHeight] tall.
///
/// Measured against the *target*, not the frame: the design chooses the side
/// from the widget being introduced, and the frame is drawn around it either
/// way.
bool tourCardSitsBelow({required Rect target, required double areaHeight}) =>
    target.bottom < areaHeight - tourCardHeadroom;

/// How far the feed scrolls to bring a target into a framable position.
///
/// The design's own rule, in its own terms: [topGap] is how far the target's
/// top sits below the feed's top edge, and [bottomOverflow] is how far its
/// bottom runs past the room the card needs. A target too high is pushed down
/// to the [tourScrollTopGap] line; one too low is pulled up, but never so far
/// that it rises above that same line. Anything already framable moves not at
/// all.
///
/// Positive scrolls the feed down (the content moves up), which is the sign
/// `ScrollPosition.pixels` uses.
double tourScrollDelta({
  required double topGap,
  required double bottomOverflow,
}) {
  if (topGap < tourScrollTopGap) return topGap - tourScrollTopGap;
  if (bottomOverflow > 0) {
    return math.min(bottomOverflow, topGap - tourScrollTopGap);
  }
  return 0;
}

/// How far past the room the card needs [target] runs, on a feed viewport
/// [viewportHeight] tall.
///
/// Named rather than inlined at the call site because it is half of
/// [tourScrollDelta]'s contract and the two are read together.
double tourBottomOverflow({
  required Rect target,
  required double viewportHeight,
}) => target.bottom - viewportHeight + tourScrollCardClearance;
