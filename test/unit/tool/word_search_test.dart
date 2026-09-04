import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The word-boundary contract behind the term check, exercised directly.
///
/// The seeded-fixture tests prove the check *fires*; these prove it draws the
/// boundary where the spec says, on the exact pairs it names. Both matter: a
/// matcher that is too permissive lets a false pointer through, and a false
/// pointer is what #20's stored Learned state cements permanently.
///
/// Driven through `node` like the extractor tests, because the matcher is the
/// extractor's and re-implementing it here is the drift decision 4 forbids.
const _module = 'tool/extract_content/validate/mentions.js';

bool _mentions(String haystack, String needle) {
  const script =
      '''
const { mentionsWholeWord } = require('./$_module');
const [haystack, needle] = JSON.parse(process.argv[1]);
process.stdout.write(String(mentionsWholeWord(haystack, needle)));
''';
  final result = Process.runSync('node', [
    '-e',
    script,
    jsonEncode([haystack, needle]),
  ]);
  expect(result.exitCode, 0, reason: result.stderr.toString());
  return result.stdout.toString() == 'true';
}

void main() {
  test('a term inside a longer word does not count as saying it', () {
    // The two pairs the spec names. Substring matching is permissive in the
    // dangerous direction, and several terms are short with thin alias lists.
    expect(_mentions('everybody knows this', 'body'), isFalse);
    expect(_mentions('the body of the cup', 'body'), isTrue);

    expect(_mentions('that defines the grind', 'fines'), isFalse);
    expect(_mentions('too many fines in the basket', 'fines'), isTrue);
  });

  test('a term carrying a subscript still matches', () {
    // A naive word boundary cannot match a term containing a subscript and
    // invents a false failure on CO₂ — the one case that made the boundary
    // Unicode-aware rather than `\\b`.
    expect(_mentions('CO₂ builds up in the bag', 'CO₂'), isTrue);
    expect(_mentions('degassing releases co₂ slowly', 'CO₂'), isTrue);
  });

  test('matching ignores case but not spelling', () {
    expect(_mentions('a pour-over cone', 'Pour-Over'), isTrue);
    expect(_mentions('a pourover cone', 'Pour-Over'), isFalse);
  });

  test('punctuation around a word is a boundary, not part of it', () {
    expect(_mentions('the crema, thick and hazelnut', 'crema'), isTrue);
    expect(_mentions('(tamp) evenly', 'tamp'), isTrue);
  });
}
