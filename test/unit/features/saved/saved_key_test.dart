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
}
