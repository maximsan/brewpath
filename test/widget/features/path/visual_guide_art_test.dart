import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/path/presentation/visual_guide_art.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every subject the bank ships.
const _subjects = [
  'roast',
  'grind',
  'extraction',
  'ratio',
  'anatomy',
  'variety',
  'caffeine',
  'distribution',
];

Widget _harness(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.cupping,
  home: Scaffold(body: child),
);

void main() {
  test('every subject has a drawing of its own', () {
    const mood = MoodColors.cupping;
    final marks = {
      for (final subject in _subjects) subject: guideMarkFor(subject, mood),
    };

    expect(
      marks.values.map((mark) => mark.runtimeType).toSet(),
      hasLength(_subjects.length),
      reason: 'two subjects sharing a painter is two guides that look alike',
    );
    expect(
      marks.values,
      isNot(contains(isA<FallbackMark>())),
      reason: 'a shipped subject falling back is art that never arrived',
    );
  });

  test('an unknown subject falls back rather than failing', () {
    expect(guideMarkFor('gooseneck', MoodColors.cupping), isA<FallbackMark>());
  });

  testWidgets('the same drawing serves both sizes', (tester) async {
    for (final size in VisualGuideArtSize.values) {
      await tester.pumpWidget(
        _harness(VisualGuideArt(subject: 'roast', size: size)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '$size');
      expect(
        tester.getSize(find.byType(VisualGuideArt)).height,
        size.side,
      );
    }
  });

  testWidgets('every drawing paints in both moods without throwing', (
    tester,
  ) async {
    for (final theme in [AppTheme.cupping, AppTheme.darkRoast]) {
      for (final subject in _subjects) {
        await tester.pumpWidget(
          _harness(
            VisualGuideArt(subject: subject, size: VisualGuideArtSize.sheet),
            theme: theme,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: subject);
      }
    }
  });

  testWidgets('a drawing is kept out of the semantics tree', (tester) async {
    await tester.pumpWidget(
      _harness(
        const VisualGuideArt(
          subject: 'anatomy',
          size: VisualGuideArtSize.row,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(VisualGuideArt),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a drawing repaints when the mood changes', (tester) async {
    const roast = 'roast';
    final cupping = guideMarkFor(roast, MoodColors.cupping);
    final dark = guideMarkFor(roast, MoodColors.darkRoast);

    expect(
      cupping.shouldRepaint(dark),
      isTrue,
      reason: 'a drawing that ignores the mood is one that reads wrong in it',
    );
    expect(
      cupping.shouldRepaint(guideMarkFor(roast, MoodColors.cupping)),
      isFalse,
    );
  });
}
