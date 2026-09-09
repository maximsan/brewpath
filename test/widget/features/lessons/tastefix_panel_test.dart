import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_panel.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_reaction.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_symptoms.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _tags = ['SOUR', 'THIN'];
const _scenario = 'Grind is dialled in and the beans are fresh.';

void main() {
  Future<void> pump(
    WidgetTester tester,
    TastefixReaction reaction, {
    ThemeData? theme,
    bool reduceMotion = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.darkRoast,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          body: TastefixPanel(
            tags: _tags,
            scenario: _scenario,
            reaction: reaction,
          ),
        ),
      ),
    ),
  );

  Iterable<Text> chipTexts(WidgetTester tester) => tester.widgetList<Text>(
    find.descendant(
      of: find.byType(TastefixSymptoms),
      matching: find.byType(Text),
    ),
  );

  double shakeOf(WidgetTester tester) => tester
      .widgetList<Transform>(find.byType(Transform))
      .map((widget) => widget.transform.getTranslation().x)
      .firstWhere((offset) => offset != 0, orElse: () => 0);

  double scaleOf(WidgetTester tester) => tester
      .widgetList<Transform>(find.byType(Transform))
      .map((widget) => widget.transform.getMaxScaleOnAxis())
      .firstWhere((scale) => scale != 1, orElse: () => 1);

  group('the symptoms', () {
    testWidgets('are chips, not one joined line', (tester) async {
      await pump(tester, TastefixReaction.unfixed);

      expect(chipTexts(tester).map((text) => text.data), ['SOUR', 'THIN']);
      expect(find.text('SOUR · THIN'), findsNothing);
    });

    testWidgets('sit under TASTES, with the setup above them', (tester) async {
      await pump(tester, TastefixReaction.unfixed);

      expect(find.text('TASTES'), findsOneWidget);
      expect(find.text('STARTING POINT'), findsOneWidget);
      expect(find.text(_scenario), findsOneWidget);
    });

    testWidgets('dim when the fix failed to relieve them', (tester) async {
      await pump(tester, TastefixReaction.worsened);
      await tester.pumpAndSettle();

      final faded = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(faded, hasLength(_tags.length));
      for (final chip in faded) {
        expect(chip.opacity, tastefixDimmedOpacity);
      }
    });

    testWidgets('stay at full strength while nothing is committed', (
      tester,
    ) async {
      await pump(tester, TastefixReaction.unfixed);

      for (final chip in tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      )) {
        expect(chip.opacity, 1);
      }
    });
  });

  group('the balanced state', () {
    testWidgets('replaces the symptoms outright when the fix works', (
      tester,
    ) async {
      await pump(tester, TastefixReaction.relieved);
      await tester.pumpAndSettle();

      expect(find.text(tastefixBalancedLabel.toUpperCase()), findsOneWidget);
      for (final tag in _tags) {
        expect(find.text(tag), findsNothing, reason: '$tag outlived the fix');
      }
    });

    testWidgets('renames the panel and its row', (tester) async {
      await pump(tester, TastefixReaction.relieved);
      await tester.pumpAndSettle();

      expect(find.text('FIXED'), findsOneWidget);
      expect(find.text('RESULT'), findsOneWidget);
      expect(find.text('STARTING POINT'), findsNothing);
      expect(find.text('TASTES'), findsNothing);
    });
  });

  group('the reaction', () {
    testWidgets('shakes the panel once when the fix fails', (tester) async {
      await pump(tester, TastefixReaction.unfixed);
      await pump(tester, TastefixReaction.worsened);

      await tester.pump(const Duration(milliseconds: 120));
      expect(shakeOf(tester), isNot(0));

      await tester.pumpAndSettle();
      expect(shakeOf(tester), 0);
    });

    testWidgets('does not move again once the card has latched', (
      tester,
    ) async {
      await pump(tester, TastefixReaction.unfixed);
      await pump(tester, TastefixReaction.worsened);
      await tester.pumpAndSettle();

      // The latch means the same reaction is rebuilt, never a second one.
      await pump(tester, TastefixReaction.worsened);
      await tester.pump(const Duration(milliseconds: 120));

      expect(shakeOf(tester), 0);
    });

    testWidgets('pulses the panel once when the fix works', (tester) async {
      await pump(tester, TastefixReaction.unfixed);
      await pump(tester, TastefixReaction.relieved);

      await tester.pump(const Duration(milliseconds: 230));
      expect(scaleOf(tester), greaterThan(1));

      await tester.pumpAndSettle();
      expect(scaleOf(tester), 1);
    });

    testWidgets('rebuilding does not pile listeners on the controller', (
      tester,
    ) async {
      await pump(tester, TastefixReaction.unfixed);
      await pump(tester, TastefixReaction.worsened);

      // A curve minted per build would leave one behind on every frame of the
      // shake, and the ticker would outlive the card.
      for (var frame = 0; frame < 8; frame++) {
        await tester.pump(const Duration(milliseconds: 40));
      }
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());

      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion lands it in one frame', (tester) async {
      await pump(tester, TastefixReaction.unfixed, reduceMotion: true);
      await pump(tester, TastefixReaction.worsened, reduceMotion: true);

      // Deep enough in that an unguarded shake would be at its widest.
      await tester.pump(const Duration(milliseconds: 120));
      expect(shakeOf(tester), 0);
      for (final chip in tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      )) {
        expect(chip.opacity, tastefixDimmedOpacity);
        expect(chip.duration, Duration.zero);
      }
    });
  });

  group('assistive technology', () {
    testWidgets('is given the symptoms, and the state after a commit', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await pump(tester, TastefixReaction.unfixed);
      expect(find.bySemanticsLabel('Tastes: SOUR, THIN'), findsOneWidget);

      await pump(tester, TastefixReaction.relieved);
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Result: $tastefixBalancedLabel'),
        findsOneWidget,
      );

      handle.dispose();
    });
  });

  group('both moods', () {
    for (final (name, theme) in [
      ('Cupping', AppTheme.cupping),
      ('Dark Roast', AppTheme.darkRoast),
    ]) {
      testWidgets('$name draws the chips in the mood tokens', (tester) async {
        await pump(tester, TastefixReaction.unfixed, theme: theme);

        final mood = theme.extension<MoodColors>()!;
        final style = chipTexts(tester).first.style!;

        expect(style.color, mood.berry);
      });
    }
  });
}
