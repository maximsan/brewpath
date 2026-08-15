import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seededOrder', () {
    test('is a permutation — every index appears exactly once', () {
      for (var length = 0; length < 12; length++) {
        final order = seededOrder(length, 12345);
        expect(order, hasLength(length));
        expect(order.toSet(), List<int>.generate(length, (i) => i).toSet());
      }
    });

    test('the same seed always gives the same order', () {
      expect(seededOrder(6, 99), seededOrder(6, 99));
    });

    test('different seeds give different orders', () {
      // Not a guarantee for any single pair — over a run of seeds, an
      // implementation that ignored its seed would show up as one repeated
      // order, which is the failure worth catching.
      final orders = {
        for (var seed = 0; seed < 50; seed++) seededOrder(5, seed).join(','),
      };
      expect(orders.length, greaterThan(1));
    });

    test('a one-item list is left alone', () {
      expect(seededOrder(1, 7), [0]);
    });
  });

  group('cardSeed', () {
    test('two cards in one attempt do not share a seed', () {
      final seeds = {
        for (var index = 0; index < 8; index++)
          cardSeed(nonce: 4242, cardIndex: index),
      };
      expect(seeds, hasLength(8));
    });

    test('one card across two attempts does not share a seed', () {
      expect(
        cardSeed(nonce: 1, cardIndex: 3),
        isNot(cardSeed(nonce: 2, cardIndex: 3)),
      );
    });

    test('the same attempt and card reproduce the same seed', () {
      expect(
        cardSeed(nonce: 77, cardIndex: 2),
        cardSeed(nonce: 77, cardIndex: 2),
      );
    });
  });

  // The behaviour a learner would notice: replaying a lesson does not put the
  // answers back where they were, so a remembered position is worth nothing.
  test('replaying a lesson reorders a card, given a fresh nonce', () {
    const cardIndex = 3;
    const choices = ['a', 'b', 'c', 'd'];

    final firstRun = shuffledBySeed(
      choices,
      cardSeed(nonce: 1000, cardIndex: cardIndex),
    );
    final laterRuns = {
      for (var nonce = 1001; nonce < 1020; nonce++)
        shuffledBySeed(
          choices,
          cardSeed(nonce: nonce, cardIndex: cardIndex),
        ).join(),
    };

    expect(laterRuns, contains(isNot(firstRun.join())));
  });

  test('shuffledBySeed keeps every item', () {
    final shuffled = shuffledBySeed(['a', 'b', 'c', 'd'], 31);
    expect(shuffled.toSet(), {'a', 'b', 'c', 'd'});
  });
}
