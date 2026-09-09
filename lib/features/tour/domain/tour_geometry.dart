import 'dart:math' as math;

import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/painting.dart';

/// Where the Tour's frame and card go, as arithmetic.
///
/// Pure and separate from the layer that draws it, so every number the design
/// gives this overlay can be checked without measuring a widget — the only way
/// to check them at all, since a frame caught mid-animation looks the same as
/// one in the wrong place. The figures themselves live in [OffTokens].

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
/// [topGap] is how far the target's top sits below the feed's top edge, and
/// [bottomOverflow] how far its bottom runs past the room the card needs. Too
/// high is pushed down to the [OffTokens.tourScrollTopGap] line, too low is
/// pulled up but never above it. Positive scrolls the feed down.
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

/// The top edge of a card [cardHeight] tall, on a layer [areaHeight] tall.
///
/// The design picks a side; where that side cannot hold the card clear of
/// [safeArea] and the other can, the other one takes it. The mock the rule is
/// drawn against has no status bar, so above a tall target near the top of the
/// feed the card ran under the clock on a real phone.
double tourCardTop({
  required Rect? target,
  required double areaHeight,
  required double cardHeight,
  required EdgeInsets safeArea,
}) {
  final gap = OffTokens.tourCardInset.value;
  final highest = safeArea.top + gap;
  final lowest = areaHeight - safeArea.bottom - gap - cardHeight;
  // A card with less room than it has height shows its top — the counter, the
  // title and the start of the body — rather than its buttons alone.
  if (lowest < highest) return highest;

  final sides = _tourCardSides(
    target: target,
    areaHeight: areaHeight,
    cardHeight: cardHeight,
  );
  for (final side in sides) {
    if (side >= highest && side <= lowest) return side;
  }
  return sides.first.clamp(highest, lowest);
}

/// Where the card could go, the design's own side first.
List<double> _tourCardSides({
  required Rect? target,
  required double areaHeight,
  required double cardHeight,
}) {
  final gap = OffTokens.tourCardInset.value;
  if (target == null) {
    return [areaHeight - OffTokens.tourCardRestingBottom.value - cardHeight];
  }
  final below = target.bottom + gap;
  final above = target.top - gap - cardHeight;
  return tourCardSitsBelow(target: target, areaHeight: areaHeight)
      ? [below, above]
      : [above, below];
}
