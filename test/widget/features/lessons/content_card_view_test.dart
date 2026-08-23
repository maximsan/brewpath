import 'package:brew_path/features/lessons/presentation/cards/content_card_view.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts what crossed the card boundary. The whole contract is here: success
/// is reported at most once and only when earned, and continue is separate.
class _Signals {
  int solved = 0;
  int advanced = 0;
}

const _mcq = ContentCard.mcq(
  prompt: 'What is a coffee bean?',
  choices: [
    Choice(text: 'A seed', isCorrect: true),
    Choice(text: 'A legume'),
  ],
  explanation: 'It is the seed of a fruit.',
);

const _recall = ContentCard.recall(
  label: 'BEFORE YOU GO',
  question: 'What is it really?',
  choices: [
    Choice(text: 'The seed of a cherry', isCorrect: true),
    Choice(text: 'A dried leaf'),
  ],
  explanation: 'Botanically a seed.',
  takeaway: 'Coffee is fruit.',
);

const _decision = ContentCard.decision(
  label: 'AT THE SHELF',
  title: 'Old bag or fresh',
  scenario: 'Your coffee tastes flat.',
  question: 'What do you change?',
  options: [
    DecisionOption(
      text: 'Buy fresh',
      subtitle: 'Roasted 3 days ago',
      isCorrect: true,
    ),
    DecisionOption(text: 'Grind finer', subtitle: 'Opened 2 months ago'),
  ],
  rightExplanation: 'Fresh beans do more than any adjustment.',
  wrongExplanation: 'Grinding finer cannot restore lost aromatics.',
  note: 'Freshness first.',
);

const _predict = ContentCard.predict(
  label: 'LESSON 1',
  title: 'What coffee actually is',
  body: 'Coffee starts on a tree.',
  question: 'A coffee bean is really the ___',
  options: ['Seed', 'Skin'],
  answer: 'Seed',
  hold: 'Hold that thought.',
);

const _concept = ContentCard.concept(
  label: 'CONCEPT',
  title: 'The cherry, the seed',
  fill: [
    ConceptFillPart.literal('A coffee '),
    ConceptFillPart.blank(
      answer: 'seed',
      options: ['seed', 'skin'],
      label: 'What it is',
    ),
    ConceptFillPart.literal(' of a fruit.'),
  ],
  paragraphs: ['Coffee plants grow cherries.'],
  meta: [
    ['LOOKS LIKE', 'cherry'],
    ['ACTUALLY IS', 'seed'],
  ],
);

/// A tastefix round: what the cup is doing wrong, the setup that rules out the
/// obvious causes, and four fixes with the right one marked on the choice.
const _tastefix = ContentCard.tastefix(
  tags: ['SOUR', 'THIN'],
  scenario: 'Grind is dialled in and the beans are fresh.',
  prompt: 'The first sip puckers, and the cup feels hollow. What first?',
  choices: [
    Choice(text: 'Grind coarser'),
    Choice(text: 'Grind finer', isCorrect: true),
    Choice(text: 'Use colder water'),
    Choice(text: 'Brew for less time'),
  ],
  explanation: 'Puckering with no weight behind it is under-extraction.',
);

/// A flavor round whose correct note sits **third**, not first.
///
/// The position is the point. `flavor` holds correctness as an index into the
/// authored order rather than on the choice, so a mapping that reads the wrong
/// field, or shuffles before it marks, produces a round nobody can win — and a
/// fixture answering at index 0 would pass under several of those mistakes by
/// luck.
const _flavor = ContentCard.flavor(
  clue: 'A sharp, tangy brightness that makes your mouth water',
  prompt: 'Name the note',
  choices: [
    Choice(text: 'Caramel'),
    Choice(text: 'Cedar'),
    Choice(text: 'Citrus'),
    Choice(text: 'Tobacco'),
  ],
  answer: 2,
  explanation: 'That mouth-watering snap is acidity — most often citrus.',
);

Widget _host(ContentCard card, _Signals signals, {int nonce = 1}) =>
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: contentCardView(
            card,
            nonce: nonce,
            cardIndex: 0,
            onSolved: () => signals.solved++,
            onContinue: () => signals.advanced++,
          ),
        ),
      ),
    );

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Finder get _continueButton => find.widgetWithText(FilledButton, 'Continue');

