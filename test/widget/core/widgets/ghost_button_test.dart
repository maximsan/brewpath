import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design's `.btn-ghost`: `background: transparent`, `1px var(--rule)`,
/// `color: var(--ink)`, `border-radius: var(--r)`, `width: 100%`.
///
/// Asserted on what the button *paints* rather than the style it was handed,
/// for the reason `button_shape_test.dart` gives: a test that reads back its
/// own input proves only that a style object holds values.
RoundedRectangleBorder _paintedShape(WidgetTester tester) {
  final materials = tester.widgetList<Material>(
    find.descendant(
      of: find.byType(GhostButton),
      matching: find.byType(Material),
    ),
  );
  return materials.firstWhere((material) => material.shape != null).shape!
      as RoundedRectangleBorder;
}

Material _paintedMaterial(WidgetTester tester) => tester
    .widgetList<Material>(
      find.descendant(
        of: find.byType(GhostButton),
        matching: find.byType(Material),
      ),
    )
    .firstWhere((material) => material.shape != null);

void main() {
  final moods = {
    'Cupping': (AppTheme.cupping, MoodColors.cupping),
    'Dark Roast': (AppTheme.darkRoast, MoodColors.darkRoast),
  };

  Future<void> pump(
    WidgetTester tester,
    ThemeData theme, {
    VoidCallback? onPressed,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: GhostButton(label: 'Skip', onPressed: onPressed),
        ),
      ),
    ),
  );

  for (final entry in moods.entries) {
    final (theme, mood) = entry.value;

    group(entry.key, () {
      testWidgets('is a hairline on nothing, not a filled button', (
        tester,
      ) async {
        await pump(tester, theme, onPressed: () {});

        final material = _paintedMaterial(tester);
        expect(
          material.color,
          Colors.transparent,
          reason:
              'a ghost lets the page through; that is what makes it a ghost',
        );
        expect(_paintedShape(tester).side.color, mood.rule);
        expect(_paintedShape(tester).side.width, 1);
      });

      testWidgets("takes the design's one radius, not a pill", (tester) async {
        await pump(tester, theme, onPressed: () {});

        final shape = _paintedShape(tester);
        expect(shape, isNot(isA<StadiumBorder>()));
        expect(
          shape.borderRadius.resolve(TextDirection.ltr),
          BorderRadius.circular(AppRadii.chrome),
        );
      });

      testWidgets('letters its label in ink', (tester) async {
        await pump(tester, theme, onPressed: () {});

        expect(tester.widget<Text>(find.text('Skip')).style?.color, mood.ink);
      });

      testWidgets('mutes the label when disabled, and keeps the hairline', (
        tester,
      ) async {
        await pump(tester, theme);

        expect(
          tester.widget<Text>(find.text('Skip')).style?.color,
          mood.inkMute,
          reason: "the design's 35% fade is invisible on the dark ground",
        );
        expect(
          _paintedShape(tester).side.color,
          mood.rule,
          reason: 'a disabled ghost is still visibly a button',
        );
      });
    });
  }

  testWidgets('stacks under a primary at the same width and height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: Column(
            children: [
              PrimaryButton(label: 'Continue', onPressed: () {}),
              GhostButton(label: 'Skip', onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(GhostButton)),
      tester.getSize(find.byType(PrimaryButton)),
      reason: 'a shorter second button reads as a different kind of control',
    );
  });

  testWidgets('keeps its shape without the app theme', (tester) async {
    // Same guarantee `PrimaryButton` carries: `context.mood` falls back to
    // Dark Roast, so this renders in a themeless `MaterialApp` — and without
    // its own shape it would render there as Material's pill.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GhostButton(label: 'Skip', onPressed: () {}),
        ),
      ),
    );

    expect(_paintedShape(tester), isNot(isA<StadiumBorder>()));
    expect(
      _paintedShape(tester).borderRadius.resolve(TextDirection.ltr),
      BorderRadius.circular(AppRadii.chrome),
    );
  });
}
