import 'package:brew_path/app/app.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

/// The two halves of the bar a theme cannot carry on its own: the words, and
/// the hairline that separates it from the page. Its colours and type are
/// asserted against the theme itself in `test/unit/app/tab_bar_theme_test.dart`.

Finder _tabLabel(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

MoodColors _renderedMood(WidgetTester tester) =>
    tester.element(find.byType(NavigationBar)).mood;

/// Every [Border] drawn by a box the bar sits inside.
Iterable<Border> _framesAround(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(
      find.ancestor(
        of: find.byType(NavigationBar),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((box) => box.decoration)
    .whereType<BoxDecoration>()
    .map((decoration) => decoration.border)
    .whereType<Border>();

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
        (frame) => frame.top.color == mood.rule && frame.top.width == 1,
      ),
      isTrue,
      reason: 'the design rules the bar off from the page it floats over',
    );
  });
}
