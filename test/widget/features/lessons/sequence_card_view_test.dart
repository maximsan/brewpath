import 'package:brew_path/features/lessons/presentation/cards/sequence_card_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/sequence_step_number.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A shipped round, handed to the card in a display order that is not the
/// answer — which is what the host always does. Its authored order is
/// Pick → Process → Roast → Grind → Brew.
const _shown = [
  SequenceItem(label: 'Roast', order: 3),
  SequenceItem(label: 'Brew', order: 5),
  SequenceItem(label: 'Pick the cherry', order: 1),
  SequenceItem(label: 'Grind', order: 4),
  SequenceItem(label: 'Process and dry', order: 2),
];

const _authoredOrder = [
  'Pick the cherry',
  'Process and dry',
  'Roast',
  'Grind',
  'Brew',
];

class _Signals {
  int solved = 0;
  int continued = 0;
}

/// Pumps the renderer with no host around it — the point of it living in the
/// shared card layer is that it needs none.
Future<void> _pumpCard(WidgetTester tester, _Signals signals) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SequenceCardView(
            prompt: 'Order the journey from farm to cup',
            items: _shown,
            onSolved: () => signals.solved++,
            onContinue: () => signals.continued++,
          ),
        ),
      ),
    ),
  );
}

Future<void> _tapSteps(WidgetTester tester, List<String> labels) async {
  for (final label in labels) {
    await tester.tap(find.text(label));
    await tester.pump();
  }
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
  await tester.pump();
}

/// The numbers currently shown in the step badges, in display order.
List<String> _badges(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(find.byType(Text)))
    if (text.data != null && RegExp(r'^[1-9]$').hasMatch(text.data!))
      text.data!,
];

/// The number shown on [label]'s own badge, or empty while it has none.
///
/// Read off the row rather than off the column of badges, because the badges
/// sit in *display* order and the run is in tap order — the two are different
/// lists on purpose, and reading one for the other is the mistake this helper
/// exists to make impossible.
String _badgeFor(WidgetTester tester, String label) {
  final row = find
      .ancestor(of: find.text(label), matching: find.byType(Row))
      .first;
  final badge = find.descendant(
    of: row,
    matching: find.byType(SequenceStepNumber),
  );
  return tester
          .widget<Text>(find.descendant(of: badge, matching: find.byType(Text)))
          .data ??
      '';
}

void main() {
  testWidgets('opens unnumbered, with the steps in the order it was given', (
    tester,
  ) async {
    await _pumpCard(tester, _Signals());

    for (final item in _shown) {
      expect(find.text(item.label), findsOneWidget);
    }
    expect(_badges(tester), isEmpty, reason: 'nothing is placed on arrival');
  });

  testWidgets('nothing can be submitted until every step is placed', (
    tester,
  ) async {
    await _pumpCard(tester, _Signals());
    await _tapSteps(tester, ['Pick the cherry', 'Process and dry']);

    final gated = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Submit'),
    );
    expect(
      gated.onPressed,
      isNull,
      reason: 'a card answered by a whole sequence cannot take a prefix',
    );
  });

  testWidgets('tapping numbers a step, and tapping again takes it back out', (
    tester,
  ) async {
    await _pumpCard(tester, _Signals());
    await _tapSteps(tester, ['Pick the cherry', 'Process and dry', 'Roast']);

    expect(_badgeFor(tester, 'Pick the cherry'), '1');
    expect(_badgeFor(tester, 'Process and dry'), '2');
    expect(_badgeFor(tester, 'Roast'), '3');
    expect(_badgeFor(tester, 'Brew'), '');

    // Pulling the middle one out renumbers what is left rather than leaving a
    // hole — the whole reason a tap toggles.
    await _tapSteps(tester, ['Process and dry']);

    expect(_badgeFor(tester, 'Pick the cherry'), '1');
    expect(_badgeFor(tester, 'Process and dry'), '');
    expect(_badgeFor(tester, 'Roast'), '2');
  });

  testWidgets('the authored order pays exactly one success signal', (
    tester,
  ) async {
    final signals = _Signals();
    await _pumpCard(tester, signals);

    await _tapSteps(tester, _authoredOrder);
    await _submit(tester);

    expect(signals.solved, 1);
    expect(find.text('IN ORDER'), findsOneWidget);
  });

  testWidgets('any other order pays nothing and says where each step went', (
    tester,
  ) async {
    final signals = _Signals();
    await _pumpCard(tester, signals);

    // Roast and Grind swapped; the other three are where they belong.
    await _tapSteps(tester, [
      'Pick the cherry',
      'Process and dry',
      'Grind',
      'Roast',
      'Brew',
    ]);
    await _submit(tester);

    expect(signals.solved, 0);
    expect(find.text('NOT QUITE'), findsOneWidget);
    expect(find.text('GOES #4'), findsOneWidget);
    expect(find.text('GOES #3'), findsOneWidget);
  });

  testWidgets('a wrong run reveals the order it should have been', (
    tester,
  ) async {
    await _pumpCard(tester, _Signals());

    await _tapSteps(tester, _authoredOrder.reversed.toList());
    await _submit(tester);

    expect(find.text('CORRECT ORDER'), findsOneWidget);
    expect(find.text(_authoredOrder.join('  →  ')), findsOneWidget);
  });

  testWidgets('the run latches — steps freeze and cannot re-score', (
    tester,
  ) async {
    final signals = _Signals();
    await _pumpCard(tester, signals);

    await _tapSteps(tester, _authoredOrder.reversed.toList());
    await _submit(tester);
    // A second run at it: clear the board and lay it out correctly.
    await _tapSteps(tester, _authoredOrder);

    expect(signals.solved, 0);
    expect(find.widgetWithText(FilledButton, 'Submit'), findsNothing);
  });

  testWidgets('reset clears the run while it is still open, then goes', (
    tester,
  ) async {
    await _pumpCard(tester, _Signals());

    expect(
      find.text('Reset'),
      findsNothing,
      reason: 'there is nothing to reset until the run is finished',
    );

    await _tapSteps(tester, _authoredOrder);
    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(_badges(tester), isEmpty);
    expect(find.text('Reset'), findsNothing);
  });

  testWidgets('continue is gated on the commit, not on being right', (
    tester,
  ) async {
    final signals = _Signals();
    await _pumpCard(tester, signals);

    // The shell swaps one button rather than drawing two, so before the commit
    // there is no way forward at all.
    expect(find.widgetWithText(FilledButton, 'Continue'), findsNothing);

    await _tapSteps(tester, _authoredOrder.reversed.toList());
    await _submit(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));

    expect(
      signals.continued,
      1,
      reason: 'moving on is moving on, whatever the learner scored',
    );
  });

  testWidgets('a step says its place, and the verdict is announced', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpCard(tester, _Signals());

    await _tapSteps(tester, [
      'Pick the cherry',
      'Process and dry',
      'Grind',
      'Roast',
      'Brew',
    ]);
    await _submit(tester);

    expect(
      find.bySemanticsLabel('Pick the cherry, position 1, correct'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Grind, position 3, belongs at 4'),
      findsOneWidget,
      reason: 'the mark is carried by colour alone unless it is spoken',
    );
    expect(find.bySemanticsLabel('NOT QUITE'), findsOneWidget);
    handle.dispose();
  });
}
