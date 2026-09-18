// Roasty's lines as a bank: a language folder reaches them, and the committed
// bank still answers every reaction a surface can fire (#604). The folder is
// staged in a fake bundle because English is the only one that ships.
import 'dart:convert';
import 'dart:io';

import 'package:brew_path/features/companion/data/companion_lines_repository.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/shared/content/content_language.dart';
import 'package:brew_path/shared/repositories/bank_envelope.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

const _polish = ContentLanguage(code: 'pl', speechTag: 'pl-PL');
const _bank = 'companion_lines';

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

String _envelope(List<Map<String, dynamic>> items) => jsonEncode({
  'bank': _bank,
  'schemaVersion': contentSchemaVersion,
  'items': items,
});

_FakeBundle _bundle({List<Map<String, dynamic>>? polish}) => _FakeBundle({
  'assets/content/generated/$_bank.json': _envelope([
    {'id': 'rl-nice-brew', 'occasion': 'lessonComplete', 'text': 'Nice brew!'},
  ]),
  if (polish != null) 'assets/content/l10n/pl/$_bank.json': _envelope(polish),
});

List<Map<String, dynamic>> _committed() {
  final file = File(p.join('assets/content/generated', '$_bank.json'));
  final envelope = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return (envelope['items'] as List).cast<Map<String, dynamic>>();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('a language folder reaches Roasty', () {
    test('English is what Roasty says with no folder over it', () async {
      final lines = await CompanionLinesRepository().getLines(
        bundle: _bundle(),
      );

      expect(lines.lineFor(CompanionReaction.lessonComplete), 'Nice brew!');
    });

    test('a staged folder changes what Roasty says', () async {
      final lines = await CompanionLinesRepository().getLines(
        language: _polish,
        bundle: _bundle(
          polish: [
            {'id': 'rl-nice-brew', 'text': 'Nieźle zaparzone!'},
          ],
        ),
      );

      expect(
        lines.lineFor(CompanionReaction.lessonComplete),
        'Nieźle zaparzone!',
      );
    });

    test('a line the folder omits stays English', () async {
      final lines = await CompanionLinesRepository().getLines(
        language: _polish,
        bundle: _bundle(
          polish: [
            {'id': 'rl-nice-brew', 'occasion': 'lessonComplete'},
          ],
        ),
      );

      expect(lines.lineFor(CompanionReaction.lessonComplete), 'Nice brew!');
    });
  });

  group('the committed bank', () {
    test('answers every reaction a surface can fire', () {
      final occasions = _committed()
          .map((record) => record['occasion'])
          .toSet();

      for (final reaction in CompanionReaction.values) {
        expect(
          occasions,
          contains(reaction.name),
          reason: 'no line answers ${reaction.name}',
        );
      }
    });

    test('gives every line an id of its own', () {
      final ids = _committed().map((record) => record['id']).toList();

      expect(ids, everyElement(isA<String>()));
      expect(ids.toSet(), hasLength(ids.length));
    });
  });
}
