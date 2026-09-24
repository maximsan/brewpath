/// What the Cards grid shows, and what the footer counts.
///
/// Every earned card, exactly one locked card as a teaser, and a footer
/// naming how many are still to collect (#396). Here rather than in the
/// screen because both rules are arithmetic over a list, and the footer's
/// off-by-one reads as a bug until checked against the design.
library;

import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';

/// A card the grid draws, and where it sits in the **whole** catalogue.
///
/// The place is the catalogue's, not the grid's: cards unlock out of order, so
/// the grid shows gaps — 01, 04, 21 — and the number is what tells a learner
/// *which* card this is rather than how many tiles precede it.
/// It is 1-based, as the design prints it.
typedef PlacedCard = ({CardWithCollection item, int place, int total});

/// `04 / 37` — the design's own padding and separator.
///
/// Here rather than in the widget because it is arithmetic over the set, like
/// everything else in this file, and it can be checked without pumping one.
String formatCardPlace(AppLocalizations strings, PlacedCard placed) =>
    strings.cardPlaceInSet(
      placed.place.toString().padLeft(2, '0'),
      placed.total,
    );

/// The cards the grid draws, in authored order.
///
/// Every collected card, plus the first uncollected one as a teaser, which
/// keeps its authored position rather than being appended — so a teaser can
/// sit between two earned cards. A complete collection has no teaser.
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
/// Counts the teaser the grid is showing, as the design's `total - earned`
/// does: that tile is one of the three the footer names. Subtracting it would
/// count only the cards they cannot see.
int unearnedRemainder(List<CardWithCollection> all) =>
    all.where((item) => !item.isCollected).length;

/// How many cards the learner has earned.
int earnedCount(List<CardWithCollection> all) =>
    all.where((item) => item.isCollected).length;
