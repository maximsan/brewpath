import 'package:brew_path/features/lessons/presentation/cards/match_board.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_board_view.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_lines_painter.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_tile.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _pairs = [
  MatchPair(left: 'Sweeter, more aromatic', right: 'Arabica'),
  MatchPair(left: 'Almost twice the caffeine', right: 'Robusta'),
];

/// Two traits that share one answer, which is what the deduped right column
/// is for: the board must draw both lines into the one tile.
const _fanned = [
  MatchPair(left: 'Sweeter, more aromatic', right: 'Arabica'),
  MatchPair(left: 'Grown high and slow', right: 'Arabica'),
  MatchPair(left: 'Almost twice the caffeine', right: 'Robusta'),
];

/// The widest board the shipped content actually has — four targets with long
/// labels, which is a lesson `match` card, not a mini-game one.
const _wideBoard = [
  MatchPair(left: 'Ethiopian naturals', right: 'Floral, citrus'),
  MatchPair(left: 'Classic Brazil', right: 'Balanced, caramel'),
  MatchPair(left: 'Aged Sumatra', right: 'Earthy, herbal'),
  MatchPair(left: 'Kenyan SL28', right: 'Blackcurrant, bright'),
];

Widget _host(
  List<MatchPair> pairs, {
  required VoidCallback onSolved,
  bool reducedMotion = false,
}) => ProviderScope(
  child: MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: Scaffold(
        body: SingleChildScrollView(
          child: MatchBoardView(
            prompt: 'Match each trait to its species',
            pairs: pairs,
            targets: matchTargets(pairs),
            onSolved: onSolved,
            onContinue: () {},
          ),
        ),
      ),
    ),
  ),
);

/// Pumps the renderer with no host around it — the point of it living in the
/// shared card layer is that it needs none.
Future<int> _pumpBoard(
  WidgetTester tester, {
  required List<(String fact, String target)> taps,
  List<MatchPair> pairs = _pairs,
}) async {
  var solved = 0;
  await tester.pumpWidget(_host(pairs, onSolved: () => solved++));

  for (final (fact, target) in taps) {
    await tester.tap(find.text(fact));
    await tester.pump();
    await tester.tap(find.text(target));
    await tester.pump();
  }
  return solved;
}

