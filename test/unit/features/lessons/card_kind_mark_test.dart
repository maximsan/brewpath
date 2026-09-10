import 'dart:convert';
import 'dart:io';

import 'package:brew_path/features/lessons/presentation/cards/card_kind_mark.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _bankKinds() {
  final raw = File('assets/content/generated/card_kind_help.json');
  final decoded = jsonDecode(raw.readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final item in decoded['items'] as List)
      (item as Map<String, dynamic>)['kind'] as String,
  ];
}

void main() {
  group('cardKindMarks', () {
    test('every kind with help carries a mark', () {
      for (final kind in _bankKinds()) {
        expect(
          cardKindMark(kind),
          isNotNull,
          reason: '$kind would open the drawer on an empty well',
        );
      }
    });

    test('maps nothing the help bank cannot reach', () {
      final bank = _bankKinds().toSet();

      for (final kind in cardKindMarks.keys) {
        expect(
          bank,
          contains(kind),
          reason: '$kind has a mark but no help to head',
        );
      }
    });

    test(
      'a kind the design never drew has no mark rather than a wrong one',
      () {
        expect(cardKindMark('nosuchkind'), isNull);
      },
    );
  });
}
