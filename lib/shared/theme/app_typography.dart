// Self-describing tokens / DTOs / storage infra; no per-member docs.
// ignore_for_file: public_member_api_docs

import 'package:brew_path/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single source of truth for onboarding + mascot typography. Mirrors the
/// design-bundle stack (`Fraunces` display, `IBM Plex Sans` UI body,
/// `IBM Plex Mono` smallcaps). All callers should reach text styles through
/// this class so future font swaps stay localized.
abstract class AppTypography {
  // ── Display (Fraunces) ──────────────────────────────────────────
  static TextStyle displayXL({Color color = AppColors.darkRoastInk}) =>
      GoogleFonts.fraunces(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.05,
        letterSpacing: -0.72, // -0.02em at 36px
        color: color,
      );

  static TextStyle displayLG({Color color = AppColors.darkRoastInk}) =>
      GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.05,
        letterSpacing: -0.64,
        color: color,
      );

  static TextStyle displayMD({Color color = AppColors.darkRoastInk}) =>
      GoogleFonts.fraunces(
        fontSize: 30,
        fontWeight: FontWeight.w400,
        height: 1.10,
        letterSpacing: -0.30,
        color: color,
      );

  /// Italic Fraunces used by the loading caption ("Brewing your lesson").
  static TextStyle captionItalic({Color color = AppColors.darkRoastInk}) =>
      GoogleFonts.fraunces(
        fontSize: 22,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.44,
        color: color,
      );

  // ── Body / UI (IBM Plex Sans) ───────────────────────────────────
  static TextStyle body({Color color = AppColors.darkRoastInk}) =>
      GoogleFonts.ibmPlexSans(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySm({Color color = AppColors.darkRoastInkMute}) =>
      GoogleFonts.ibmPlexSans(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle button({Color color = AppColors.darkRoastAccentInk}) =>
      GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle pickTitle({Color color = AppColors.darkRoastInk}) =>
      GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // ── Smallcaps / mono (IBM Plex Mono) ────────────────────────────
  static TextStyle smallcaps({Color color = AppColors.darkRoastInkMute}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.76, // 0.16em at 11px
        color: color,
      );

  static TextStyle mono({Color color = AppColors.darkRoastInkMute}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.96,
        color: color,
      );

  /// Pre-baked `TextTheme` so `Theme.of(context).textTheme.displayLarge` etc.
  /// resolve to the dark-roast stack out of the box.
  static TextTheme textTheme() => TextTheme(
    displayLarge: displayXL(),
    displayMedium: displayLG(),
    displaySmall: displayMD(),
    headlineSmall: GoogleFonts.fraunces(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 1.10,
      letterSpacing: -0.24,
      color: AppColors.darkRoastInk,
    ),
    bodyLarge: body(),
    bodyMedium: bodySm(),
    labelLarge: button(),
    labelSmall: smallcaps(),
  );
}
