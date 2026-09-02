/// What the Cards grid shows, and what the footer counts.
///
/// The design does not lay out the whole locked set. It shows every card the
/// learner has earned, exactly **one** locked card as a teaser, and a footer
/// naming how many are still to collect — so the grid grows as the collection
/// does instead of opening as a wall of blanks (#396).
///
/// Both rules are here rather than in the screen because they are arithmetic
/// over a list, and the off-by-one in the footer is the kind of thing a widget
/// test sees badly: the teaser is *visible* and still *counted*, which reads as
/// a bug until you check it against the design.
library;

import 'package:brew_path/features/cards/domain/cards_providers.dart';

/// A card the grid draws, and where it sits in the **whole** catalogue.
///
/// The place is the catalogue's, not the grid's: cards unlock out of order, so
/// the grid shows gaps — 01, 04, 21 — and the number is what tells a learner
/// *which* card this is rather than how many tiles precede it
/// (`screens.jsx:2394`). It is 1-based, as the design prints it.
typedef PlacedCard = ({CardWithCollection item, int place, int total});

/// `04 / 37` — the design's own padding and separator (`screens.jsx:2397`).
///
/// Here rather than in the widget because it is arithmetic over the set, like
/// everything else in this file, and it can be checked without pumping one.
String formatCardPlace(PlacedCard placed) =>
    '${placed.place.toString().padLeft(2, '0')} / ${placed.total}';

/// The cards the grid draws, in authored order.
///
/// Every collected card, plus the first uncollected one as a teaser. The
/// teaser keeps its **authored position** rather than being appended — the
/// design maps over the whole set in order and drops the locked cards after
/// the first, so a teaser can sit between two earned cards.
///
/// A complete collection has no teaser, and an empty one is a single teaser.
List<PlacedCard> cardsGridItems(List<CardWithCollection> all) {
  final shown = <PlacedCard>[];
  var teased = false;
  for (final (index, item) in all.indexed) {
    final placed = (item: item, place: index + 1, total: all.length);
    if (item.isCollected) {
      shown.add(placed);
    } else if (!teased) {
      shown.add(placed);
      teased = true;
    }
  }
  return shown;
}

/// How many cards are still uncollected.
///
/// **Counts the teaser the grid is showing.** The design reads
/// `total - earned`, so a learner looking at one locked tile above a footer
/// saying "3 more to collect" is seeing the truth: that tile is one of the
/// three. Subtracting it would name the cards they cannot see, which is a
/// different and less useful number.
int unearnedRemainder(List<CardWithCollection> all) =>
    all.where((item) => !item.isCollected).length;

/// How many cards the learner has earned.
int earnedCount(List<CardWithCollection> all) =>
    all.where((item) => item.isCollected).length;
