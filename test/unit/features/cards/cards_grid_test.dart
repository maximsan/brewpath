import 'package:brew_path/features/cards/domain/cards_grid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

List<String> _ids(List<PlacedCard> items) => [
  for (final placed in items) placed.item.card.id,
];

/// The catalogue place each drawn tile carries, so a gap in the grid can be
/// told apart from a renumbering of it.
List<int> _places(List<PlacedCard> items) => [
  for (final placed in items) placed.place,
];

void main() {
  group('cardsGridItems', () {
    test('shows every earned card and exactly one locked teaser', () {
      final grid = cardsGridItems([
        testCardWithCollection('a', collected: true),
        testCardWithCollection('b', collected: false),
        testCardWithCollection('c', collected: false),
        testCardWithCollection('d', collected: false),
      ]);

      expect(_ids(grid), ['a', 'b']);
    });

    // The teaser keeps its authored place rather than being appended, because
    // the design maps the whole set in order and drops the later locked ones.
    test('the teaser stays where it was authored, between earned cards', () {
      final grid = cardsGridItems([
        testCardWithCollection('a', collected: true),
        testCardWithCollection('b', collected: false),
        testCardWithCollection('c', collected: true),
        testCardWithCollection('d', collected: false),
      ]);

      expect(_ids(grid), ['a', 'b', 'c']);
    });

    test('a fresh collection is one teaser, not a wall of blanks', () {
      final grid = cardsGridItems([
        testCardWithCollection('a', collected: false),
        testCardWithCollection('b', collected: false),
        testCardWithCollection('c', collected: false),
      ]);

      expect(_ids(grid), ['a']);
    });

    test('a complete collection has no teaser', () {
      final grid = cardsGridItems([
        testCardWithCollection('a', collected: true),
        testCardWithCollection('b', collected: true),
      ]);

      expect(_ids(grid), ['a', 'b']);
    });

    // The number is the card's place in the *catalogue*, not in the grid.
    // Cards unlock out of order, so a learner reading `03 / 37` on the third
    // tile would be told a lie the moment one card is skipped.
    test('a tile keeps its catalogue place, not its place in the grid', () {
      final grid = cardsGridItems([
        testCardWithCollection('a', collected: true),
        testCardWithCollection('b', collected: false),
        testCardWithCollection('c', collected: true),
        testCardWithCollection('d', collected: false),
      ]);

      expect(_ids(grid), ['a', 'b', 'c']);
      expect(_places(grid), [1, 2, 3]);
    });

    test('a skipped card leaves a gap in the numbering', () {
      final grid = cardsGridItems([
        testCardWithCollection('a', collected: false),
        testCardWithCollection('b', collected: true),
        testCardWithCollection('c', collected: true),
      ]);

      // The teaser is 'a' at 1; 'b' and 'c' keep 2 and 3 behind it.
      expect(_places(grid), [1, 2, 3]);
    });

    test('the number reads as a place in the whole set', () {
      final grid = cardsGridItems([
        testCardWithCollection('a', collected: true),
        testCardWithCollection('b', collected: true),
        testCardWithCollection('c', collected: false),
      ]);

      // Zero-padded to two, against the catalogue's size — not the grid's.
      expect(formatCardPlace(grid.first), '01 / 3');
      expect(formatCardPlace(grid.last), '03 / 3');
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
        testCardWithCollection('a', collected: true),
        testCardWithCollection('b', collected: false),
        testCardWithCollection('c', collected: false),
        testCardWithCollection('d', collected: false),
      ];

      expect(unearnedRemainder(all), 3);
      expect(
        cardsGridItems(all).where((placed) => !placed.item.isCollected),
        hasLength(1),
        reason: 'one of the three counted is the tile on screen',
      );
    });

    test('a complete collection has nothing left', () {
      expect(
        unearnedRemainder([testCardWithCollection('a', collected: true)]),
        0,
      );
    });

    test('an empty set has nothing left either', () {
      expect(unearnedRemainder(const []), 0);
    });
  });

  group('earnedCount', () {
    test('counts what the learner holds', () {
      expect(
        earnedCount([
          testCardWithCollection('a', collected: true),
          testCardWithCollection('b', collected: false),
          testCardWithCollection('c', collected: true),
        ]),
        2,
      );
    });

    test('earned and unearned always account for the whole set', () {
      final all = [
        testCardWithCollection('a', collected: true),
        testCardWithCollection('b', collected: false),
        testCardWithCollection('c', collected: false),
      ];

      expect(earnedCount(all) + unearnedRemainder(all), all.length);
    });
  });
}
