import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The drafting tool's pure core, driven through `node` for the reason the
/// word-search test gives: the logic is the tool's, and re-implementing it in
/// Dart would guarantee the two drift.
const _module = 'tool/draft_language/folder';

Object? _call(String expression, Object? argument) {
  final script =
      '''
const folder = require('./$_module.js');
const argument = JSON.parse(process.argv[1]);
const value = ($expression)(folder, argument);
process.stdout.write(JSON.stringify(value === undefined ? null : value));
''';
  final result = Process.runSync('node', ['-e', script, jsonEncode(argument)]);
  expect(result.exitCode, 0, reason: result.stderr.toString());
  return jsonDecode(result.stdout.toString());
}

List<Map<String, dynamic>> _master() => [
  {
    'id': 'm1l1',
    'title': 'What coffee actually is',
    'cards': [
      {
        'kind': 'bagpick',
        'prompt': 'Pick the washed bean',
        'options': ['washed', 'natural'],
        'answer': 'washed',
      },
    ],
  },
];

Map<String, Object?> _polish() => {
  'm1l1|title': 'Czym naprawdę jest kawa',
  'm1l1|cards[0].prompt': 'Wybierz ziarno myte',
  'm1l1|cards[0].options[0]': 'myte',
  'm1l1|cards[0].options[1]': 'naturalne',
};

List<Object?> _plan(
  List<Map<String, dynamic>> master,
  List<Object?> existing,
) =>
    _call(
          '(f, a) => f.planBank({ bank: "lessons", master: a.master, folder: a.folder })',
          {'master': master, 'folder': existing},
        )!
        as List<Object?>;

List<Object?> _apply(
  List<Map<String, dynamic>> master,
  List<Object?> existing,
  Map<String, Object?> translations,
) =>
    _call(
          '(f, a) => f.applyBank({ bank: "lessons", master: a.master, '
          'folder: a.folder, translations: new Map(Object.entries(a.t)) })',
          {'master': master, 'folder': existing, 't': translations},
        )!
        as List<Object?>;

void main() {
  group('what a language still owes', () {
    test('an empty folder owes every piece of prose and nothing else', () {
      final keys = _plan(
        _master(),
        [],
      ).map((item) => (item! as Map<String, dynamic>)['key']).toList();

      expect(keys, [
        'title',
        'cards[0].prompt',
        'cards[0].options[0]',
        'cards[0].options[1]',
      ]);
    });

    test('a drafted folder owes nothing on a second run', () {
      final folder = _apply(_master(), [], _polish());

      expect(_plan(_master(), folder), isEmpty);
    });

    test('an English edit stales that field and leaves its neighbours', () {
      final folder = _apply(_master(), [], _polish());
      final edited = _master()..first['title'] = 'What coffee really is';

      final work = _plan(
        edited,
        folder,
      ).map((item) => item! as Map<String, dynamic>).toList();

      expect(work, hasLength(1));
      expect(work.single['key'], 'title');
      expect(work.single['state'], 'stale');
      expect(work.single['held'], 'Czym naprawdę jest kawa');
    });
  });

  group('what a draft writes', () {
    test('an answer follows the option it names into the language', () {
      final folder = _apply(_master(), [], _polish());
      final card =
          ((folder.single! as Map<String, dynamic>)['cards']! as List).single!
              as Map<String, dynamic>;

      expect(card['options'], ['myte', 'naturalne']);
      expect(card['answer'], 'myte');
    });

    test('a field whose English held still keeps its review mark', () {
      final reviewed = [
        {
          'id': 'm1l1',
          'title': 'Czym naprawdę jest kawa',
          'translatedFrom': {'title': _digest('What coffee actually is')},
          'nativeReviewed': {'title': true},
        },
      ];

      final folder = _apply(_master(), reviewed, const {});
      final entry = folder.single! as Map<String, dynamic>;

      expect(entry['title'], 'Czym naprawdę jest kawa');
      expect((entry['nativeReviewed']! as Map)['title'], isTrue);
    });

    test('a field drafted afresh is unread again', () {
      final reviewed = [
        {
          'id': 'm1l1',
          'title': 'Stare słowa',
          'translatedFrom': {'title': _digest('What coffee actually is')},
          'nativeReviewed': {'title': true},
        },
      ];

      final folder = _apply(_master(), reviewed, {'m1l1|title': 'Nowe słowa'});
      final entry = folder.single! as Map<String, dynamic>;

      expect(entry['title'], 'Nowe słowa');
      expect(entry['nativeReviewed'], isNot(contains('title')));
    });
  });

  group('what stops a language being complete', () {
    test('a folder missing a field names it', () {
      final missing =
          _call(
                '(f, a) => f.checkBank({ bank: "lessons", master: a.master, folder: a.folder })',
                {'master': _master(), 'folder': const <Object>[]},
              )!
              as List<Object?>;

      expect(missing, hasLength(4));
      expect(missing.first, contains('m1l1'));
    });

    test('an answer naming no option it is offered beside is caught', () {
      final folder = _apply(_master(), [], _polish());
      (((folder.single! as Map<String, dynamic>)['cards']! as List).single!
              as Map<String, dynamic>)['answer'] =
          'washed';

      final stranded =
          _call(
                '(f, a) => f.strandedAnswers({ bank: "lessons", master: a.master, folder: a.folder })',
                {'master': _master(), 'folder': folder},
              )!
              as List<Object?>;

      expect(stranded, hasLength(1));
      expect(stranded.single, contains('washed'));
    });
  });
}

String _digest(String english) {
  final result = Process.runSync('node', [
    '-e',
    "const {fingerprint} = require('./tool/draft_language/fingerprint.js');"
        'process.stdout.write(fingerprint(process.argv[1]));',
    english,
  ]);
  expect(result.exitCode, 0, reason: result.stderr.toString());
  return result.stdout.toString();
}
