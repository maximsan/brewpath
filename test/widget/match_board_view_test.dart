import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_board_view.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pairs = [
  MatchPair(left: 'Sweeter, more aromatic', right: 'Arabica'),
  MatchPair(left: 'Almost twice the caffeine', right: 'Robusta'),
];

/// Pumps the renderer with no host around it — the point of it living in the
/// shared card layer is that it needs none.
Future<int> _pumpBoard(
  WidgetTester tester, {
  required List<(String fact, String target)> taps,
}) async {
  var solved = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MatchBoardView(
          prompt: 'Match each trait to its species',
          pairs: _pairs,
          targets: matchTargets(_pairs),
          onSolved: () => solved++,
          onContinue: () {},
        ),
      ),
    ),
  );

  for (final (fact, target) in taps) {
    await tester.tap(find.text(fact));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, target));
    await tester.pump();
  }
  return solved;
}

/// The widest board the shipped content actually has — four targets with long
/// labels, which is a lesson `match` card, not a mini-game one.
const _wideBoard = [
  MatchPair(left: 'Ethiopian naturals', right: 'Floral, citrus'),
  MatchPair(left: 'Classic Brazil', right: 'Balanced, caramel'),
  MatchPair(left: 'Aged Sumatra', right: 'Earthy, herbal'),
  MatchPair(left: 'Kenyan SL28', right: 'Blackcurrant, bright'),
];

void main() {
  testWidgets('a four-target board lays out on a phone without overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MatchBoardView(
              prompt: 'Match each origin to its profile',
              pairs: _wideBoard,
              targets: matchTargets(_wideBoard),
              onSolved: () {},
              onContinue: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    for (final pair in _wideBoard) {
      expect(find.widgetWithText(OutlinedButton, pair.right), findsOneWidget);
    }
  });

  testWidgets('a clean board pays exactly one success signal', (tester) async {
    final solved = await _pumpBoard(
      tester,
      taps: [
        ('Sweeter, more aromatic', 'Arabica'),
        ('Almost twice the caffeine', 'Robusta'),
      ],
    );

    expect(solved, 1);
    expect(find.text('CLEAN BOARD'), findsOneWidget);
  });

  // The rule this card exists for: the board still finishes, and still pays
  // nothing.
  testWidgets('a board finished after a wrong drop pays nothing', (
    tester,
  ) async {
    final solved = await _pumpBoard(
      tester,
      taps: [
        ('Sweeter, more aromatic', 'Robusta'),
        ('Sweeter, more aromatic', 'Arabica'),
        ('Almost twice the caffeine', 'Robusta'),
      ],
    );

    expect(solved, 0);
    expect(find.text('1 WRONG DROP'), findsOneWidget);
  });

  testWidgets('a wrong drop reacts in-card and leaves the fact in play', (
    tester,
  ) async {
    await _pumpBoard(
      tester,
      taps: [('Sweeter, more aromatic', 'Robusta')],
    );

    expect(find.text('Not that one — try it somewhere else.'), findsOneWidget);
    // Still placeable: the board is finished by clearing it, not by surviving.
    expect(find.text('Clean board.'), findsNothing);
  });

  testWidgets('continue is gated until the board clears', (tester) async {
    await _pumpBoard(
      tester,
      taps: [('Sweeter, more aromatic', 'Arabica')],
    );

    final gated = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(gated.onPressed, isNull);

    await tester.tap(find.text('Almost twice the caffeine'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Robusta'));
    await tester.pump();

    final open = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(open.onPressed, isNotNull);
  });
}
