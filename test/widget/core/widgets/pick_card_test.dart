// What a pick card does when it cannot be chosen, and how it marks the one
// that is. The distinction is the whole point: untappable and unavailable are
// not the same state, and the design draws them differently.
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/pick_card.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool selected,
  required VoidCallback? onTap,
  ThemeData? theme,
  Widget? trailing,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: theme ?? AppTheme.cupping,
      home: Scaffold(
        body: PickCard(
          title: 'A deck',
          description: 'What it holds',
          selected: selected,
          onTap: onTap,
          trailing: trailing,
        ),
      ),
    ),
  );
  // MaterialApp crossfades a theme change, so a mood read before the fade
  // finishes is the colour halfway between the two moods.
  await tester.pumpAndSettle();
}

/// The edge the card drew — the design's border, whatever its width.
BorderSide _edge(WidgetTester tester) {
  final box = find.descendant(
    of: find.byType(PickCard),
    matching: find.byWidgetPredicate(
      (widget) => widget is Container && widget.decoration is BoxDecoration,
    ),
  );
  final decoration =
      tester.widget<Container>(box.first).decoration! as BoxDecoration;
  return decoration.border!.top;
}

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

  testWidgets('selection is a doubled accent edge, in either mood', (
    tester,
  ) async {
    for (final (theme, mood) in [
      (AppTheme.cupping, MoodColors.cupping),
      (AppTheme.darkRoast, MoodColors.darkRoast),
    ]) {
      await _pump(tester, selected: false, onTap: () {}, theme: theme);
      expect(_edge(tester).color, mood.rule);
      expect(_edge(tester).width, 1);

      await _pump(tester, selected: true, onTap: () {}, theme: theme);
      expect(_edge(tester).color, mood.accent);
      expect(
        _edge(tester).width,
        2,
        reason: 'the design borders 1px and adds `inset 0 0 0 1px accent`',
      );
    }
  });

  testWidgets('no indicator is drawn, selected or not', (tester) async {
    // The defect this replaced: a 28 ring with a 14 filled dot, which is a
    // fill — the one thing the design's selection rule forbids.
    for (final selected in [false, true]) {
      await _pump(tester, selected: selected, onTap: () {});

      expect(
        find.descendant(of: find.byType(PickCard), matching: find.byType(Row)),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
        findsNothing,
      );
    }
  });

  testWidgets('the trailing slot is the right column, and empty by default', (
    tester,
  ) async {
    await _pump(tester, selected: false, onTap: () {});
    expect(find.text('24'), findsNothing);

    await _pump(
      tester,
      selected: false,
      onTap: () {},
      trailing: const Text('24'),
    );
    expect(
      tester.getCenter(find.text('24')).dx,
      greaterThan(tester.getCenter(find.text('A deck')).dx),
    );
  });

  testWidgets('the card takes the design padding and radius', (tester) async {
    await _pump(tester, selected: false, onTap: () {});

    final box = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(PickCard),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container && widget.decoration is BoxDecoration,
            ),
          )
          .first,
    );
    expect(
      box.padding,
      EdgeInsets.all(OffTokens.pickCardPadding.value),
      reason: '`.pick-card` sets `padding: 20px`',
    );
    expect(
      (box.decoration! as BoxDecoration).borderRadius,
      BorderRadius.circular(AppRadii.chrome),
      reason: '`.pick-card` sets `border-radius: var(--r)`',
    );
  });

  testWidgets('a centred card stacks its title over its description', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.cupping,
        home: const Scaffold(
          body: PickCard.centred(
            title: '12',
            description: 'Deep',
            selected: true,
            onTap: null,
          ),
        ),
      ),
    );

    expect(
      find.descendant(of: find.byType(PickCard), matching: find.byType(Row)),
      findsNothing,
    );
    expect(
      tester.getCenter(find.text('12')).dx,
      moreOrLessEquals(tester.getCenter(find.text('Deep')).dx),
    );
    expect(_edge(tester).color, MoodColors.cupping.accent);
  });
}
