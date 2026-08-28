import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
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

/// A bag whose tell is its centre cut, with the answer authored **second** in
/// the options so a run that keys off position rather than the process key
/// cannot pass by accident.
const _multi =
    ContentCard.multi(
          prompt: 'Which of these change how a cup tastes?',
          choices: [
            Choice(text: 'Grind size', isCorrect: true),
            Choice(text: 'Mug colour'),
            Choice(text: 'Water temperature', isCorrect: true),
            Choice(text: 'The weather'),
            Choice(text: 'Brew time', isCorrect: true),
          ],
          explanation: 'Grind, temperature and time are the three you control.',
        )
        as MultiCard;

const _bagpick = ContentCard.bagpick(
  bag: 'BAG 01',
  origin: 'Ethiopia · 1,900 m',
  prompt: 'How was this lot processed?',
  bean: BagpickBean(
    body: 'var(--art-cherry-seed)',
    crease: '#F0E9D9',
    mottle: 0,
    chaff: false,
  ),
  options: ['natural', 'washed'],
  answer: 'washed',
  tell: 'cut',
  cues: [
    BagpickCue(
      id: 'colour',
      label: 'Colour',
      text: 'Even blue-green. Every bean the same shade.',
    ),
    BagpickCue(
      id: 'cut',
      label: 'Centre cut',
      text: 'A clean, pale line — nothing packed into it.',
    ),
    BagpickCue(id: 'aroma', label: 'Aroma', text: 'Dry and grassy, like hay.'),
  ],
  explanation: 'Even colour and a pale centre cut are the washed signature.',
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

/// Whether [verdict] is spoken when it appears, rather than only drawn.
///
/// Shared by every kind that ends on a line naming the outcome. Those lines
/// arrive on commit with no focus change to bring a reader to them, so without
/// a live region a learner using one hears the marks and never the result.
bool _announces(WidgetTester tester, String verdict) => tester
    .widgetList<Semantics>(find.byType(Semantics))
    .where((node) => node.properties.label == verdict)
    .any((node) => node.properties.liveRegion ?? false);

void main() {
  group('every renderer', () {
    // Three kinds are absent on purpose, all because this table asserts a
    // *disabled Continue* before the card is answered. `visual` and
    // `practical` are read, not asked, so Continue is live from the first
    // frame; `multi` shows *Check answers* in its place until it commits, as
    // the design's single swapping button has it. Each is covered where its
    // own rule lives, and the switch-pair test at the foot of this file is
    // what keeps every kind covered.
    final cards = <String, ContentCard>{
      'predict': _predict,
      'concept': _concept,
      'mcq': _mcq,
      'decision': _decision,
      'recall': _recall,
      'flavor': _flavor,
      'tastefix': _tastefix,
      'bagpick': _bagpick,
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

  group('bagpick — investigate, then call it', () {
    /// Taps a process in the option list.
    ///
    /// Scoped deliberately: once called, the bag names the process too, so a
    /// bare text finder matches the pill as well as the option. The options are
    /// last on the card, which is what `.last` leans on.
    Future<void> call(WidgetTester tester, String process) async {
      await tester.tap(find.text(process).last);
      await tester.pumpAndSettle();
    }

    /// The screen-reader label of the cue row headed [label].
    String cueLabel(WidgetTester tester, String label) => tester
        .widgetList<Semantics>(find.byType(Semantics))
        .map((node) => node.properties.label)
        .whereType<String>()
        .singleWhere((text) => text.startsWith(label));

    testWidgets('withholds the process until the learner commits', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_bagpick, _Signals()));

      // The concealment is the game: a card showing the answer while asking
      // the question is not asking anything.
      expect(find.text('Process hidden'), findsOneWidget);
      expect(find.text('Washed'), findsOneWidget); // the option, not the label
      expect(find.text('BAG 01'), findsOneWidget);
      expect(find.text('Ethiopia · 1,900 m'), findsOneWidget);
    });

    testWidgets('names the process on the bag once called', (tester) async {
      await tester.pumpWidget(_host(_bagpick, _Signals()));

      await call(tester, 'Washed');

      expect(find.text('Process hidden'), findsNothing);
      // Now on the bag as well as on the option that was chosen.
      expect(find.text('Washed'), findsNWidgets(2));
    });

    testWidgets('a closed cue looks closed, before its words are read', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_bagpick, _Signals()));

      /// The surface behind the cue row showing [text].
      Color? surfaceBehind(String text) => tester
          .widget<Material>(find.widgetWithText(Material, text).first)
          .color;

      await tester.tap(find.text('Tap to inspect').first);
      await tester.pumpAndSettle();

      // Compared in the same frame: an opened row against one still closed,
      // which is exactly what the learner is looking at.
      expect(
        surfaceBehind('Even blue-green. Every bean the same shade.'),
        isNot(surfaceBehind('Tap to inspect')),
        reason:
            'a row whose only difference is its text makes the learner read '
            'every row to find the unread ones — on the one card where '
            'looking is the interaction',
      );
    });

    testWidgets('a closed cue is dashed and an opened one is not', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_bagpick, _Signals()));

      /// The shape drawn around the cue row showing [text].
      ShapeBorder? shapeAround(String text) {
        final decoration = tester
            .widget<Container>(find.widgetWithText(Container, text).first)
            .decoration;
        return decoration is ShapeDecoration ? decoration.shape : null;
      }

      await tester.tap(find.text('Tap to inspect').first);
      await tester.pumpAndSettle();

      // The design draws a cue dashed over nothing and fills it in once
      // inspected — compared in the same frame, as the learner sees them.
      expect(
        shapeAround('Tap to inspect'),
        isA<DashedRoundedBorder>(),
        reason: 'a cue waiting to be read is an outline, not a filled box',
      );
      expect(
        shapeAround('Even blue-green. Every bean the same shade.'),
        isNot(isA<DashedRoundedBorder>()),
      );
    });

    testWidgets('the verdict is coloured by outcome, not only worded', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_bagpick, _Signals()));
      await call(tester, 'Natural');
      final wrong = tester.widget<Text>(find.text('Washed, actually.'));

      // A bare re-pump reuses the same State, so the card would still be
      // latched on the wrong call and never reach the right one.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_host(_bagpick, _Signals()));
      await call(tester, 'Washed');
      final right = tester.widget<Text>(find.text('Called it.'));

      expect(
        right.style?.color,
        isNot(wrong.style?.color),
        reason: 'scanning back over a run, wording alone is easy to miss',
      );
    });

    for (final (process, verdict) in [
      ('Washed', 'Called it.'),
      ('Natural', 'Washed, actually.'),
    ]) {
      testWidgets('$verdict is announced, not only drawn', (tester) async {
        // Colour is what separates right from wrong here, and colour is the
        // one thing a screen reader cannot report. The option list marks the
        // call itself, but only this line names the outcome, and it arrives
        // with no focus change to bring a reader to it.
        await tester.pumpWidget(_host(_bagpick, _Signals()));

        await call(tester, process);

        expect(find.text(verdict), findsOneWidget);
        expect(_announces(tester, verdict), isTrue);
      });
    }

    testWidgets('a cue is hidden until it is inspected', (tester) async {
      await tester.pumpWidget(_host(_bagpick, _Signals()));

      expect(find.text('Tap to inspect'), findsNWidgets(3));
      expect(find.text('Dry and grassy, like hay.'), findsNothing);

      await _tapText(tester, 'Aroma');

      expect(find.text('Dry and grassy, like hay.'), findsOneWidget);
      // The other two stay shut — inspecting is one cue at a time.
      expect(find.text('Tap to inspect'), findsNWidgets(2));
    });

    testWidgets('calling it without inspecting anything is allowed', (
      tester,
    ) async {
      // Confidence is a legitimate way to play. A card that required every cue
      // to be opened would be a checklist rather than a judgement.
      final signals = _Signals();
      await tester.pumpWidget(_host(_bagpick, signals));

      await call(tester, 'Washed');

      expect(signals.solved, 1);
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('names the cue that was the real tell', (tester) async {
      // The round's whole teaching payload. A version that graded the call and
      // skipped this would pass every other test here and teach nothing.
      await tester.pumpWidget(_host(_bagpick, _Signals()));

      await call(tester, 'Natural');

      expect(cueLabel(tester, 'Centre cut'), contains('This was the tell'));
      // And only that one — the tell is a single cue, not a mood on all three.
      expect(cueLabel(tester, 'Colour'), isNot(contains('the tell')));
      expect(cueLabel(tester, 'Aroma'), isNot(contains('the tell')));
    });

    testWidgets('every cue opens once the call is made', (tester) async {
      // So the explanation can point at a cue the learner never looked at.
      await tester.pumpWidget(_host(_bagpick, _Signals()));

      await call(tester, 'Washed');

      expect(find.text('Tap to inspect'), findsNothing);
      expect(
        find.text('A clean, pale line — nothing packed into it.'),
        findsOneWidget,
      );
    });

    testWidgets('a wrong call stays silent and still explains', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_bagpick, signals));

      await _tapText(tester, 'Natural');

      expect(signals.solved, 0);
      expect(
        find.text(
          'Even colour and a pale centre cut are the washed signature.',
        ),
        findsOneWidget,
      );
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('latches: neither the call nor the cues move after', (
      tester,
    ) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_bagpick, signals));

      await call(tester, 'Natural');
      await call(tester, 'Washed');

      expect(signals.solved, 0, reason: 'a second call was accepted');
    });

    testWidgets('is winnable whichever order the options are drawn in', (
      tester,
    ) async {
      // The answer is matched on the process key. A run that compared indices
      // would pass for some seeds and fail for others, which is exactly the
      // kind of bug a single-seed test lets through.
      for (var nonce = 1; nonce <= 8; nonce++) {
        final signals = _Signals();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(_host(_bagpick, signals, nonce: nonce));
        await call(tester, 'Washed');

        expect(signals.solved, 1, reason: 'unwinnable at nonce $nonce');
      }
    });
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

    testWidgets('predict lets the learner change their guess', (tester) async {
      await tester.pumpWidget(_host(_predict, _Signals()));

      /// Whether the tile carrying [text] is drawn as the chosen one.
      bool chosen(String text) {
        final button = tester.widget<OutlinedButton>(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(OutlinedButton),
          ),
        );
        return button.style?.backgroundColor?.resolve(const {}) != null;
      }

      await _tapText(tester, 'Skin');
      expect(chosen('Skin'), isTrue);

      // Nothing here is scored, so nothing is protected by latching — and a
      // first instinct immediately reconsidered is still the instinct.
      await _tapText(tester, 'Seed');
      expect(chosen('Seed'), isTrue);
      expect(chosen('Skin'), isFalse);
    });

    testWidgets('predict dims the guess not taken, without disabling it', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_predict, _Signals()));
      await _tapText(tester, 'Seed');

      final faded = tester.widget<Opacity>(
        find.ancestor(of: find.text('Skin'), matching: find.byType(Opacity)),
      );
      expect(faded.opacity, lessThan(1));
      expect(
        faded.opacity,
        greaterThan(0),
        reason: 'the other guess must stay readable — it can still be taken',
      );
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

  group('multi — select all that apply, checked together', () {
    /// Picks each of [texts] and commits the card.
    Future<void> pickAndCheck(WidgetTester tester, List<String> texts) async {
      for (final text in texts) {
        await _tapText(tester, text);
      }
      await _tapText(tester, 'Check answers');
    }

    testWidgets('asks for every answer, and offers them all', (tester) async {
      await tester.pumpWidget(_host(_multi, _Signals()));

      expect(find.text('Select all that apply'), findsOneWidget);
      expect(find.text(_multi.prompt), findsOneWidget);
      for (final choice in _multi.choices) {
        expect(find.text(choice.text), findsOneWidget);
      }
    });

    testWidgets('cannot be checked until something is picked', (tester) async {
      await tester.pumpWidget(_host(_multi, _Signals()));

      final check = find.widgetWithText(FilledButton, 'Check answers');
      expect(
        tester.widget<FilledButton>(check).onPressed,
        isNull,
        reason: 'an empty selection is not an answer',
      );

      await _tapText(tester, 'Grind size');
      expect(tester.widget<FilledButton>(check).onPressed, isNotNull);
    });

    testWidgets('one button, which swaps once the set is committed', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_multi, _Signals()));

      // The design shows a single primary action, never a check beside a
      // dead Continue.
      expect(find.text('Check answers'), findsOneWidget);
      expect(_continueButton, findsNothing);

      await pickAndCheck(tester, ['Grind size']);

      expect(find.text('Check answers'), findsNothing);
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('the exact correct set scores, once', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_multi, signals));

      await pickAndCheck(tester, [
        'Grind size',
        'Water temperature',
        'Brew time',
      ]);

      expect(signals.solved, 1);
      expect(find.text('ALL CORRECT'), findsOneWidget);
    });

    for (final (picks, verdict) in [
      (['Grind size', 'Water temperature', 'Brew time'], 'ALL CORRECT'),
      (['Grind size'], 'NOT QUITE'),
    ]) {
      testWidgets('$verdict is announced, not only shown', (tester) async {
        // The per-choice marks say what each row was; only this line says
        // whether the card was passed. It appears with no focus change to
        // bring a reader to it, so without a live region a learner using one
        // hears every mark and never the outcome — the same reason the match
        // board announces its own verdict.
        await tester.pumpWidget(_host(_multi, _Signals()));

        await pickAndCheck(tester, picks);

        expect(find.text(verdict), findsOneWidget);
        expect(_announces(tester, verdict), isTrue);
      });
    }

    testWidgets('a correct subset scores nothing', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_multi, signals));

      await pickAndCheck(tester, ['Grind size', 'Water temperature']);

      expect(
        signals.solved,
        0,
        reason: 'missing an answer is not a partial pass',
      );
      expect(find.text('NOT QUITE'), findsOneWidget);
    });

    testWidgets('picking everything scores nothing', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_multi, signals));

      await pickAndCheck(tester, [
        for (final choice in _multi.choices) choice.text,
      ]);

      expect(
        signals.solved,
        0,
        reason: 'picking everything must not be a winning strategy',
      );
    });

    testWidgets('names what should have been picked', (tester) async {
      await tester.pumpWidget(_host(_multi, _Signals()));

      await pickAndCheck(tester, ['Grind size']);

      expect(
        find.text('MISSED'),
        findsNWidgets(2),
        reason: 'both unpicked answers must be shown as missed',
      );
    });

    testWidgets('a missed answer is outlined in dashes, as the design has it', (
      tester,
    ) async {
      /// The shape an option row is drawn with.
      ShapeBorder? shapeOf(String text) {
        final button = tester.widget<OutlinedButton>(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(OutlinedButton),
          ),
        );
        return button.style?.shape?.resolve(const {});
      }

      await tester.pumpWidget(_host(_multi, _Signals()));
      await pickAndCheck(tester, ['Grind size']);

      expect(shapeOf('Water temperature'), isA<DashedRoundedBorder>());
      expect(
        shapeOf('Grind size'),
        isNot(isA<DashedRoundedBorder>()),
        reason: 'only the answer left unpicked is dashed',
      );
    });

    testWidgets('a missed answer is not drawn like one you got right', (
      tester,
    ) async {
      /// The fill behind an option row, which is what separates the marks.
      Color? fillBehind(String text) {
        final button = tester.widget<OutlinedButton>(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(OutlinedButton),
          ),
        );
        return button.style?.backgroundColor?.resolve(const {});
      }

      await tester.pumpWidget(_host(_multi, _Signals()));
      await pickAndCheck(tester, ['Grind size']);

      // Compared in the same frame: an answer picked against one missed.
      expect(
        fillBehind('Water temperature'),
        isNot(fillBehind('Grind size')),
        reason:
            'a row whose only difference is a small tag makes the learner '
            'read every row to find the ones they missed',
      );
    });

    testWidgets('latches: nothing moves after the check', (tester) async {
      final signals = _Signals();
      await tester.pumpWidget(_host(_multi, signals));

      await pickAndCheck(tester, [
        'Grind size',
        'Water temperature',
        'Brew time',
      ]);
      // A second run at it must neither re-score nor re-open the card.
      await _tapText(tester, 'Mug colour');

      expect(signals.solved, 1, reason: 'a re-submit paid twice');
      expect(find.text('Check answers'), findsNothing);
      expect(_continueEnabled(tester), isTrue);
    });

    testWidgets('stays winnable whichever order a run draws', (tester) async {
      for (var nonce = 1; nonce <= 8; nonce++) {
        final signals = _Signals();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(_host(_multi, signals, nonce: nonce));
        await pickAndCheck(tester, [
          'Grind size',
          'Water temperature',
          'Brew time',
        ]);

        expect(signals.solved, 1, reason: 'unwinnable at nonce $nonce');
      }
    });
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
