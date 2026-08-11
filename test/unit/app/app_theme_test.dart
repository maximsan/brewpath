import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('each theme carries its own mood as a ThemeExtension', () {
      expect(
        AppTheme.darkRoast.extension<MoodColors>(),
        MoodColors.darkRoast,
      );
      expect(AppTheme.cupping.extension<MoodColors>(), MoodColors.cupping);
    });

    test('brightness matches the mood, not the old misnomer', () {
      expect(AppTheme.darkRoast.brightness, Brightness.dark);
      expect(AppTheme.cupping.brightness, Brightness.light);
    });

    test('the scaffold background is the mood canvas', () {
      expect(
        AppTheme.darkRoast.scaffoldBackgroundColor,
        MoodColors.darkRoast.bg,
      );
      expect(AppTheme.cupping.scaffoldBackgroundColor, MoodColors.cupping.bg);
    });

    test('ColorScheme is populated so Material widgets are not unstyled', () {
      const mood = MoodColors.darkRoast;
      final scheme = AppTheme.darkRoast.colorScheme;

      expect(scheme.primary, mood.accent);
      expect(scheme.onPrimary, mood.accentInk);
      expect(scheme.secondary, mood.sage);
      expect(scheme.error, mood.berry);
      expect(scheme.surface, mood.surface);
      expect(scheme.onSurface, mood.ink);
      expect(scheme.onSurfaceVariant, mood.inkMute);
      expect(scheme.surfaceContainerHighest, mood.surface2);
      expect(scheme.outline, mood.rule);
      // Previously fell through to `onBackground` (= ink), painting hairlines
      // in full-strength cream. It is the design's `--rule` now.
      expect(scheme.outlineVariant, mood.rule);
    });

    test('the scheme follows the mood it was built from', () {
      expect(AppTheme.cupping.colorScheme.primary, MoodColors.cupping.accent);
      expect(
        AppTheme.cupping.colorScheme.primary,
        isNot(AppTheme.darkRoast.colorScheme.primary),
      );
    });
  });
}
