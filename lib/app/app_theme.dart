import 'package:brew_path/app/tab_bar_theme.dart';
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
        // Every inactive icon is muted ink — the design says so in the token's
        // own description. Left unset, Material hands glyphs white or black87,
        // which is off-palette in both moods and which `IconMark` would then
        // inherit for want of anything better.
        iconTheme: IconThemeData(color: mood.inkMute),
        navigationBarTheme: tabBarTheme(mood),
        // Buttons take `--r`, the design's one radius token, where Material
        // defaults to a stadium pill. Declared here rather than at each call
        // site so a bare `FilledButton` is correct by construction: the app
        // shipped fourteen of them wearing the pill because the rule lived
        // only inside `PrimaryButton`, which six screens bypassed (#377).
        //
        // Shape only. Height and full width belong to `PrimaryButton`, which
        // is the *primary CTA*, not every button — theming those here would
        // stretch the lesson card's Continue and the sheets' actions to a
        // page-wide 52px bar.
        filledButtonTheme: const FilledButtonThemeData(style: _solidButton),
        outlinedButtonTheme: const OutlinedButtonThemeData(style: _solidButton),
        elevatedButtonTheme: const ElevatedButtonThemeData(style: _solidButton),
        textButtonTheme: const TextButtonThemeData(style: _linkButton),
        // The one button the design *does* draw as a pill, so it is declared
        // rather than left to Material's default happening to agree.
        segmentedButtonTheme: const SegmentedButtonThemeData(
          style: _segmentedButton,
        ),
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
        //
        // It is also the one place the dim's colour is taken without its blur,
        // because `BottomSheetThemeData` has no field for a filter. That is the
        // whole reason `showAppSheet` pushes its own route — a sheet that came
        // through the theme alone would be dimmed and unblurred (#379).
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: mood.bg,
          modalBackgroundColor: mood.bg,
          modalBarrierColor: OverlayColors.dimModal.color,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.chrome),
            ),
          ),
        ),
      );

  /// The shape a button with a body takes — `.btn-primary`, `.btn-ghost`.
  ///
  /// [AppRadii.chrome], not [AppRadii.editorial]. `Design System.html` sets
  /// `.btn-primary` to 2px and the running `index.html` sets it to `var(--r)`;
  /// ADR-0009 rules the running prototype wins, and this is the same
  /// disagreement it already resolved for `.mcq-choice` and `.match-item`.
  /// Buttons were missed in that sweep.
  static const ButtonStyle _solidButton = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.chrome)),
      ),
    ),
  );

  /// The shape a text button takes — `.btn-link`, which draws no body.
  ///
  /// Editorial rather than chrome: the design gives `.btn-link` **no** radius
  /// at all (`index.html:283`), so rounding it to `--r` would invent a
  /// softness the design does not have. It still needs a shape, because the
  /// alternative is Material's pill showing through on press.
  static const ButtonStyle _linkButton = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.editorial)),
      ),
    ),
  );

  /// The shape a segmented toggle takes.
  ///
  /// [AppRadii.pill], which the token names for toggles in as many words and
  /// which the design draws at `borderRadius: 999` (`dictionary.jsx:202`). It
  /// rendered as a pill already — but only because Material's default happens
  /// to match, which is not the same as the app saying so. Declared so the
  /// exception is deliberate and cannot be "corrected" to chrome by someone
  /// reading the rule above.
  static const ButtonStyle _segmentedButton = ButtonStyle(
    shape: WidgetStatePropertyAll(StadiumBorder()),
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
