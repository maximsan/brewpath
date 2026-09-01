// What counts as a lesson *mentioning* a term — the rule the practice pool is
// derived from (ADR-0014). Asserted on synthetic lessons rather than the
// shipped banks, so it tests the rule instead of the authoring.
import 'package:brew_path/features/dictionary/domain/lesson_visible_text.dart';
import 'package:brew_path/features/dictionary/domain/term_mentions.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/content_reward.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _reward = ContentReward(
  title: 'A card',
  summary: 'For finishing.',
  fact: 'Coffee is a fruit seed.',
);

LessonModel _lesson(List<ContentCard> cards, {String title = 'A lesson'}) =>
    LessonModel(
      id: 'm1l1',
      moduleId: 'm1',
      moduleLabel: 'MODULE 1 · BEANS',
      title: title,
      points: 10,
      time: 4,
      cards: cards,
      reward: _reward,
    );

ContentCard _prose(String body) => ContentCard.practical(
  tag: 'TRY IT',
  title: 'A card',
  paragraphs: [body],
  note: 'A note.',
);

DictionaryTerm _term(
  String id,
  String name, {
  List<String> aliases = const [],
}) => DictionaryTerm(
  id: id,
  term: name,
  categoryId: 'beans',
  shortExplanation: 'What $name means.',
  aliases: aliases,
);

Set<String> _mentions(String body, List<DictionaryTerm> terms) =>
    termsMentionedIn(
      lessons: [
        _lesson([_prose(body)]),
      ],
      terms: terms,
    );

void main() {
  group('a mention is a whole word', () {
    test('the term said plainly is a mention', () {
      expect(
        _mentions('Arabica is the sweeter species.', [_term('a', 'Arabica')]),
        contains('a'),
      );
    });

    test('case does not matter, in either direction', () {
      expect(
        _mentions('ARABICA beans.', [_term('a', 'arabica')]),
        contains('a'),
      );
    });

    test('a term buried inside a longer word is not a mention', () {
      // The failure substring matching would introduce: `scale` is not SCA,
      // and counting it would quietly widen the free pool with a term no
      // lesson says.
      expect(
        _mentions('Set the scale to zero.', [_term('sca', 'SCA')]),
        isEmpty,
      );
      expect(
        _mentions('An atypical harvest.', [_term('typica', 'Typica')]),
        isEmpty,
      );
    });

    test('punctuation and hyphens still bound a word', () {
      expect(
        _mentions('Try a pour-over, slowly.', [_term('po', 'Pour-Over')]),
        contains('po'),
      );
      expect(_mentions('It is crema.', [_term('c', 'Crema')]), contains('c'));
    });

    test('an alias counts as the term', () {
      expect(
        _mentions('The coffee goes stale.', [
          _term('staling', 'Staling', aliases: ['stale']),
        ]),
        contains('staling'),
      );
    });

    test('a term nothing says is not mentioned', () {
      expect(_mentions('Nothing to see.', [_term('a', 'Arabica')]), isEmpty);
    });
  });

  group('only what a learner can read counts', () {
    test('copy a card renders is searched', () {
      final lesson = _lesson([
        const ContentCard.mcq(
          prompt: 'Which is sweeter?',
          choices: [
            Choice(text: 'Arabica', isCorrect: true),
            Choice(text: 'Robusta'),
          ],
          explanation: 'Arabica carries more sugar.',
        ),
      ]);

      expect(
        termsMentionedIn(lessons: [lesson], terms: [_term('r', 'Robusta')]),
        contains('r'),
      );
    });

    test('a card kind carries its own visible copy', () {
      // A guard on the exhaustive switch: a kind that returned nothing would
      // silently stop contributing mentions.
      const card = ContentCard.quiz(
        statement: 'Robusta has more caffeine.',
        answer: true,
        explanation: 'It does.',
      );

      expect(cardVisibleText(card), contains('Robusta has more caffeine.'));
    });

    test('a visual card contributes its caption, not its axis slug', () {
      // `subject` is a slug the renderer never prints — counting it would let
      // a term be "mentioned" by a field nobody reads.
      const card = ContentCard.visual(
        label: 'GUIDE',
        title: 'Roast levels',
        subject: 'roast',
        caption: 'From city to French.',
      );

      expect(cardVisibleText(card), contains('From city to French.'));
      expect(cardVisibleText(card), isNot(contains('roast')));
    });

    test('the lesson title and its reward are read too', () {
      final lesson = _lesson(
        [_prose('Nothing here.')],
        title: 'What terroir means',
      );

      expect(
        termsMentionedIn(lessons: [lesson], terms: [_term('t', 'Terroir')]),
        contains('t'),
      );
      expect(lessonVisibleText(lesson), contains(_reward.fact));
    });
  });
}
