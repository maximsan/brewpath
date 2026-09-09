import 'package:brew_path/features/lessons/domain/cloze.dart';
import 'package:flutter_test/flutter_test.dart';

// A predict question carries its blank as a run of underscores. Splitting it is
// a derivation, so it is checked here rather than by reading a widget tree.
void main() {
  test('splits a question around its blank', () {
    expect(clozeSegments('A coffee bean is really the ___ of that fruit'), [
      'A coffee bean is really the ',
      ' of that fruit',
    ]);
  });

  test('a question with no blank is one segment', () {
    const plain = 'Same variety, same roast, two different mountains?';

    expect(clozeSegments(plain), [plain]);
    expect(hasCloze(plain), isFalse);
  });

  test('two underscores are a blank, one is not', () {
    expect(hasCloze('the __ of that fruit'), isTrue);
    expect(
      hasCloze('a snake_case identifier'),
      isFalse,
      reason: 'a lone underscore is punctuation, not a blank',
    );
  });

  test('a blank at either end leaves an empty segment beside it', () {
    expect(clozeSegments('___ carries the caffeine'), [
      '',
      ' carries the caffeine',
    ]);
    expect(clozeSegments('the caffeine is in ___'), [
      'the caffeine is in ',
      '',
    ]);
  });

  test('two blanks give three segments', () {
    expect(clozeSegments('___ beats ___ on caffeine'), [
      '',
      ' beats ',
      ' on caffeine',
    ]);
  });

  test('every authored predict question splits without losing its words', () {
    // The invariant the renderer depends on: segments plus blanks reassemble
    // the question, so no authored word can go missing on screen.
    const question = 'A coffee bean is really the ___ of that fruit';

    expect(
      clozeSegments(question).join('___'),
      question,
      reason: 'the split is lossless',
    );
  });
}