bool _continueEnabled(WidgetTester tester) =>
    tester.widget<FilledButton>(_continueButton).onPressed != null;

void main() {
  group('every renderer', () {
    final cards = <String, ContentCard>{
      'predict': _predict,
      'concept': _concept,
      'mcq': _mcq,
      'decision': _decision,
      'recall': _recall,
      'flavor': _flavor,
      'tastefix': _tastefix,
    };

    for (final entry in cards.entries) {
      testWidgets('${entry.key} renders and gates continue on its latch', (
        tester,
      ) async {
        final signals = _Signals();
        await tester.pumpWidget(_host(entry.value, signals));

        expect(_continueButton, findsOneWidget);
        expect(
          _continueEnabled(tester),
          isFalse,
          reason: '${entry.key} let the learner past an unanswered card',
        );
        expect(signals.solved, 0);
      });
    }
  });

  group('tastefix — the cup that came out wrong', () {
    testWidgets('shows the symptoms, the setup and the fixes', (tester) async {
      await tester.pumpWidget(_host(_tastefix, _Signals()));

      // The symptoms frame the question rather than answering it.
      expect(find.textContaining('SOUR'), findsOneWidget);
      expect(find.textContaining('THIN'), findsOneWidget);
      expect(
        find.text('Grind is dialled in and the beans are fresh.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'The first sip puckers, and the cup feels hollow. What first?',
        ),
        findsOneWidget,
      );
      for (final fix in ['Grind coarser', 'Grind finer', 'Use colder water']) {
        expect(find.text(fix), findsOneWidget, reason: '$fix went missing');
      }
    });

    testWidgets('the right fix fires success exactly once', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_tastefix, signals));

      await _tapText(tester, 'Grind finer');

      expect(signals.solved, 1);
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('stays winnable whichever order a run draws', (tester) async {
      for (var nonce = 1; nonce <= 8; nonce++) {
        final signals = _Signals();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(_host(_tastefix, signals, nonce: nonce));
        await _tapText(tester, 'Grind finer');

        expect(signals.solved, 1, reason: 'unwinnable at nonce $nonce');
      }
    });

    testWidgets('a wrong fix stays silent and still explains', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_tastefix, signals));

      await _tapText(tester, 'Grind coarser');

      expect(signals.solved, 0);
      expect(
        find.text('Puckering with no weight behind it is under-extraction.'),
        findsOneWidget,
      );
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('latches on the first commit', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_tastefix, signals));

      await _tapText(tester, 'Grind coarser');
      await _tapText(tester, 'Grind finer');

      expect(signals.solved, 0);
    });
  });

  group('flavor — the note behind the clue', () {
    testWidgets('shows the tasting clue and every note', (tester) async {
      await tester.pumpWidget(_host(_flavor, _Signals()));

      expect(
        find.text('A sharp, tangy brightness that makes your mouth water'),
        findsOneWidget,
      );
      expect(find.text('Name the note'), findsOneWidget);
      for (final note in ['Caramel', 'Cedar', 'Citrus', 'Tobacco']) {
        expect(find.text(note), findsOneWidget, reason: '$note went missing');
      }
    });

    testWidgets('a correct note fires success exactly once', (tester) async {
      // **The trap test.** The answer is an index into the authored order, and
      // the options are shuffled — so this passes only if the index is resolved
      // into the marked option before the shuffle moves it. Mapping through the
      // helper the tastefix kind uses, or shuffling first, leaves every note
      // reading as wrong: the round renders perfectly and cannot be won.
      final signals = _Signals();
      await tester.pumpWidget(_host(_flavor, signals));

      await _tapText(tester, 'Citrus');

      expect(signals.solved, 1);
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('every seed keeps the answer winnable', (tester) async {
      // The shuffle is seeded per run, so correctness must survive whichever
      // order a run happens to draw — not merely the one this file pumps.
      for (var nonce = 1; nonce <= 8; nonce++) {
        final signals = _Signals();
        // A bare pump between runs, so each nonce meets a freshly mounted card
        // rather than the previous one updated in place — which would still be
        // latched, and would report every run after the first as a failure.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(_host(_flavor, signals, nonce: nonce));
        await _tapText(tester, 'Citrus');

        expect(signals.solved, 1, reason: 'unwinnable at nonce $nonce');
      }
    });

    testWidgets('a wrong note stays silent and still explains', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_flavor, signals));

      await _tapText(tester, 'Cedar');

      expect(signals.solved, 0);
      expect(
        find.text('That mouth-watering snap is acidity — most often citrus.'),
        findsOneWidget,
      );
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('latches on the first commit', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_flavor, signals));

      await _tapText(tester, 'Cedar');
      // Fishing for the answer after committing must change nothing.
      await _tapText(tester, 'Citrus');

      expect(signals.solved, 0);
    });
  });

  group('graded cards report success once, and only when earned', () {
    testWidgets('mcq fires onSolved for the right answer', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_mcq, signals));

      await _tapText(tester, 'A seed');

      expect(signals.solved, 1);
      expect(_continueEnabled(tester), isTrue);
      expect(find.text('It is the seed of a fruit.'), findsOneWidget);
    });

    testWidgets('mcq stays silent on a wrong answer', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_mcq, signals));

      await _tapText(tester, 'A legume');

      expect(signals.solved, 0);
      // Still explains itself, and still lets the learner move on.
      expect(find.text('It is the seed of a fruit.'), findsOneWidget);
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('recall fires once and shows its takeaway', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_recall, signals));

      await _tapText(tester, 'The seed of a cherry');

      expect(signals.solved, 1);
      expect(find.text('Coffee is fruit.'), findsOneWidget);
    });

    testWidgets('decision reads its wrong answer its own way', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_decision, signals));

      await _tapText(tester, 'Grind finer');

      expect(signals.solved, 0);
      expect(
        find.text('Grinding finer cannot restore lost aromatics.'),
        findsOneWidget,
      );
      expect(
        find.text('Fresh beans do more than any adjustment.'),
        findsNothing,
      );
    });

    testWidgets('decision reads its right answer its own way', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_decision, signals));

      await _tapText(tester, 'Buy fresh');

      expect(signals.solved, 1);
      expect(
        find.text('Fresh beans do more than any adjustment.'),
        findsOneWidget,
      );
      expect(
        find.text('Grinding finer cannot restore lost aromatics.'),
        findsNothing,
      );
    });
  });

  group('a card cannot be returned to an unanswered state', () {
    testWidgets('a second tap changes nothing', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_mcq, signals));

      await _tapText(tester, 'A seed');
      await _tapText(tester, 'A legume');

      expect(signals.solved, 1, reason: 'success was reported twice');
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('there is no retry affordance anywhere', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_mcq, signals));
      await _tapText(tester, 'A legume');

      expect(find.textContaining('Try Again'), findsNothing);
      expect(find.textContaining('Reset'), findsNothing);
    });
  });

  group('ungraded cards', () {
    testWidgets('predict holds its answer back rather than marking it', (
      tester,
    ) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_predict, signals));

      await _tapText(tester, 'Skin');

      // Wrong by the card's own answer, but nothing says so — the recall card
      // at the end of the lesson is what resolves it.
      expect(signals.solved, 0);
      expect(find.text('Hold that thought.'), findsOneWidget);
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('concept resolves a blank to its authored answer', (
      tester,
    ) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_concept, signals));

      expect(_continueEnabled(tester), isFalse);
      // Tap the *wrong* word: the sentence still resolves correctly, which is
      // the whole point of the fill card.
      await _tapText(tester, 'skin');

      // 'seed' also appears in the meta table, so look inside the sentence.
      expect(
        find.descendant(of: find.byType(Wrap), matching: find.text('seed')),
        findsOneWidget,
      );
      expect(find.text('skin'), findsNothing);
      expect(signals.solved, 0);
      expect(_continueEnabled(tester), isTrue);
    });
  });

  testWidgets('continue reports separately from success', (tester) async {
    final signals = _Signals();
    await tester.pumpWidget(_host(_mcq, signals));

    await _tapText(tester, 'A seed');
    expect(signals.advanced, 0);

    await tester.tap(_continueButton);
    await tester.pumpAndSettle();
    expect(signals.advanced, 1);
    expect(signals.solved, 1);
  });

  testWidgets('a different attempt orders the choices differently', (
    tester,
  ) async {
    List<String> optionOrder() => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(OutlinedButton),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data ?? '')
        .toList();

    await tester.pumpWidget(_host(_mcq, _Signals(), nonce: 100));
    final first = optionOrder();

    // Walk attempts until the order moves — a seeded shuffle is allowed to
    // repeat, but it must not be pinned to one arrangement.
    var moved = false;
    for (var nonce = 101; nonce < 111 && !moved; nonce++) {
      await tester.pumpWidget(_host(_mcq, _Signals(), nonce: nonce));
      await tester.pumpAndSettle();
      moved = optionOrder().join() != first.join();
    }
    expect(moved, isTrue, reason: 'choice order never changed across attempts');
  });

  group('hasRenderer agrees with what contentCardView actually builds', () {
    // Two exhaustive switches over the same sealed union. Adding a kind breaks
    // both, but nothing stops the two from disagreeing about a kind they both
    // already handle — which would either strand a playable card or drop a
    // drawable one out of a lesson silently.
    const cases = <String, ContentCard>{
      'predict': ContentCard.predict(
        label: 'LESSON 1',
        title: 'T',
        body: 'B',
        question: 'Q',
        options: ['a', 'b'],
        answer: 'a',
        hold: 'H',
      ),
      'concept': ContentCard.concept(
        label: 'CONCEPT',
        title: 'T',
        fill: [FillLiteral('x')],
        paragraphs: ['p'],
        meta: [],
      ),
      'mcq': _mcq,
      'recall': ContentCard.recall(
        label: 'BEFORE YOU GO',
        question: 'Q',
        choices: [Choice(text: 'a', isCorrect: true)],
        explanation: 'E',
        takeaway: 'L',
      ),
      'decision': ContentCard.decision(
        label: 'AT THE SHELF',
        title: 'T',
        scenario: 'S',
        question: 'Q',
        options: [DecisionOption(text: 'a', isCorrect: true)],
        rightExplanation: 'R',
        wrongExplanation: 'W',
      ),
      'quiz': ContentCard.quiz(
        statement: 'S',
        answer: true,
        explanation: 'E',
      ),
      'match': ContentCard.match(
        prompt: 'P',
        pairs: [MatchPair(left: 'l', right: 'r')],
      ),
      'visual': ContentCard.visual(
        label: 'L',
        title: 'T',
        subject: 'v',
        caption: 'C',
      ),
      'practical': ContentCard.practical(
        tag: 'TRY IT',
        title: 'T',
        paragraphs: ['p'],
        note: 'N',
      ),
      'multi': ContentCard.multi(
        prompt: 'P',
        choices: [Choice(text: 'a', isCorrect: true)],
        explanation: 'E',
      ),
      'sequence': ContentCard.sequence(
        prompt: 'P',
        items: [SequenceItem(label: 'a', order: 1)],
      ),
      'slider': ContentCard.slider(
        prompt: 'P',
        leftLabel: 'l',
        rightLabel: 'r',
        target: 1,
        tolerance: 1,
        scale: ['a', 'b'],
        feedback: 'F',
      ),
      'tastefix': ContentCard.tastefix(
        tags: ['t'],
        prompt: 'P',
        scenario: 'S',
        choices: [Choice(text: 'a', isCorrect: true)],
        explanation: 'E',
      ),
      'bagpick': ContentCard.bagpick(
        bag: 'B',
        origin: 'O',
        prompt: 'P',
        bean: BagpickBean(body: '#000', crease: '#111', mottle: 1, chaff: true),
        options: ['a', 'b'],
        answer: 'a',
        tell: 'T',
        cues: [BagpickCue(id: 'c', label: 'L', text: 'X')],
        explanation: 'E',
      ),
      'flavor': ContentCard.flavor(
        clue: 'C',
        prompt: 'P',
        choices: [Choice(text: 'a', isCorrect: true)],
        answer: 0,
        explanation: 'E',
      ),
    };

    for (final entry in cases.entries) {
      test(entry.key, () {
        final built = contentCardView(
          entry.value,
          nonce: 1,
          cardIndex: 0,
          onSolved: () {},
          onContinue: () {},
        );
        expect(hasRenderer(entry.value), built != null);
      });
    }
  });
}
