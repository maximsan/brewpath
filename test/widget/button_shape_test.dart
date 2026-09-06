import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design's buttons take `--r` — [AppRadii.chrome] — and Material's default
/// is a stadium pill. The app declared no button theme, so every bare button
/// resolved to the pill; the rule lived only inside `PrimaryButton`, which six
/// screens bypassed (#377).
///
/// **Chrome, not editorial.** The design-system catalogue sets `.btn-primary`
/// to 2px and the running prototype sets it to `var(--r)`; ADR-0009 ranks the
/// running prototype above the catalogue. Pinned here so the app cannot drift
/// back to the value the catalogue states.
///
/// Asserted on **bare** buttons on purpose. A test that styles the button it
/// checks proves only that a test can set a shape. The claim here is that a
/// developer writing `FilledButton(...)` with no style gets the design without
/// knowing the rule — so what is inspected is the `Material` the button
/// actually paints, not the style it was handed.
ShapeBorder _paintedShape(WidgetTester tester, Finder button) {
  // The first `Material` under a button is not always the one that paints it —
  // `SegmentedButton` wraps its segments in a shapeless container first — so
  // take the first that actually carries a shape.
  final materials = tester.widgetList<Material>(
    find.descendant(of: button, matching: find.byType(Material)),
  );
  return materials.firstWhere((material) => material.shape != null).shape!;
}

Future<void> _pump(WidgetTester tester, ThemeData theme, Widget button) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: Center(child: button)),
    ),
  );
}

void main() {
  final themes = {
    'Cupping': AppTheme.cupping,
    'Dark Roast': AppTheme.darkRoast,
  };

  Map<String, Widget> bareButtons() => {
    'FilledButton': FilledButton(onPressed: () {}, child: const Text('x')),
    'FilledButton.tonal': FilledButton.tonal(
      onPressed: () {},
      child: const Text('x'),
    ),
    'OutlinedButton': OutlinedButton(onPressed: () {}, child: const Text('x')),
    'TextButton': TextButton(onPressed: () {}, child: const Text('x')),
    'ElevatedButton': ElevatedButton(onPressed: () {}, child: const Text('x')),
  };

  testWidgets('PrimaryButton keeps its shape without the app theme', (
    tester,
  ) async {
    // `PrimaryButton` sets the radius itself as well as taking it from the
    // theme. This is why: `context.mood` falls back to Dark Roast when no
    // theme carries the extension, so the component renders in a themeless
    // `MaterialApp` — and without its own shape it would render there as
    // Material's pill. Both read `AppRadii.chrome`, so the two cannot drift.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'x', onPressed: () {}),
        ),
      ),
    );

    final shape = _paintedShape(tester, find.byType(PrimaryButton));
    expect(shape, isNot(isA<StadiumBorder>()));
    expect(
      (shape as RoundedRectangleBorder).borderRadius.resolve(
        TextDirection.ltr,
      ),
      BorderRadius.circular(AppRadii.chrome),
    );
  });

  for (final theme in themes.entries) {
    for (final entry in bareButtons().entries) {
      // `.btn-link` draws no body and the design gives it no radius, so a text
      // button takes the sharp end rather than `--r`. It still needs a shape,
      // or Material's pill shows through on press.
      final expected = entry.key == 'TextButton'
          ? AppRadii.editorial
          : AppRadii.chrome;

      testWidgets('${entry.key} is not a pill in ${theme.key}', (tester) async {
        await _pump(tester, theme.value, entry.value);

        final shape = _paintedShape(
          tester,
          find.byType(entry.value.runtimeType),
        );

        expect(
          shape,
          isNot(isA<StadiumBorder>()),
          reason: "${entry.key} still paints Material's pill",
        );
        expect(
          (shape as RoundedRectangleBorder).borderRadius.resolve(
            TextDirection.ltr,
          ),
          BorderRadius.circular(expected),
          reason: 'the running prototype sets this button at $expected',
        );
      });
    }

    test('${theme.key} declares the segmented toggle as a pill', () {
      // The one exception, and it is the design's: the filter toggle is drawn
      // at `borderRadius: 999`, which `AppRadii.pill`
      // names for toggles in as many words.
      //
      // Asserted on the *declaration* rather than the painted shape, unlike
      // every case above. Material already drew this one as a pill by default,
      // so painting proves nothing about the app's intent — what changed is
      // that the app now says so, and that is what stops the rule above being
      // applied here by someone tidying.
      expect(
        theme.value.segmentedButtonTheme.style?.shape?.resolve({}),
        isA<StadiumBorder>(),
      );
    });
  }

  testWidgets('a call site that asks for its own shape still wins', (
    tester,
  ) async {
    // The theme is a default, not a mandate: a component that genuinely needs
    // its own radius keeps it.
    await _pump(
      tester,
      AppTheme.cupping,
      OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.editorial),
          ),
        ),
        child: const Text('x'),
      ),
    );

    final shape = _paintedShape(tester, find.byType(OutlinedButton));
    expect(
      (shape as RoundedRectangleBorder).borderRadius.resolve(
        TextDirection.ltr,
      ),
      BorderRadius.circular(AppRadii.editorial),
    );
  });
}
