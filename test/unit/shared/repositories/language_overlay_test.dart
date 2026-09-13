// How a language folder lands on top of the English master: ADR-0008 for the
// per-entry fallback, ADR-0026 for a stale entry staying put.
import 'package:brew_path/shared/repositories/content_assembly.dart';
import 'package:brew_path/shared/repositories/language_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

List<Map<String, dynamic>> _master() => [
  {'id': 'arabica', 'term': 'Arabica', 'short': 'The sweeter species.'},
  {'id': 'robusta', 'term': 'Robusta', 'short': 'The hardier species.'},
];

List<Map<String, dynamic>> _overlaid(List<Map<String, dynamic>> translated) =>
    overlayTranslations(
      master: _master(),
      translated: translated,
      assetPath: 'assets/content/l10n/pl/dictionary_terms.json',
    );

void main() {
  group('a translated entry wins', () {
    test('its fields replace the English ones', () {
      final records = _overlaid([
        {'id': 'arabica', 'term': 'Arabika', 'short': 'Słodszy gatunek.'},
      ]);

      expect(records.first['term'], 'Arabika');
      expect(records.first['short'], 'Słodszy gatunek.');
    });

    test('a field the translation omits stays English', () {
      final records = _overlaid([
        {'id': 'arabica', 'term': 'Arabika'},
      ]);

      expect(records.first['term'], 'Arabika');
      expect(records.first['short'], 'The sweeter species.');
    });

    test('an entry with no translation stays English', () {
      final records = _overlaid([
        {'id': 'arabica', 'term': 'Arabika'},
      ]);

      expect(records.last['term'], 'Robusta');
    });
  });

  group('the master fixes the shape', () {
    test('the order and the count are the English bank’s', () {
      final records = _overlaid([
        {'id': 'robusta', 'term': 'Robusta PL'},
      ]);

      expect(records.map((record) => record['id']), ['arabica', 'robusta']);
    });

    test('a translation of an entry the master dropped is refused', () {
      expect(
        () => _overlaid([
          {'id': 'liberica', 'term': 'Liberika'},
        ]),
        throwsA(isA<ContentFormatException>()),
      );
    });

    test('no translation at all leaves the master untouched', () {
      expect(_overlaid([]), _master());
    });
  });

  group('bookkeeping never reaches the device', () {
    test('both of the tool’s marks are stripped from the record', () {
      final records = _overlaid([
        {
          'id': 'arabica',
          'term': 'Arabika',
          translatedFromField: {'term': 'abc123'},
          nativeReviewedField: {'term': true},
        },
      ]);

      for (final field in bookkeepingFields) {
        expect(records.first.containsKey(field), isFalse, reason: field);
      }
      expect(records.first['term'], 'Arabika');
    });

    test('a stale entry is shown, not skipped', () {
      // ADR-0026: staleness is a fact about the repository. The loader cannot
      // tell a stale entry from a current one, and must not try.
      final records = _overlaid([
        {
          'id': 'arabica',
          'term': 'Arabika',
          translatedFromField: {'term': 'a-digest-nobody-checks'},
        },
      ]);

      expect(records.first['term'], 'Arabika');
    });

    test('an unreviewed translation is shown like any other', () {
      // ADR-0025 ships a language on its draft; review follows afterwards, so
      // "nobody has read this" is not a reason to withhold it.
      final records = _overlaid([
        {
          'id': 'arabica',
          'term': 'Arabika',
          nativeReviewedField: <String, bool>{},
        },
      ]);

      expect(records.first['term'], 'Arabika');
    });
  });
}
