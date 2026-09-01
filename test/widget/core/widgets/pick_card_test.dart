// What a pick card does when it cannot be chosen. The distinction is the
// whole point: untappable and unavailable are not the same state, and the
// design draws them differently.
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/pick_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool selected,
  required VoidCallback? onTap,
}) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.cupping,
    home: Scaffold(
      body: PickCard(
        title: 'A deck',
        description: 'What it holds',
        selected: selected,
        onTap: onTap,
      ),
    ),
  ),
);

/// The wash the card drew over itself, or null when it drew none.
double? _wash(WidgetTester tester) {
  final washes = find.descendant(
    of: find.byType(PickCard),
    matching: find.byType(Opacity),
  );
  if (washes.evaluate().isEmpty) return null;
  return tester.widget<Opacity>(washes.first).opacity;
}

void main() {
  testWidgets('a card that can be chosen is drawn at full strength', (
    tester,
  ) async {
    await _pump(tester, selected: false, onTap: () {});

    expect(_wash(tester), isNull);
  });

  testWidgets('a card the rules cannot offer is dimmed', (tester) async {
    // A deck below its minimum, or a round length the pool cannot fill.
    await _pump(tester, selected: false, onTap: null);

    expect(_wash(tester), isNotNull);
    expect(_wash(tester), lessThan(1));
  });

  testWidgets('a selected card is never dimmed, even with nowhere to go', (
    tester,
  ) async {
    // The whole-deck card: `pick-card selected` at `cursor: default` in the
    // design, and never dimmed. It states what you get rather than refusing a
    // choice, and dimming it would read as unavailable.
    await _pump(tester, selected: true, onTap: null);

    expect(_wash(tester), isNull);
  });

  testWidgets('taps reach a card that can be chosen, and not one that cannot', (
    tester,
  ) async {
    var taps = 0;

    await _pump(tester, selected: false, onTap: () => taps++);
    await tester.tap(find.byType(PickCard));
    await tester.pumpAndSettle();
    expect(taps, 1);

    await _pump(tester, selected: false, onTap: null);
    await tester.tap(find.byType(PickCard));
    await tester.pumpAndSettle();
    expect(taps, 1, reason: 'a card the rules cannot offer must not latch');
  });

  testWidgets('an untappable card is not announced as a button', (
    tester,
  ) async {
    // The defect this replaced: `onTap: () {}` left the card dimmed but read
    // out as a working button, so a screen reader found a control that did
    // nothing when used.
    final semantics = tester.ensureSemantics();
    await _pump(tester, selected: false, onTap: null);

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && (widget.properties.button ?? false),
      ),
      findsNothing,
    );
    semantics.dispose();
  });
}
