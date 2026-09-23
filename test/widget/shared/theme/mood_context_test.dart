// Where the mood tokens come from, and what happens when a tree has none: the
// app's two themes carry them, and anything else fails at once rather than
// painting one mood's tokens on the other mood's page.
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads the mood where it is built and hands it out.
class _MoodProbe extends StatelessWidget {
  const _MoodProbe(this.onRead);

  final void Function(MoodColors mood) onRead;

  @override
  Widget build(BuildContext context) {
    onRead(context.mood);
    return const SizedBox.shrink();
  }
}

Future<MoodColors?> _readMood(WidgetTester tester, {ThemeData? theme}) async {
  MoodColors? read;
  await tester.pumpWidget(
    MaterialApp(theme: theme, home: _MoodProbe((mood) => read = mood)),
  );
  // A theme change crossfades, and the mood mid-fade is a blend of both.
  await tester.pumpAndSettle();
  return read;
}

void main() {
  testWidgets('each app theme carries its own mood', (tester) async {
    expect(
      await _readMood(tester, theme: AppTheme.cupping),
      MoodColors.cupping,
    );
    expect(
      await _readMood(tester, theme: AppTheme.darkRoast),
      MoodColors.darkRoast,
    );
  });

  testWidgets('a theme with no mood fails a debug build, naming the way in', (
    tester,
  ) async {
    // The defect this pins: a bare MaterialApp used to fall back to Dark
    // Roast silently, so the tokens painted dark on Material's light page.
    await _readMood(tester);
    final error = tester.takeException();

    expect(error, isA<AssertionError>());
    expect('$error', contains('AppTheme.cupping'));
    expect('$error', contains('AppTheme.darkRoast'));
  });

  test('the release fallback is the mood of the theme’s own brightness', () {
    // What a release build reads in the same tree: a mood that agrees with
    // the page rather than one that contradicts it.
    expect(MoodColors.forBrightness(Brightness.light), MoodColors.cupping);
    expect(MoodColors.forBrightness(Brightness.dark), MoodColors.darkRoast);
  });

  testWidgets('the page and the tokens agree under either theme', (
    tester,
  ) async {
    for (final (theme, mood) in [
      (AppTheme.cupping, MoodColors.cupping),
      (AppTheme.darkRoast, MoodColors.darkRoast),
    ]) {
      await tester.pumpWidget(
        MaterialApp(theme: theme, home: const Scaffold()),
      );
      await tester.pumpAndSettle();

      final page = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(Scaffold),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(page.color, mood.bg, reason: 'the page is the mood’s own canvas');
    }
  });
}
