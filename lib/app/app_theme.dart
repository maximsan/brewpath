import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';

/// App-wide Material 3 themes, one per mood.
///
/// Each theme carries its [MoodColors] as a `ThemeExtension`; that is what app
/// code reads, through `context.mood`. The [ColorScheme] below exists so stock
/// Material widgets (switches, dialogs, ink splashes) are not unstyled — no app
/// code reads it, because Material's names cannot carry the design's meanings.
abstract class AppTheme {
  /// The dark mood, and the app's default.
  static ThemeData get darkRoast =>
      _themeFor(MoodColors.darkRoast, Brightness.dark);

  /// The light mood.
  static ThemeData get cupping =>
      _themeFor(MoodColors.cupping, Brightness.light);

  static ThemeData _themeFor(MoodColors mood, Brightness brightness) =>
      ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: mood.bg,
        colorScheme: _schemeFor(mood, brightness),
        extensions: [mood],
        textTheme: AppText.textTheme(mood),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: mood.bg,
          foregroundColor: mood.ink,
        ),
        // The safety net under `showAppSheet`, not an alternative to it: this
        // carries the three things a theme can express, so a sheet opened by
        // any other route is at least not wearing stock Material colours. The
        // handle, insets, height cap, title and reduced motion live in the
        // function, which is the door to use.
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: mood.bg,
          modalBackgroundColor: mood.bg,
          modalBarrierColor: OverlayColors.dimModal,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.chrome),
            ),
          ),
        ),
      );

  /// Material's own palette, translated from the mood as faithfully as its
  /// vocabulary allows. The container slots repeat `accent` / `accentInk`
  /// because that is what they already resolved to via `ColorScheme`'s
  /// fallbacks — the design has no separate container tone.
  static ColorScheme _schemeFor(MoodColors mood, Brightness brightness) =>
      ColorScheme(
        brightness: brightness,
        primary: mood.accent,
        onPrimary: mood.accentInk,
        primaryContainer: mood.accent,
        onPrimaryContainer: mood.accentInk,
        secondary: mood.sage,
        onSecondary: mood.bg,
        error: mood.berry,
        onError: mood.accentInk,
        surface: mood.surface,
        onSurface: mood.ink,
        onSurfaceVariant: mood.inkMute,
        surfaceContainerLowest: mood.surface,
        surfaceContainerHigh: mood.surface,
        surfaceContainerHighest: mood.surface2,
        outline: mood.rule,
        outlineVariant: mood.rule,
      );
}
