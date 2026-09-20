// The rule that turns glossary terms in lesson copy into links (#99).
// Asserted on synthetic terms rather than the shipped bank, so it tests the
// rule instead of the authoring.
import 'package:brew_path/features/dictionary/domain/term_links.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter_test/flutter_test.dart';

DictionaryTerm _term(
  String id,
  String name, {
  List<String> aliases = const [],
}) => DictionaryTerm(
  id: id,
  term: name,
  categoryId: 'brewing',
  shortExplanation: 'A word.',
  aliases: aliases,
);

final DictionaryTerm _crema = _term(
  'crema',
  'Crema',
  aliases: ['crema', 'the crema'],
);
final DictionaryTerm _bloom = _term('bloom', 'Bloom');
final DictionaryTerm _burr = _term(
  'burr-grinder',
  'Burr grinder',
  aliases: ['burr'],
);
final DictionaryTerm _burrSet = _term(
  'burr-set',
  'Burr set',
  aliases: ['burr set'],
);

List<String?> _ids(List<TermTextSegment> segments) => [
  for (final segment in segments) segment.termId,
];

List<String> _texts(List<TermTextSegment> segments) => [
  for (final segment in segments) segment.text,
];

void main() {
  group('matching', () {
    test('an alias links the term it belongs to', () {
      final segments = TermLinkIndex.of([
        _crema,
      ]).segmentsIn('Judge the crema first.');

      expect(_texts(segments), ['Judge ', 'the crema', ' first.']);
      expect(_ids(segments), [null, 'crema', null]);
    });

    test('a term with no alias of its own links under its name', () {
      final segments = TermLinkIndex.of([_bloom]).segmentsIn('Let it bloom.');

      expect(_texts(segments), ['Let it ', 'bloom', '.']);
      expect(_ids(segments), [null, 'bloom', null]);
    });

    test('the match is case-insensitive and keeps the copy as written', () {
      final segments = TermLinkIndex.of([_bloom]).segmentsIn('Bloom first.');

      expect(_texts(segments).first, 'Bloom');
      expect(_ids(segments).first, 'bloom');
    });

    test('a word that merely contains an alias does not link', () {
      final segments = TermLinkIndex.of([
        _burr,
      ]).segmentsIn('Burrito for lunch.');

      expect(segments, hasLength(1));
      expect(_ids(segments), [null]);
    });

    test('the longest of two overlapping aliases wins', () {
      final segments = TermLinkIndex.of([
        _burr,
        _burrSet,
      ]).segmentsIn('Swap the burr set out.');

      expect(_texts(segments), ['Swap the ', 'burr set', ' out.']);
      expect(_ids(segments), [null, 'burr-set', null]);
    });

    test('a term links once, at its first occurrence', () {
      final segments = TermLinkIndex.of([
        _bloom,
      ]).segmentsIn('Bloom the bed, then bloom again.');

      expect(_ids(segments), ['bloom', null]);
      expect(_texts(segments), ['Bloom', ' the bed, then bloom again.']);
    });

    test('text with no match comes back as one plain run', () {
      final segments = TermLinkIndex.of([_crema]).segmentsIn('Nothing here.');

      expect(segments, hasLength(1));
      expect(segments.single, (text: 'Nothing here.', termId: null));
    });

    test('a term the view does not hold never links', () {
      final segments = TermLinkIndex.of([
        _bloom,
      ]).segmentsIn('Judge the crema.');

      expect(_ids(segments), [null]);
    });
  });

  group('how many', () {
    test('a fifth term in one run does not link', () {
      final terms = [
        for (var index = 0; index < 5; index++) _term('t$index', 'word$index'),
      ];

      final segments = TermLinkIndex.of(
        terms,
      ).segmentsIn('word0 word1 word2 word3 word4.');

      expect(
        _ids(segments).whereType<String>(),
        ['t0', 't1', 't2', 't3'],
        reason: 'the design caps a run at four links',
      );
      expect(_texts(segments).last, ' word4.');
    });
  });

  group('the index', () {
    test('an empty index leaves every run plain', () {
      final segments = TermLinkIndex.empty.segmentsIn('Judge the crema.');

      expect(segments, hasLength(1));
      expect(_ids(segments), [null]);
    });
  });
}
