import 'package:brew_path/features/lessons/domain/concept_card_parts.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter_test/flutter_test.dart';

ConceptCard _card({
  required List<String> paragraphs,
  bool withBlank = true,
}) =>
    ContentCard.concept(
          label: 'CONCEPT',
          title: 'T',
          fill: [
            const ConceptFillPart.literal('A coffee '),
            if (withBlank)
              const ConceptFillPart.blank(
                answer: 'seed',
                options: ['seed', 'skin'],
                label: 'What it is',
              ),
            const ConceptFillPart.literal(' of a fruit.'),
          ],
          paragraphs: paragraphs,
          meta: const [],
        )
        as ConceptCard;

// The design hands the verdict block `paragraphs.slice(1, 2)`. Everything else
// stays prose — and on a card that is never checked, so does that one.
void main() {
  test('the blanks are keyed by where they sit in the sentence', () {
    expect(blanksIn(_card(paragraphs: ['One.'])).keys, [1]);
    expect(blanksIn(_card(paragraphs: ['One.'], withBlank: false)), isEmpty);
  });

  test('the block takes the second paragraph, and prose keeps the rest', () {
    final card = _card(paragraphs: ['One.', 'Two.', 'Three.']);

    expect(supportIn(card), 'Two.');
    expect(proseIn(card), ['One.', 'Three.']);
  });

  test('a card with one paragraph gives the block nothing', () {
    final card = _card(paragraphs: ['Only.']);

    expect(supportIn(card), isNull);
    expect(proseIn(card), ['Only.']);
  });

  test('a card with no blank keeps every paragraph as prose', () {
    // It is never checked, so the block never appears — a paragraph held back
    // for it would simply be lost off the screen.
    final card = _card(paragraphs: ['One.', 'Two.'], withBlank: false);

    expect(supportIn(card), isNull);
    expect(
      proseIn(card),
      ['One.', 'Two.'],
      reason: 'nothing is checked here, so nothing may be held back',
    );
  });
}
