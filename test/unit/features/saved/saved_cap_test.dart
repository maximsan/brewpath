import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:flutter_test/flutter_test.dart';

/// Five keys — a full free shelf.
const _full = {'t:a', 't:b', 't:c', 't:d', 't:e'};

void main() {
  test('the free shelf holds five', () {
    expect(savedFreeMax, 5);
  });

  group('below the cap', () {
    test('a save takes', () {
      expect(
        attemptSave(
          key: 't:new',
          keys: const {'t:a'},
          visible: const {'t:a'}.length,
          isPlus: false,
        ),
        const SaveOutcome.saved({'t:a', 't:new'}),
      );
    });

    test('the fifth save still takes', () {
      const four = {'t:a', 't:b', 't:c', 't:d'};
      expect(
        attemptSave(
          key: 't:e',
          keys: four,
          visible: four.length,
          isPlus: false,
        ),
        const SaveOutcome.saved(_full),
      );
    });
  });

  group('at the cap', () {
    test('a sixth save raises the gate and changes nothing', () {
      final outcome = attemptSave(
        key: 't:f',
        keys: _full,
        visible: _full.length,
        isPlus: false,
      );

      expect(outcome, const SaveOutcome.gateRaised());
    });

    test('removal is still allowed', () {
      // The rule most worth protecting: a full shelf stays curatable.
      expect(
        attemptSave(
          key: 't:a',
          keys: _full,
          visible: _full.length,
          isPlus: false,
        ),
        const SaveOutcome.removed({'t:b', 't:c', 't:d', 't:e'}),
      );
    });

    test('re-saving after a removal takes', () {
      final after = attemptSave(
        key: 't:a',
        keys: _full,
        visible: _full.length,
        isPlus: false,
      );
      final next = switch (after) {
        SaveRemoved(:final keys) => keys,
        _ => fail('an unsave at the cap must be allowed'),
      };

      expect(
        attemptSave(
          key: 't:z',
          keys: next,
          visible: next.length,
          isPlus: false,
        ),
        SaveOutcome.saved({...next, 't:z'}),
      );
    });
  });

  group('with Plus', () {
    test('a sixth save takes', () {
      expect(
        attemptSave(
          key: 't:f',
          keys: _full,
          visible: _full.length,
          isPlus: true,
        ),
        const SaveOutcome.saved({..._full, 't:f'}),
      );
    });

    test('and so does a fiftieth', () {
      final many = {for (var i = 0; i < 50; i++) 't:$i'};
      expect(
        attemptSave(
          key: 't:more',
          keys: many,
          visible: many.length,
          isPlus: true,
        ),
        SaveOutcome.saved({...many, 't:more'}),
      );
    });
  });

  test('saving something already saved removes it rather than duplicating', () {
    expect(
      attemptSave(
        key: 't:a',
        keys: const {'t:a'},
        visible: const {'t:a'}.length,
        isPlus: false,
      ),
      const SaveOutcome.removed({}),
    );
  });

  test('the cap counts all three kinds together', () {
    // One shelf, not three: the limit is on what the learner kept, whatever
    // kind it was.
    const mixed = {'t:a', 't:b', 'l:m1l1', 'l:m1l2', 'g:roast'};
    expect(
      attemptSave(
        key: 't:c',
        keys: mixed,
        visible: mixed.length,
        isPlus: false,
      ),
      const SaveOutcome.gateRaised(),
    );
  });

  test('the cap judges what the shelf shows, not what is stored', () {
    // Five saveable keys stored, but two guides are not earned on this
    // device, so the shelf draws three rows. The learner is told "3 of 5" —
    // and must not then be refused as though they were at five.
    const stored = {'t:a', 't:b', 't:c', 'g:roast', 'g:grind'};
    const visible = 3;

    expect(savedCountLine(count: visible, isPlus: false), '3 of 5 saved');
    expect(
      attemptSave(key: 't:d', keys: stored, visible: visible, isPlus: false),
      isA<SaveSaved>(),
      reason: 'the number shown and the number enforced must be one number',
    );
  });

  test('an unsaveable stored key cannot fill the shelf', () {
    // `c:` was never a key, so it never becomes a row and never counts.
    const stored = {'t:a', 'c:c1', 'rubbish'};

    expect(
      attemptSave(key: 't:b', keys: stored, visible: 1, isPlus: false),
      isA<SaveSaved>(),
    );
  });

  group('savedCountLine', () {
    test('a free learner reads their shelf against the cap', () {
      expect(savedCountLine(count: 3, isPlus: false), '3 of 5 saved');
      expect(savedCountLine(count: 0, isPlus: false), '0 of 5 saved');
      expect(savedCountLine(count: 5, isPlus: false), '5 of 5 saved');
    });

    test('a Plus learner is not shown a limit that does not apply', () {
      expect(savedCountLine(count: 3, isPlus: true), '3 items to revisit');
      expect(savedCountLine(count: 1, isPlus: true), '1 item to revisit');
    });

    test('a shelf filled on Plus still reads honestly without it', () {
      // The cap refuses new saves; it never takes anything away.
      expect(
        savedCountLine(count: 9, isPlus: false),
        '9 saved · free limit 5',
      );
    });
  });

  group('savedShelfIsFull', () {
    test('is true for a free learner at the cap and beyond', () {
      expect(savedShelfIsFull(count: 5, isPlus: false), isTrue);
      expect(savedShelfIsFull(count: 9, isPlus: false), isTrue);
    });

    test('is false below it', () {
      expect(savedShelfIsFull(count: 4, isPlus: false), isFalse);
    });

    test('is never true with Plus', () {
      expect(savedShelfIsFull(count: 99, isPlus: true), isFalse);
    });
  });
}
