import 'package:brew_path/app/app.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

// The two halves of the bar a theme cannot carry on its own: the words, and
// the hairline that separates it from the page. Its colours and type are
// asserted against the theme itself in `test/unit/app/tab_bar_theme_test.dart`.

Finder _tabLabel(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

MoodColors _renderedMood(WidgetTester tester) =>
    tester.element(find.byType(NavigationBar)).mood;

/// Every box the bar sits inside that draws a [Border] — paired with the side
/// of the child it paints on, which is the difference between a rule the
/// learner sees and one the bar covers up.
Iterable<({Border frame, DecorationPosition position})> _framesAround(
  WidgetTester tester,
) => tester
    .widgetList<DecoratedBox>(
      find.ancestor(
        of: find.byType(NavigationBar),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((box) => (decoration: box.decoration, position: box.position))
    .where((box) => box.decoration is BoxDecoration)
    .map(
      (box) => (
        frame: (box.decoration as BoxDecoration).border,
        position: box.position,
      ),
    )
    .where((box) => box.frame is Border)
    .map((box) => (frame: box.frame! as Border, position: box.position));

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('names the four tabs the way the design does', (tester) async {
    await pumpWithProviders(tester, const BrewPathApp());

    for (final label in ['TODAY', 'PATH', 'CARDS', 'PROFILE']) {
      expect(_tabLabel(label), findsOneWidget);
    }
  });

  testWidgets('says TODAY where it used to say Learn', (tester) async {
    await pumpWithProviders(tester, const BrewPathApp());

    expect(_tabLabel('Learn'), findsNothing);
    expect(
      _tabLabel('TODAY'),
      findsOneWidget,
      reason:
          'the header eyebrow above it already said TODAY, so the tab was '
          'calling one destination two names on one screen',
    );
  });

  testWidgets('a hairline separates the bar from the page', (tester) async {
    await pumpWithProviders(tester, const BrewPathApp());
    final mood = _renderedMood(tester);

    expect(
      _framesAround(tester).any(
        (box) => box.frame.top.color == mood.rule && box.frame.top.width == 1,
      ),
      isTrue,
      reason: 'the design rules the bar off from the page it floats over',
    );
  });

  testWidgets('and the bar does not paint over its own hairline', (
    tester,
  ) async {
    await pumpWithProviders(tester, const BrewPathApp());
    final mood = _renderedMood(tester);

    final rules = _framesAround(
      tester,
    ).where((box) => box.frame.top.color == mood.rule).toList();

    expect(rules, isNotEmpty);
    expect(
      rules.map((box) => box.position),
      everyElement(DecorationPosition.foreground),
      reason:
          'NavigationBar fills its whole box with an opaque Material, and a '
          'background decoration paints behind its child without insetting '
          'it — so a rule drawn there is drawn and then buried',
    );
  });
}
