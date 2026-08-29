import 'package:brew_path/features/cards/domain/cards_grid.dart';
import 'package:brew_path/features/cards/domain/cards_providers.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

CardWithCollection _card(String id, {required bool collected}) =>
    CardWithCollection(
      card: CoffeeCardModel(
        id: id,
        title: id,
        description: 'A card called $id.',
        fact: 'A fact about $id.',
        moduleTag: 'BEANS',
        iconName: 'beans',
      ),
      isCollected: collected,
    );

List<String> _ids(List<CardWithCollection> items) => [
  for (final item in items) item.card.id,
];

void main() {
  group('cardsGridItems', () {
    test('shows every earned card and exactly one locked teaser', () {
      final grid = cardsGridItems([
        _card('a', collected: true),
        _card('b', collected: false),
        _card('c', collected: false),
        _card('d', collected: false),
      ]);

      expect(_ids(grid), ['a', 'b']);
    });

    // The teaser keeps its authored place rather than being appended, because
    // the design maps the whole set in order and drops the later locked ones.
    test('the teaser stays where it was authored, between earned cards', () {
      final grid = cardsGridItems([
        _card('a', collected: true),
        _card('b', collected: false),
        _card('c', collected: true),
        _card('d', collected: false),
      ]);

      expect(_ids(grid), ['a', 'b', 'c']);
    });

    test('a fresh collection is one teaser, not a wall of blanks', () {
      final grid = cardsGridItems([
        _card('a', collected: false),
        _card('b', collected: false),
        _card('c', collected: false),
      ]);

      expect(_ids(grid), ['a']);
    });

    test('a complete collection has no teaser', () {
      final grid = cardsGridItems([
        _card('a', collected: true),
        _card('b', collected: true),
      ]);

      expect(_ids(grid), ['a', 'b']);
    });

    test('an empty set draws nothing', () {
      expect(cardsGridItems(const []), isEmpty);
    });
  });

  group('unearnedRemainder', () {
    // The one that reads as an off-by-one until it is checked against the
    // design: the teaser is on screen *and* in the count.
    test('counts the teaser the grid is showing', () {
      final all = [
        _card('a', collected: true),
        _card('b', collected: false),
        _card('c', collected: false),
        _card('d', collected: false),
      ];

      expect(unearnedRemainder(all), 3);
      expect(
        cardsGridItems(all).where((item) => !item.isCollected),
        hasLength(1),
        reason: 'one of the three counted is the tile on screen',
      );
    });

    test('a complete collection has nothing left', () {
      expect(unearnedRemainder([_card('a', collected: true)]), 0);
    });

    test('an empty set has nothing left either', () {
      expect(unearnedRemainder(const []), 0);
    });
  });

  group('earnedCount', () {
    test('counts what the learner holds', () {
      expect(
        earnedCount([
          _card('a', collected: true),
          _card('b', collected: false),
          _card('c', collected: true),
        ]),
        2,
      );
    });

    test('earned and unearned always account for the whole set', () {
      final all = [
        _card('a', collected: true),
        _card('b', collected: false),
        _card('c', collected: false),
      ];

      expect(earnedCount(all) + unearnedRemainder(all), all.length);
    });
  });
}
