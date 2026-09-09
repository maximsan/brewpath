/// The derivations a concept card's layout reads, pure so the paragraph rule
/// can be checked without pumping a widget.
library;

import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';

/// The paragraph the verdict block speaks: the design hands it
/// `paragraphs.slice(1, 2)`, so the second one, where the card has one.
const int supportParagraph = 1;

/// The blanks in [card]'s sentence, keyed by their position in it.
Map<int, FillBlank> blanksIn(ConceptCard card) => {
  for (var index = 0; index < card.fill.length; index++)
    if (card.fill[index] case final FillBlank blank) index: blank,
};

/// Whether the verdict block will speak a paragraph on this card at all.
///
/// A card with no blank is never checked, so its block never appears — and a
/// paragraph reserved for a block that cannot show would simply be lost.
bool speaksSupport(ConceptCard card) =>
    blanksIn(card).isNotEmpty && card.paragraphs.length > supportParagraph;

/// The paragraph the verdict block takes, or null when it takes none.
String? supportIn(ConceptCard card) =>
    speaksSupport(card) ? card.paragraphs[supportParagraph] : null;

/// The paragraphs that stay as prose — every one the block does not take.
List<String> proseIn(ConceptCard card) => [
  for (final (index, paragraph) in card.paragraphs.indexed)
    if (!(speaksSupport(card) && index == supportParagraph)) paragraph,
];
