import 'dart:math' as math;

import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/painting.dart';

/// Where the Tour's frame and card go, as arithmetic.
///
/// Pure and separate from the layer that draws it, so every number the design
/// gives this overlay can be checked without measuring a widget — which is the
/// only way to check them at all, since a frame caught mid-animation looks the
/// same as one in the wrong place.
///
/// The figures themselves live in [OffTokens], with the rest of the design's
/// off-scale values; this file is the rules they parameterise.

/// The frame around [target] — the target, stood off by
/// [OffTokens.tourFrameInset].
Rect tourFrameRect(Rect target) =>
    target.inflate(OffTokens.tourFrameInset.value);

/// Whether the card sits below [target] rather than above it, on a layer
/// [areaHeight] tall.
///
/// Measured against the *target*, not the frame: the design chooses the side
/// from the widget being introduced, and the frame is drawn around it either
/// way.
bool tourCardSitsBelow({required Rect target, required double areaHeight}) =>
    target.bottom < areaHeight - OffTokens.tourCardHeadroom.value;

/// How far the feed scrolls to bring a target into a framable position.
///
/// The design's own rule, in its own terms: [topGap] is how far the target's
/// top sits below the feed's top edge, and [bottomOverflow] is how far its
/// bottom runs past the room the card needs. A target too high is pushed down
/// to the [OffTokens.tourScrollTopGap] line; one too low is pulled up, but
/// never so far that it rises above that same line. Anything already framable
/// moves not at all.
///
/// Positive scrolls the feed down (the content moves up), which is the sign
/// `ScrollPosition.pixels` uses.
double tourScrollDelta({
  required double topGap,
  required double bottomOverflow,
}) {
  final line = OffTokens.tourScrollTopGap.value;
  if (topGap < line) return topGap - line;
  if (bottomOverflow > 0) return math.min(bottomOverflow, topGap - line);
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
}) => target.bottom - viewportHeight + OffTokens.tourScrollCardClearance.value;
