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

  test('no asset carries a CSS variable the renderer cannot read', () {
    for (final kind in cardArtKinds) {
      expect(
        File(cardArtAsset(kind)!).readAsStringSync(),
        isNot(contains('var(--')),
        reason: '$kind kept a custom property, which paints nothing',
      );
    }
  });

  test('a clip travels as clip-path, not as the element spelling', () {
    // `clipPath` is camelCase as an *element*; the attribute is `clip-path`.
    // Emitting the element spelling drops the clip silently — the parser finds
    // no `clip-path`, and the shape draws unclipped with no error anywhere.
    for (final kind in cardArtKinds) {
      final markup = File(cardArtAsset(kind)!).readAsStringSync();
      expect(markup, isNot(contains('clipPath=')), reason: kind);
    }
    expect(
      File(cardArtAsset('lightdark')!).readAsStringSync(),
      contains('clip-path='),
      reason: 'the bean in Light vs Dark is clipped by the design',
    );
  });

  test('every paint in every asset maps to a token', () {
    final sentinels =
        ((jsonDecode(
                      File('assets/card_art/index.json').readAsStringSync(),
                    )
                    as Map<String, dynamic>)['sentinels']
                as Map<String, dynamic>)
            .values
            .cast<String>()
            .toSet();
    final literals =
        ((jsonDecode(
                      File('assets/card_art/index.json').readAsStringSync(),
                    )
                    as Map<String, dynamic>)['literals']
                as Map<String, dynamic>)
            .keys
            .toSet();
    final paint = RegExp(
      '(?:fill|stroke|color|stop-color|flood-color|lighting-color)'
      '="([^"]*)"',
    );

    for (final kind in cardArtKinds) {
      for (final match in paint.allMatches(
        File(cardArtAsset(kind)!).readAsStringSync(),
      )) {
        final value = match.group(1)!;
        expect(
          value == 'none' ||
              sentinels.contains(value) ||
              literals.contains(value),
          isTrue,
          reason: '$kind paints in $value, which follows no token',
        );
      }
    }
  });
}
