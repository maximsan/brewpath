import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSavedKey', () {
    test('reads each of the three saveable prefixes', () {
      expect(parseSavedKey('l:m1l1'), (kind: SavedKind.lesson, id: 'm1l1'));
      expect(parseSavedKey('t:arabica'), (kind: SavedKind.term, id: 'arabica'));
      expect(parseSavedKey('g:roast'), (kind: SavedKind.guide, id: 'roast'));
    });

    test('rejects a prefix that is not saveable', () {
      // `c:` was never a key. Card favourites are not a design feature, so
      // this is not an exemption — there is nothing to exempt.
      expect(parseSavedKey('c:c1'), isNull);
      expect(parseSavedKey('x:whatever'), isNull);
    });

    test('rejects malformed keys rather than guessing', () {
      expect(parseSavedKey(''), isNull);
      expect(parseSavedKey('lm1l1'), isNull);
      expect(parseSavedKey('l:'), isNull);
      expect(parseSavedKey(':m1l1'), isNull);
      expect(parseSavedKey('ll:m1l1'), isNull);
    });

    test('keeps a colon inside the id, which only the first one delimits', () {
      expect(parseSavedKey('t:a:b'), (kind: SavedKind.term, id: 'a:b'));
    });
  });

  group('formatSavedKey', () {
    test('round-trips every kind', () {
      for (final kind in SavedKind.values) {
        final key = formatSavedKey(kind, 'some-id');
        expect(parseSavedKey(key), (kind: kind, id: 'some-id'));
      }
    });
  });

  group('isSavedKey', () {
    test('is true for the three saveable prefixes and false otherwise', () {
      expect(isSavedKey('l:m1l1'), isTrue);
      expect(isSavedKey('t:arabica'), isTrue);
      expect(isSavedKey('g:roast'), isTrue);
      expect(isSavedKey('c:c1'), isFalse);
      expect(isSavedKey('nonsense'), isFalse);
    });
  });

  group('toggleSavedKey', () {
    test('adds a key that is not there', () {
      expect(toggleSavedKey({'t:arabica'}, 'l:m1l1'), {
        't:arabica',
        'l:m1l1',
      });
    });

    test('removes a key that is', () {
      expect(toggleSavedKey({'t:arabica', 'l:m1l1'}, 't:arabica'), {'l:m1l1'});
    });

    test('saving twice is one entry, not two', () {
      final once = toggleSavedKey(const {}, 't:arabica');
      expect(toggleSavedKey(toggleSavedKey(once, 't:arabica'), 't:arabica'), {
        't:arabica',
      });
    });

    test('does not mutate the set it was handed', () {
      final original = {'t:arabica'};
      toggleSavedKey(original, 'l:m1l1');
      expect(original, {'t:arabica'});
    });
  });

  group('savedKeysOfKind', () {
    test('keeps only the requested kind, and drops unparseable keys', () {
      const stored = {'t:arabica', 't:bloom', 'l:m1l1', 'c:c1', 'rubbish'};
      expect(savedKeysOfKind(stored, SavedKind.term), {'arabica', 'bloom'});
      expect(savedKeysOfKind(stored, SavedKind.lesson), {'m1l1'});
      expect(savedKeysOfKind(stored, SavedKind.guide), isEmpty);
    });
  });
}
