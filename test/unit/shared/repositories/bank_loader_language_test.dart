// The loader reading a language folder over the English master. The folder is
// staged in a fake bundle because English is the only one that ships, so there
// is no real second folder to read yet.
import 'dart:convert';

import 'package:brew_path/shared/content/content_language.dart';
import 'package:brew_path/shared/repositories/bank_loader.dart';
import 'package:brew_path/shared/repositories/content_assembly.dart';
import 'package:brew_path/shared/repositories/language_overlay.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _polish = ContentLanguage(code: 'pl', speechTag: 'pl-PL');
const _bank = 'dictionary_terms';

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final contents = files[key];
    if (contents == null) throw Exception('no asset staged at $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(contents)));
  }
}

String _envelope(List<Map<String, dynamic>> items) =>
    jsonEncode({'bank': _bank, 'schemaVersion': 2, 'items': items});

_FakeBundle _bundle({List<Map<String, dynamic>>? polish}) => _FakeBundle({
  'assets/content/generated/$_bank.json': _envelope([
    {'id': 'arabica', 'term': 'Arabica', 'short': 'The sweeter species.'},
    {'id': 'robusta', 'term': 'Robusta', 'short': 'The hardier species.'},
  ]),
  if (polish != null) 'assets/content/l10n/pl/$_bank.json': _envelope(polish),
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('English is read straight through', () {
    test('the master needs no folder over it', () async {
      final records = await loadBankRecords(_bank, bundle: _bundle());

      expect(records.map((record) => record['term']), ['Arabica', 'Robusta']);
    });

    test('the shipping language reads the master', () async {
      expect(activeContentLanguage.isMaster, isTrue);
      expect(translatedBankPath(_bank, activeContentLanguage), isNull);
    });
  });

  group('a language folder lands on the master', () {
    test('a translated entry is what the reader gets', () async {
      final records = await loadBankRecords(
        _bank,
        language: _polish,
        bundle: _bundle(
          polish: [
            {'id': 'arabica', 'term': 'Arabika', 'short': 'Słodszy gatunek.'},
            {'id': 'robusta', 'term': 'Robusta'},
          ],
        ),
      );

      expect(records.first['term'], 'Arabika');
      expect(records.first['short'], 'Słodszy gatunek.');
    });

    test('an entry the folder omits falls back to English', () async {
      final records = await loadBankRecords(
        _bank,
        language: _polish,
        bundle: _bundle(
          polish: [
            {'id': 'arabica', 'term': 'Arabika'},
          ],
        ),
      );

      expect(records.last['term'], 'Robusta');
      expect(records.first['short'], 'The sweeter species.');
    });

    test('the approval fingerprint never reaches the record', () async {
      final records = await loadBankRecords(
        _bank,
        language: _polish,
        bundle: _bundle(
          polish: [
            {'id': 'arabica', 'term': 'Arabika', approvedAgainstField: 'abc'},
          ],
        ),
      );

      expect(records.first.containsKey(approvedAgainstField), isFalse);
    });

    test('a folder with no copy of the bank is a build defect', () async {
      expect(
        () => loadBankRecords(_bank, language: _polish, bundle: _bundle()),
        throwsA(
          isA<ContentFormatException>().having(
            (error) => error.message,
            'message',
            contains('assets/content/l10n/pl/$_bank.json'),
          ),
        ),
      );
    });
  });

  group('an unusable bank is refused by name', () {
    test('a bank the bundle does not carry', () async {
      expect(
        () => loadBankRecords('no_such_bank', bundle: _bundle()),
        throwsA(
          isA<ContentFormatException>().having(
            (error) => error.message,
            'message',
            contains('assets/content/generated/no_such_bank.json'),
          ),
        ),
      );
    });

    test('a bank stamped at another schema version', () async {
      final bundle = _FakeBundle({
        'assets/content/generated/$_bank.json': jsonEncode({
          'bank': _bank,
          'schemaVersion': 99,
          'items': [
            {'id': 'arabica'},
          ],
        }),
      });

      expect(
        () => loadBankRecords(_bank, bundle: bundle),
        throwsA(isA<ContentFormatException>()),
      );
    });
  });
}