/// The connectors the board is painting right now.
List<MatchConnector> _lines(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((paint) => paint.painter)
    .whereType<MatchLinesPainter>()
    .single
    .connectors;

/// Drags [fact] onto [target] the way a learner does, and settles the board.
Future<void> _dragOnto(
  WidgetTester tester,
  String fact,
  String target,
) async {
  final from = tester.getCenter(find.text(fact));
  final onto = tester.getCenter(find.text(target));

  final gesture = await tester.startGesture(from);
  await tester.pump();
  await gesture.moveTo(onto);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('a four-target board lays out on a phone without overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(_wideBoard, onSolved: () {}));
    await tester.pump();

    expect(tester.takeException(), isNull);
    for (final pair in _wideBoard) {
      expect(find.text(pair.right), findsOneWidget);
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
    await tester.pumpAndSettle();
  });

  testWidgets('a wrong drop is announced and leaves the trait in play', (
    tester,
  ) async {
    await _pumpBoard(
      tester,
      taps: [('Sweeter, more aromatic', 'Robusta')],
    );

    expect(
      find.bySemanticsLabel(missAnnouncement),
      findsOneWidget,
      reason:
          'the design marks a miss in colour and motion alone, which is '
          'nothing to a learner who cannot see it',
    );
    // Still placeable: the board is finished by clearing it, not by surviving.
    expect(find.text('CLEAN BOARD'), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('the miss stops being marked once the design lets it go', (
    tester,
  ) async {
    await _pumpBoard(
      tester,
      taps: [('Sweeter, more aromatic', 'Robusta')],
    );

    expect(find.bySemanticsLabel(missAnnouncement), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(missAnnouncement), findsNothing);
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
    await tester.tap(find.text('Robusta'));
    await tester.pump();

    final open = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(open.onPressed, isNotNull);
  });

  group('dragging', () {
    testWidgets('a trait dragged onto its answer lands', (tester) async {
      var solved = 0;
      await tester.pumpWidget(_host(_pairs, onSolved: () => solved++));

      await _dragOnto(tester, 'Sweeter, more aromatic', 'Arabica');
      await _dragOnto(tester, 'Almost twice the caffeine', 'Robusta');
      await tester.pumpAndSettle();

      expect(solved, 1);
      expect(find.text('CLEAN BOARD'), findsOneWidget);
    });

    testWidgets('a trait dragged onto the wrong answer costs a drop', (
      tester,
    ) async {
      var solved = 0;
      await tester.pumpWidget(_host(_pairs, onSolved: () => solved++));

      await _dragOnto(tester, 'Sweeter, more aromatic', 'Robusta');
      expect(find.bySemanticsLabel(missAnnouncement), findsOneWidget);
      await tester.pumpAndSettle();

      await _dragOnto(tester, 'Sweeter, more aromatic', 'Arabica');
      await _dragOnto(tester, 'Almost twice the caffeine', 'Robusta');
      await tester.pumpAndSettle();

      expect(solved, 0);
      expect(find.text('1 WRONG DROP'), findsOneWidget);
    });

    testWidgets('the trait left behind is drawn as the slot it came out of', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_pairs, onSolved: () {}));

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Sweeter, more aromatic')),
      );
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.text('Arabica')));
      await tester.pump();

      final dashed = tester
          .widgetList<MatchTile>(find.byType(MatchTile))
          .where((tile) => tile.dragging);
      expect(dashed, hasLength(1));
      expect(find.byType(MatchDragGhost), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a drag that lands nowhere changes nothing', (tester) async {
      var solved = 0;
      await tester.pumpWidget(_host(_pairs, onSolved: () => solved++));

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Sweeter, more aromatic')),
      );
      await tester.pump();
      await gesture.moveTo(const Offset(5, 5));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(solved, 0);
      expect(find.bySemanticsLabel(missAnnouncement), findsNothing);
      expect(
        tester
            .widgetList<MatchTile>(find.byType(MatchTile))
            .where(
              (tile) => tile.dragging,
            ),
        isEmpty,
        reason:
            'a cancelled drag puts the trait back rather than leaving a '
            'dashed slot behind',
      );
    });
  });

  testWidgets('several traits fan into one deduped answer', (tester) async {
    final solved = await _pumpBoard(
      tester,
      pairs: _fanned,
      taps: [
        ('Sweeter, more aromatic', 'Arabica'),
        ('Grown high and slow', 'Arabica'),
        ('Almost twice the caffeine', 'Robusta'),
      ],
    );

    expect(solved, 1);
    expect(
      find.text('Arabica'),
      findsOneWidget,
      reason: 'the right column is the deduped set, so two traits share a tile',
    );
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion lands the connector whole in one frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(_pairs, onSolved: () {}, reducedMotion: true),
    );

    await tester.tap(find.text('Sweeter, more aromatic'));
    await tester.pump();
    await tester.tap(find.text('Arabica'));
    await tester.pump();

    final line = _lines(tester).single;
    expect(line.draw, 1, reason: 'the draw-in collapses');
    expect(line.arrow, 1, reason: 'so does the arrowhead behind its delay');
  });

  testWidgets('without reduced motion the connector draws itself in', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_pairs, onSolved: () {}));

    await tester.tap(find.text('Sweeter, more aromatic'));
    await tester.pump();
    await tester.tap(find.text('Arabica'));
    await tester.pump();

    final opening = _lines(tester).single;
    expect(opening.draw, lessThan(1));
    expect(opening.arrow, 0, reason: 'the head waits out its delay');

    await tester.pumpAndSettle();
    final settled = _lines(tester).single;
    expect(settled.draw, 1);
    expect(settled.arrow, 1);
  });

  testWidgets('a wrong drop draws its connector in berry, and not drawn in', (
    tester,
  ) async {
    await _pumpBoard(
      tester,
      taps: [('Sweeter, more aromatic', 'Robusta')],
    );

    final miss = _lines(tester).single;
    expect(
      miss.draw,
      1,
      reason:
          'the design does not animate a wrong line — it is already there '
          'when the shake starts',
    );
    expect(miss.arrow, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('every landed pair keeps its own connector', (tester) async {
    await _pumpBoard(
      tester,
      pairs: _fanned,
      taps: [
        ('Sweeter, more aromatic', 'Arabica'),
        ('Grown high and slow', 'Arabica'),
      ],
    );
    await tester.pumpAndSettle();

    final lines = _lines(tester);
    expect(lines, hasLength(2));
    expect(
      lines.map((line) => line.to).toSet(),
      hasLength(1),
      reason: 'both fan into the one deduped answer, so they share an end',
    );
  });
}
