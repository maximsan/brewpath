import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/fill_slot.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/lessons/domain/held_guess.dart';
import 'package:brew_path/features/lessons/presentation/cards/recall_payoff.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _right = HeldGuess(pick: 'Seed', answer: 'Seed');
const _missed = HeldGuess(pick: 'Skin', answer: 'Seed');

void main() {
  Future<void> pump(WidgetTester tester, HeldGuess guess) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(body: RecallPayoff(guess: guess)),
    ),
  );

  List<FillSlot> slots(WidgetTester tester) =>
      tester.widgetList<FillSlot>(find.byType(FillSlot)).toList();

  testWidgets('leads with the same label whichever way the guess went', (
    tester,
  ) async {
    for (final guess in [_right, _missed]) {
      await pump(tester, guess);
      expect(find.text(openingGuessLabel.toUpperCase()), findsOneWidget);
    }
  });

  testWidgets('a guess that landed shows one chip, marked right', (
    tester,
  ) async {
    await pump(tester, _right);

    expect(slots(tester), hasLength(1));
    expect(slots(tester).single.word, 'Seed');
    expect(slots(tester).single.state, FillSlotState.right);
  });

  testWidgets('a guess that missed shows it beside the answer', (tester) async {
    await pump(tester, _missed);

    expect(
      slots(tester).map((slot) => (slot.word, slot.state)),
      [('Skin', FillSlotState.wrong), ('Seed', FillSlotState.right)],
      reason: 'the guess and the truth, in that order, as the design reads it',
    );
  });

  testWidgets('draws no mascot — Roasty has already spoken above it', (
    tester,
  ) async {
    await pump(tester, _missed);

    expect(find.byType(Roasty), findsNothing);
  });

  testWidgets('does not interrupt the verdict it arrives beside', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, _missed);

    final announcing = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((node) => node.properties.liveRegion ?? false);

    expect(
      announcing,
      isEmpty,
      reason:
          'the payoff mounts on the same commit as the graded verdict above '
          'it, and two live regions firing together interrupt each other',
    );
    handle.dispose();
  });

  testWidgets('speaks the whole sentence, chips included', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, _missed);

    expect(
      find.bySemanticsLabel(
        "Before the lesson you guessed Skin. It's Seed — now you know why.",
      ),
      findsOneWidget,
      reason: 'a WidgetSpan announces nothing, so the words would be lost',
    );
    handle.dispose();
  });
}
