import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The standing affordance for a swipeable deck: one card peeking on each side
/// that has a card, rising into place as the drag goes its way.
///
/// A counter is not an affordance. "Card 1 of 2" says another card *exists*;
/// only a deck that looks like a deck says the deck *moves*. Pass it to
/// `HorizontalSwipe.behind`, which is what keeps it a sibling of the transform.
class SwipeDeckStack extends StatelessWidget {
  /// Creates a [SwipeDeckStack] at the caller's own [radius].
  const SwipeDeckStack({
    required this.drag,
    required this.radius,
    this.canAdvance = false,
    this.canBack = false,
    this.shadow = _lift,
    super.key,
  });

  /// How far a sliver stands out at rest, and how small it is there — the
  /// design's 13px and 0.955, on their way to 0 and 1.
  static const double _restInset = 13;
  static const double _restScale = 0.955;

  /// How far the drag must go for a sliver to arrive fully.
  static const double _riseDistance = 104;

  /// The design's `0 10px 26px rgba(0,0,0,0.18)`.
  static const List<BoxShadow> _lift = [
    BoxShadow(color: Color(0x2E000000), blurRadius: 26, offset: Offset(0, 10)),
  ];

  /// How much accent the sliver's fill carries — the design's
  /// `color-mix(in oklab, var(--accent) 10%, var(--surface))`.
  static const double _fillShare = 0.10;

  /// How much accent its edge carries —
  /// `color-mix(in oklab, var(--accent) 52%, var(--rule))`.
  ///
  /// Full opacity, never a dimmed copy of the card: a first attempt at 0.55
  /// over a 7% fill measured 1.09:1 against the page and was invisible.
  static const double _edgeShare = 0.52;

  /// The gesture's state, as `HorizontalSwipe` hands it over.
  final SwipeDrag drag;

  /// The card's own corner radius, so the stack cannot belong to another card.
  final double radius;

  /// Whether there is a card a left swipe would bring in.
  final bool canAdvance;

  /// Whether there is one a right swipe would bring in.
  final bool canBack;

  /// The lift under the slivers.
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (canBack) _sliver(context, SwipeAim.back),
      if (canAdvance) _sliver(context, SwipeAim.advance),
    ],
  );

  Widget _sliver(BuildContext context, SwipeAim reveals) {
    final mood = context.mood;
    final rise = deckSliverRise(
      reveals: reveals,
      offset: drag.offset,
      riseDistance: _riseDistance,
    );
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(
          deckSliverOffset(reveals: reveals, inset: _restInset, rise: rise),
          0,
        ),
        child: Transform.scale(
          scale: deckSliverScale(restScale: _restScale, rise: rise),
          alignment: reveals == SwipeAim.advance
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                mood.accent.withValues(alpha: _fillShare),
                mood.surface,
              ),
              border: Border.all(
                color: Color.lerp(mood.rule, mood.accent, _edgeShare)!,
              ),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadow,
            ),
          ),
        ),
      ),
    );
  }
}
