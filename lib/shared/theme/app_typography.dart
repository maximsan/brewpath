// Self-describing tokens / DTOs / storage infra; no per-member docs.
// ignore_for_file: public_member_api_docs

import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Single source of truth for onboarding + mascot typography. Mirrors the
/// design-bundle stack (`Fraunces` display, `IBM Plex Sans` UI body,
/// `IBM Plex Mono` smallcaps), served from the font files bundled in
/// `assets/fonts/` and declared in `pubspec.yaml`. All callers should reach
/// text styles through this class so future font swaps stay localized.
///
/// Every style takes the ambient [MoodColors] (`context.mood`) so its default
/// ink follows the mood; pass `color` to override the role. Styles stay pure
/// Dart — no `BuildContext` — so they can be unit-tested without pumping a
/// widget.
abstract class AppTypography {
  static const _display = 'Fraunces';
  static const _ui = 'IBM Plex Sans';
  static const _mono = 'IBM Plex Mono';

  // ── Display (Fraunces) ──────────────────────────────────────────
  static TextStyle displayXL(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _display,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.05,
    letterSpacing: -0.72, // -0.02em at 36px
    color: color ?? mood.ink,
  );

  static TextStyle displayLG(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _display,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.05,
    letterSpacing: -0.64,
    color: color ?? mood.ink,
  );

  static TextStyle displayMD(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _display,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 1.10,
    letterSpacing: -0.30,
    color: color ?? mood.ink,
  );

  /// Italic Fraunces used by the loading caption ("Brewing your lesson").
  static TextStyle captionItalic(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _display,
    fontSize: 22,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.44,
    color: color ?? mood.ink,
  );

  // ── Body / UI (IBM Plex Sans) ───────────────────────────────────
  static TextStyle body(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _ui,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: color ?? mood.ink,
  );

  static TextStyle bodySm(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _ui,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: color ?? mood.inkMute,
  );

  static TextStyle button(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _ui,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: color ?? mood.accentInk,
  );

  static TextStyle pickTitle(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _ui,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color ?? mood.ink,
  );

  // ── Smallcaps / mono (IBM Plex Mono) ────────────────────────────
  static TextStyle smallcaps(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _mono,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.76, // 0.16em at 11px
    color: color ?? mood.inkMute,
  );

  static TextStyle mono(MoodColors mood, {Color? color}) => TextStyle(
    fontFamily: _mono,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.96,
    color: color ?? mood.inkMute,
  );

  /// Pre-baked `TextTheme` so `Theme.of(context).textTheme.displayLarge` etc.
  /// resolve to the mood's stack out of the box.
  static TextTheme textTheme(MoodColors mood) => TextTheme(
    displayLarge: displayXL(mood),
    displayMedium: displayLG(mood),
    displaySmall: displayMD(mood),
    headlineSmall: TextStyle(
      fontFamily: _display,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 1.10,
      letterSpacing: -0.24,
      color: mood.ink,
    ),
    bodyLarge: body(mood),
    bodyMedium: bodySm(mood),
    labelLarge: button(mood),
    labelSmall: smallcaps(mood),
  );
}
