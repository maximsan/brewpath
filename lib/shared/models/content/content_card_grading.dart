import 'package:brew_path/shared/models/content/content_card.dart';

/// Whether [card] counts toward mastery.
///
/// A single exhaustive switch, with no registry, builder map or factory
/// indirection behind it: the sealed union makes an unhandled kind a compile
/// error, and that guarantee is worth more than the indirection would save.
/// Adding a variant to [ContentCard] breaks this switch until the new kind is
/// classified, which is the point.
///
/// This is deliberately a second statement of what [Gradable] already marks.
/// The two are cross-checked in `content_card_test.dart`, so a variant that
/// gains a kind here but loses the marker — the shape the wrong-denominator bug
/// takes — fails a test rather than shipping.
bool isGraded(ContentCard card) => switch (card) {
  PredictCard() || ConceptCard() || VisualCard() || PracticalCard() => false,
  McqCard() ||
  MultiCard() ||
  RecallCard() ||
  DecisionCard() ||
  MatchCard() ||
  SequenceCard() ||
  SliderCard() ||
  TastefixCard() ||
  BagpickCard() ||
  FlavorCard() ||
  QuizCard() => true,
};

/// The graded cards among [cards] — the denominator a mastery score divides by.
///
/// Returns `List<Gradable>` rather than `List<ContentCard>` so that scoring
/// cannot be handed an ungraded card at all. See [Gradable].
List<Gradable> gradedCards(Iterable<ContentCard> cards) =>
    cards.whereType<Gradable>().toList();
