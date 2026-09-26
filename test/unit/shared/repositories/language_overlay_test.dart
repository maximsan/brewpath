// How a language folder lands on top of the English master: ADR-0008 for the
// per-entry fallback, ADR-0027 for a stale entry staying put.
import 'package:brew_path/shared/repositories/content_assembly.dart';
import 'package:brew_path/shared/repositories/language_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

List<Map<String, dynamic>> _master() => [
  {
    'id': 'arabica',
    'term': 'Arabica',
    'short': 'The sweeter species.',
    'pron': 'uh-RAB-ih-kuh',
  },
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

  group('a respelling belongs to the language that wrote it', () {
    test('a folder that omits it leaves the entry with none', () {
      final records = _overlaid([
        {'id': 'arabica', 'term': 'Arabika'},
      ]);

      expect(
        records.first['pron'],
        isNull,
        reason:
            'an English respelling tells an English speaker how to say an '
            'English word, so it is no use to a reader of another language',
      );
    });

    test('a folder that writes its own keeps it', () {
      final records = _overlaid([
        {'id': 'arabica', 'term': 'Arabika', 'pron': 'a-RA-bi-ka'},
      ]);

      expect(records.first['pron'], 'a-RA-bi-ka');
    });

    test('a folder that writes it as nothing still leaves none', () {
      final records = _overlaid([
        {'id': 'arabica', 'term': 'Arabika', 'pron': null},
      ]);

      expect(records.first['pron'], isNull);
    });

    test('an entry the folder never reached keeps the English one', () {
      final records = _overlaid([
        {'id': 'robusta', 'term': 'Rabusta'},
      ]);

      expect(
        records.first['pron'],
        'uh-RAB-ih-kuh',
        reason:
            'the whole entry is still in English there, so the respelling '
            'still says how to say the word the reader is being shown',
      );
    });

    test('the English bank keeps every respelling it carries', () {
      expect(_overlaid([]).first['pron'], 'uh-RAB-ih-kuh');
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
      // ADR-0027: staleness is a fact about the repository. The loader cannot
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
      // ADR-0026 ships a language on its draft; review follows afterwards, so
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

  group('the fallback reaches the text inside an entry', () {
    List<Map<String, dynamic>> overlaidHelp(Map<String, dynamic> translated) =>
        overlayTranslations(
          master: [
            {
              'id': 'mcq',
              'title': 'Multiple choice',
              'steps': [
                'Read the question',
                'Tap the answer you think is right',
                'See the explanation, then continue',
              ],
              'reward': {'kind': 'card', 'caption': 'A card you keep'},
            },
          ],
          translated: [translated],
          assetPath: 'assets/content/l10n/pl/card_kind_help.json',
        );

    test('a step the folder translates replaces only that step', () {
      final records = overlaidHelp({
        'id': 'mcq',
        'steps': [
          'Przeczytaj pytanie',
          'Tap the answer you think is right',
          'See the explanation, then continue',
        ],
      });

      expect((records.first['steps']! as List).first, 'Przeczytaj pytanie');
      expect((records.first['steps']! as List).length, 3);
    });

    test('a field inside a group the folder omits stays English', () {
      final records = overlaidHelp({
        'id': 'mcq',
        'reward': {'caption': 'Karta, którą zachowasz'},
      });

      final reward = records.first['reward']! as Map<String, dynamic>;
      expect(reward['caption'], 'Karta, którą zachowasz');
      expect(reward['kind'], 'card');
    });

    test('a list with fewer items than the master is refused', () {
      expect(
        () => overlaidHelp({
          'id': 'mcq',
          'steps': ['Przeczytaj pytanie'],
        }),
        throwsA(
          isA<ContentFormatException>().having(
            (it) => it.message,
            'message',
            allOf(contains('lists 1'), contains('3')),
          ),
        ),
      );
    });

    test('a term carries more aliases than English, and they all land', () {
      final records = overlayTranslations(
        master: [
          {
            'id': 'coffee',
            'term': 'Coffee',
            'aliases': ['coffee', 'beans'],
          },
        ],
        translated: [
          {
            'id': 'coffee',
            'term': 'Kawa',
            'aliases': ['kawa', 'kawy', 'kawie', 'kawę'],
          },
        ],
        assetPath: 'assets/content/l10n/pl/dictionary_terms.json',
      );

      expect(records.first['aliases'], [
        'kawa',
        'kawy',
        'kawie',
        'kawę',
      ]);
    });

    test('a folder that writes none leaves the term with none', () {
      final records = overlayTranslations(
        master: [
          {
            'id': 'coffee',
            'term': 'Coffee',
            'aliases': ['coffee', 'beans'],
          },
        ],
        translated: [
          {'id': 'coffee', 'term': 'Kawa'},
        ],
        assetPath: 'assets/content/l10n/pl/dictionary_terms.json',
      );

      expect(
        records.first['aliases'],
        isNull,
        reason:
            'English forms are the wrong keys in a Polish bank: they would '
            'decide which terms a lesson mentions, and so the free pool',
      );
    });

    test('a term with fewer aliases than English keeps only its own', () {
      final records = overlayTranslations(
        master: [
          {
            'id': 'coffee',
            'term': 'Coffee',
            'aliases': ['coffee', 'beans', 'brew'],
          },
        ],
        translated: [
          {
            'id': 'coffee',
            'aliases': ['kawa'],
          },
        ],
        assetPath: 'assets/content/l10n/pl/dictionary_terms.json',
      );

      expect(records.first['aliases'], ['kawa']);
    });

    test('aliases given as one word, where the master lists them, are '
        'refused', () {
      expect(
        () => overlayTranslations(
          master: [
            {
              'id': 'coffee',
              'aliases': ['coffee', 'beans'],
            },
          ],
          translated: [
            {'id': 'coffee', 'aliases': 'kawa'},
          ],
          assetPath: 'assets/content/l10n/pl/dictionary_terms.json',
        ),
        throwsA(
          isA<ContentFormatException>().having(
            (it) => it.message,
            'message',
            contains('a list'),
          ),
        ),
      );
    });

    test('a field the master has no slot for is refused', () {
      expect(
        () => overlaidHelp({'id': 'mcq', 'titel': 'Wielokrotny wybór'}),
        throwsA(
          isA<ContentFormatException>().having(
            (it) => it.message,
            'message',
            contains('titel'),
          ),
        ),
      );
    });

    test('text where the master keeps a list is refused', () {
      expect(
        () => overlaidHelp({'id': 'mcq', 'steps': 'Przeczytaj pytanie'}),
        throwsA(isA<ContentFormatException>()),
      );
    });

    test('a mark inside a group never reaches the record', () {
      final records = overlaidHelp({
        'id': 'mcq',
        'reward': {
          'caption': 'Karta, którą zachowasz',
          translatedFromField: {'caption': 'abc123'},
        },
      });

      final reward = records.first['reward']! as Map<String, dynamic>;
      expect(reward.containsKey(translatedFromField), isFalse);
    });
  });

  group('a folder cannot say two things about one entry', () {
    test('the same id translated twice is refused', () {
      expect(
        () => _overlaid([
          {'id': 'arabica', 'term': 'Pierwsza'},
          {'id': 'arabica', 'term': 'Druga'},
        ]),
        throwsA(
          isA<ContentFormatException>().having(
            (it) => it.message,
            'message',
            contains('arabica'),
          ),
        ),
      );
    });
  });
}
