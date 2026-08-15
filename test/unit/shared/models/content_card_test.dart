import 'dart:convert';
import 'dart:io';

import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/content_card_grading.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads the generated bank off disk rather than through `rootBundle`, so the
/// test exercises exactly the bytes `tool/extract_content.js` wrote.
const _lessonsBank = 'assets/content/generated/lessons.json';

/// Every kind the union claims to cover. Kept as a literal so that a kind
/// disappearing from the content is a failure rather than a silently smaller
/// set.
const _allKinds = {
  'predict',
  'concept',
  'visual',
  'practical',
  'mcq',
  'multi',
  'recall',
  'decision',
  'match',
  'sequence',
  'slider',
  'tastefix',
  'bagpick',
  'flavor',
};

Map<String, dynamic> _readBank() =>
    jsonDecode(File(_lessonsBank).readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> _readCards() {
  final lessons = _readBank()['items'] as List<dynamic>;
  return [
    for (final lesson in lessons.cast<Map<String, dynamic>>())
      ...(lesson['cards'] as List<dynamic>).cast<Map<String, dynamic>>(),
  ];
}

void main() {
  final cards = _readCards();

  test('the bank is not empty', () {
    expect(cards, isNotEmpty, reason: 'run `node tool/extract_content.js`');
  });

  // The extractor emits the prototype's field vocabulary verbatim, so a rename
  // on that side arrives here as a missing key. Constructing every card is what
  // turns that into a red build instead of a runtime null.
  test('every card the extractor emits deserializes', () {
    for (final json in cards) {
      expect(
        () => ContentCard.fromJson(json),
        returnsNormally,
        reason: 'card ${json['kind']} failed: $json',
      );
    }
  });

  test('every card kind is authored and covered by the union', () {
    final seen = cards.map((json) => json['kind'] as String).toSet();
    expect(seen, _allKinds);
  });

  // The complement of the deserialize check: that one catches a key the model
  // needs and the content dropped, this one catches a key the content carries
  // and the model silently ignores — a renamed optional field, or a new one.
  test('no card carries a field the union does not read', () {
    for (final json in cards) {
      final read = ContentCard.fromJson(json).toJson().keys.toSet();
      expect(
        json.keys.toSet().difference(read),
        isEmpty,
        reason: 'card ${json['kind']} carries fields ContentCard drops',
      );
    }
  });

  // The wrong-denominator guard. `isGraded` and the `Gradable` marker are two
  // statements of the same fact; a variant that gains one without the other is
  // how mastery starts dividing by the wrong number.
  test('the Gradable marker and isGraded agree on every card', () {
    for (final json in cards) {
      final card = ContentCard.fromJson(json);
      expect(
        card is Gradable,
        isGraded(card),
        reason: '${json['kind']} is marked and classified differently',
      );
    }
  });

  // The same guard across the language boundary. The extractor decides which
  // kinds get an answer check; the union decides which ones score. Nothing else
  // holds those two lists together, and mastery divides by them.
  test('the extractor and the union agree on which kinds are graded', () {
    final emitted = (_readBank()['gradedKinds'] as List<dynamic>)
        .cast<String>();
    final marked = {
      for (final json in cards)
        if (ContentCard.fromJson(json) is Gradable) json['kind'] as String,
    };

    expect(marked, emitted.toSet());
  });

  test('gradedCards keeps the graded cards and drops the rest', () {
    final parsed = cards.map(ContentCard.fromJson).toList();
    final graded = gradedCards(parsed);

    expect(graded, hasLength(parsed.where(isGraded).length));
    expect(graded, everyElement(isA<Gradable>()));
    expect(graded.length, lessThan(parsed.length));
  });
}
