import 'package:brew_path/features/lessons/presentation/cards/sequence_order.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:flutter_test/flutter_test.dart';

/// A shipped round, authored — as every sequence round is — in its own answer.
const _beanToCup = [
  SequenceItem(label: 'Pick the cherry', order: 1),
  SequenceItem(label: 'Process and dry', order: 2),
  SequenceItem(label: 'Roast', order: 3),
  SequenceItem(label: 'Grind', order: 4),
  SequenceItem(label: 'Brew', order: 5),
];

List<String> _labels(List<SequenceItem> items) => [
  for (final item in items) item.label,
];

void main() {
  group('sequenceDisplayOrder', () {
    test('keeps every step, exactly once', () {
      for (var seed = 1; seed <= 40; seed++) {
        final shown = sequenceDisplayOrder(_beanToCup, seed);

        expect(shown, hasLength(_beanToCup.length));
        expect(_labels(shown)..sort(), _labels(_beanToCup)..sort());
      }
    });

    // The rule this function exists for. Every other card's shuffle is
    // cosmetic; this one can hand the learner the answer, and a round that
    // opens solved is won by tapping down the list without reading it.
    test('never opens the card already solved', () {
      for (var seed = 1; seed <= 200; seed++) {
        expect(
          sequenceIsSolution(sequenceDisplayOrder(_beanToCup, seed)),
          isFalse,
          reason: 'seed $seed opened the round in its own answer',
        );
      }
    });

    test('holds for the shortest round a shuffle can protect', () {
      const two = [
        SequenceItem(label: 'Bloom', order: 1),
        SequenceItem(label: 'Pour', order: 2),
      ];

      for (var seed = 1; seed <= 200; seed++) {
        expect(sequenceIsSolution(sequenceDisplayOrder(two, seed)), isFalse);
      }
    });

    test('is reproducible from the seed alone', () {
      expect(
        _labels(sequenceDisplayOrder(_beanToCup, 7)),
        _labels(sequenceDisplayOrder(_beanToCup, 7)),
      );
    });

    test('a fresh run moves the steps', () {
      final orders = {
        for (var seed = 1; seed <= 20; seed++)
          _labels(sequenceDisplayOrder(_beanToCup, seed)).join('|'),
      };

      expect(orders.length, greaterThan(1));
    });

    // A one-step round has no order to get wrong, so there is nothing to
    // protect and nothing to shuffle.
    test('a round too short to order is left alone', () {
      const single = [SequenceItem(label: 'Brew', order: 1)];

      expect(sequenceDisplayOrder(single, 3), single);
      expect(sequenceDisplayOrder(const [], 3), isEmpty);
    });
  });

  group('sequenceIsCorrect', () {
    test('the authored order is the answer', () {
      expect(
        sequenceIsCorrect(tapped: _beanToCup, total: _beanToCup.length),
        isTrue,
      );
    });

    test('any other order is not', () {
      final swapped = [_beanToCup[1], _beanToCup[0], ..._beanToCup.skip(2)];

      expect(
        sequenceIsCorrect(tapped: swapped, total: swapped.length),
        isFalse,
      );
    });

    // A run is the whole sequence, not a prefix of it — otherwise a learner
    // who taps the first two steps right has answered the card.
    test('a partial run is never correct, however right its start', () {
      expect(
        sequenceIsCorrect(
          tapped: _beanToCup.take(2).toList(),
          total: _beanToCup.length,
        ),
        isFalse,
      );
    });

    test('an empty round has nothing to have got right', () {
      expect(sequenceIsCorrect(tapped: const [], total: 0), isFalse);
    });
  });

  group('sequencePlacedRight', () {
    test('an authored order counts from one, a position from zero', () {
      expect(sequencePlacedRight(item: _beanToCup[0], position: 0), isTrue);
      expect(sequencePlacedRight(item: _beanToCup[0], position: 1), isFalse);
      expect(sequencePlacedRight(item: _beanToCup[4], position: 4), isTrue);
    });
  });

  group('sequenceSolution', () {
    test('sorts the steps back into their authored order', () {
      final shuffled = sequenceDisplayOrder(_beanToCup, 11);

      expect(_labels(sequenceSolution(shuffled)), _labels(_beanToCup));
    });

    test('leaves the list it was given alone', () {
      final shown = sequenceDisplayOrder(_beanToCup, 11);
      final before = _labels(shown);

      sequenceSolution(shown);

      expect(_labels(shown), before);
    });
  });
}
