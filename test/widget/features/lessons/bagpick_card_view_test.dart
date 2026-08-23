import 'package:brew_path/features/lessons/presentation/cards/bagpick_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/bagpick_cue_row.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/green_bean.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _card = BagpickCard(
  bag: 'BAG 01',
  origin: 'Ethiopia · 1,900 m',
  prompt: 'How was this lot processed?',
  bean: BagpickBean(
    body: 'var(--art-cherry-seed)',
    crease: '#F0E9D9',
    mottle: 0,
    chaff: false,
  ),
  options: ['washed', 'natural'],
  answer: 'washed',
  tell: 'cut',
  cues: [
    BagpickCue(id: 'colour', label: 'Colour', text: 'Even blue-green.'),
    BagpickCue(id: 'cut', label: 'Centre cut', text: 'A clean, pale line.'),
    BagpickCue(id: 'aroma', label: 'Aroma', text: 'Dry and grassy.'),
  ],
  explanation: 'Depulped and fermented clean within hours.',
);

/// Pumps the renderer with no host around it — the point of it living in the
/// shared card layer is that it needs none.
Future<int Function()> _pump(WidgetTester tester) async {
  var solved = 0;
  tester.view.physicalSize = const Size(600, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BagpickCardView(
            card: _card,
            options: const ['washed', 'natural'],
            onSolved: () => solved++,
            onContinue: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return () => solved;
}

/// The option row, not the bag's process pill — once a call is made the two
/// carry the same word.
Finder _option(String label) => find.descendant(
  of: find.byType(ChoiceList),
  matching: find.text(label),
);

void main() {
  testWidgets('the sample is three beans, and the bag keeps its secret', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(GreenBean), findsNWidgets(3));
    expect(find.text('BAG 01'), findsOneWidget);
    expect(find.text('Process hidden'), findsOneWidget);
    expect(
      _option('Washed'),
      findsOneWidget,
      reason: 'the option is there; the answer pill is not',
    );
  });

  testWidgets('a cue says nothing until it is inspected', (tester) async {
    await _pump(tester);

    expect(find.text('Tap to inspect'), findsNWidgets(3));
    expect(find.text('A clean, pale line.'), findsNothing);

    await tester.tap(find.text('Tap to inspect').first);
    await tester.pumpAndSettle();

    expect(find.text('Even blue-green.'), findsOneWidget);
    expect(
      find.text('Tap to inspect'),
      findsNWidgets(2),
      reason: 'inspecting one cue must not uncover the others',
    );
  });

  testWidgets('a closed cue looks closed, before its words are read', (
    tester,
  ) async {
    await _pump(tester);

    Decoration decorationOf(int index) => tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(BagpickCueRow),
            matching: find.byType(Container),
          ),
        )
        .elementAt(index)
        .decoration!;

    final closed = decorationOf(0);
    await tester.tap(find.text('Tap to inspect').first);
    await tester.pumpAndSettle();

    expect(
      decorationOf(0),
      isNot(closed),
      reason:
          'a row whose only difference is its text makes the learner read '
          'every row to find the unread ones',
    );
  });

  testWidgets('the verdict is coloured by outcome, not only worded', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(_option('Natural'));
    await tester.pumpAndSettle();
    final wrong = tester.widget<Text>(find.text('Washed, actually.'));

    // Tear the tree down first: a bare re-pump reuses the same State, so the
    // card would still be latched on the wrong call and never reach the right
    // one.
    await tester.pumpWidget(const SizedBox.shrink());
    await _pump(tester);
    await tester.tap(_option('Washed'));
    await tester.pumpAndSettle();
    final right = tester.widget<Text>(find.text('Called it.'));

    expect(
      right.style?.color,
      isNot(wrong.style?.color),
      reason: 'scanning back over a run, wording alone is easy to miss',
    );
  });

  testWidgets('calling it right reports success exactly once', (tester) async {
    final solved = await _pump(tester);

    await tester.tap(_option('Washed'));
    await tester.pumpAndSettle();

    expect(solved(), 1);
  });

  testWidgets('calling it wrong reports nothing and names the answer', (
    tester,
  ) async {
    final solved = await _pump(tester);

    await tester.tap(_option('Natural'));
    await tester.pumpAndSettle();

    expect(solved(), 0);
    expect(find.text('Washed, actually.'), findsOneWidget);
    expect(find.text(_card.explanation), findsOneWidget);
  });

  testWidgets('the call latches — a second tap changes nothing', (
    tester,
  ) async {
    final solved = await _pump(tester);

    await tester.tap(_option('Natural'));
    await tester.pumpAndSettle();
    await tester.tap(_option('Washed'));
    await tester.pumpAndSettle();

    expect(solved(), 0, reason: 'a latched card cannot be answered again');
    expect(find.text('Washed, actually.'), findsOneWidget);
  });

  testWidgets('committing opens every cue and marks the tell', (tester) async {
    await _pump(tester);

    await tester.tap(_option('Washed'));
    await tester.pumpAndSettle();

    expect(find.text('Tap to inspect'), findsNothing);
    expect(find.text('Even blue-green.'), findsOneWidget);
    expect(find.text('A clean, pale line.'), findsOneWidget);
    expect(find.text('Dry and grassy.'), findsOneWidget);
  });

  testWidgets('the tell is announced to a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);

    expect(
      find.bySemanticsLabel(RegExp('Centre cut. Not yet inspected')),
      findsOneWidget,
    );

    await tester.tap(_option('Washed'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('Centre cut.*The tell')),
      findsOneWidget,
      reason: 'which cue gave it away is the lesson, not decoration',
    );
    handle.dispose();
  });

  testWidgets('the bag names its process once the call is made', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(_option('Washed'));
    await tester.pumpAndSettle();

    expect(find.text('Process hidden'), findsNothing);
    expect(find.text('Washed'), findsNWidgets(2));
  });

  testWidgets('continue is gated until the card is answered', (tester) async {
    await _pump(tester);

    final before = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(before.onPressed, isNull);

    await tester.tap(_option('Washed'));
    await tester.pumpAndSettle();

    final after = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(after.onPressed, isNotNull);
  });
}
