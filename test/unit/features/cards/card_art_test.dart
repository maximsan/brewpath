import 'dart:convert';
import 'dart:io';

import 'package:brew_path/features/cards/domain/card_art.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the three lists that have to agree about collectible art: the files
/// `tool/extract_card_art.js` wrote, the kinds the content bank names, and
/// [cardArtKinds]. Any two of them can be edited without the third noticing,
/// and the symptom — a card falling back to its module's mark — looks exactly
/// like a card the design never drew.
Map<String, dynamic> get _manifest =>
    jsonDecode(File('assets/card_art/index.json').readAsStringSync())
        as Map<String, dynamic>;

List<String> get _bankKinds =>
    ((jsonDecode(
                  File(
                    'assets/content/generated/collectibles.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>)['items']
            as List<dynamic>)
        .map((item) => (item as Map<String, dynamic>)['kind'] as String)
        .toList();

void main() {
  late List<Map<String, dynamic>> arts;

  setUp(() {
    arts = (_manifest['arts'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .toList();
  });

  test('every drawn art is named, and every name is drawn', () {
    expect(
      arts.map((art) => art['kind'] as String).toSet(),
      cardArtKinds,
      reason: 'run `node tool/extract_card_art.js` and update cardArtKinds',
    );
  });

  test('every kind the bank ships has art', () {
    expect(
      _bankKinds.toSet().difference(cardArtKinds),
      isEmpty,
      reason: 'a collectible would fall back to its module mark',
    );
  });

  test('the slug rule reproduces every file name the extractor wrote', () {
    for (final art in arts) {
      expect(cardArtSlug(art['kind'] as String), art['slug']);
    }
  });

  test('every named kind has a file on disk', () {
    for (final kind in cardArtKinds) {
      expect(File(cardArtAsset(kind)!).existsSync(), isTrue, reason: kind);
    }
  });

  test('a kind the design has not drawn resolves to no asset', () {
    // The fallback the card sheet and the tile lean on.
    expect(cardArtAsset('not-a-kind'), isNull);
  });
}
