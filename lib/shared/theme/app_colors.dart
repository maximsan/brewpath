import 'package:flutter/material.dart';

/// Centralized color tokens for the app. Feature code should reference these
/// rather than inlining `Color(0x…)` literals.
abstract class AppColors {
  /// Legacy primary brown — retained for screens not yet re-tokenized.
  static const coffeeBrown = Color(0xFF6B3A2A);

  /// Legacy darkest brown accent.
  static const espresso = Color(0xFF3B1F0F);

  /// Legacy light tan.
  static const latte = Color(0xFFD4A574);

  /// Legacy cream fill.
  static const cream = Color(0xFFF5E6D3);

  /// Legacy off-white page surface.
  static const surface = Color(0xFFFAF7F4);

  /// Disabled / locked element gray.
  static const locked = Color(0xFFBDBDBD);

  // ── Dark-roast palette (onboarding + mascot screens) ───────────
  // Sourced 1:1 from the design bundle CSS at
  // brew-path/index.html [data-mood="dark-roast"].

  /// Page background for dark-roast screens.
  static const darkRoastBg = Color(0xFF1A130E);

  /// Card/panel surface on the dark-roast background.
  static const darkRoastSurface = Color(0xFF251B14);

  /// Raised secondary surface (one step lighter than [darkRoastSurface]).
  static const darkRoastSurface2 = Color(0xFF30231A);

  /// Primary text/ink on dark-roast surfaces.
  static const darkRoastInk = Color(0xFFF3E7D2);

  /// Muted/secondary text on dark-roast surfaces.
  static const darkRoastInkMute = Color(0xFFB59E84);

  /// Hairline / divider rule on dark-roast surfaces.
  static const darkRoastRule = Color(0xFF44321E);

  /// Primary accent (CTAs, highlights) on dark-roast screens.
  static const darkRoastAccent = Color(0xFFE07A4F);

  /// Ink color for content placed on the accent fill.
  static const darkRoastAccentInk = Color(0xFF1A130E);

  /// Sage-green accent (sprout / growth motifs).
  static const darkRoastSage = Color(0xFF97A285);

  /// Warning / caution accent.
  static const darkRoastWarn = Color(0xFFE6A35C);

  /// Berry accent used for error/negative states.
  static const darkRoastBerry = Color(0xFFC75450);

  /// Cream tint used for subtle highlights.
  static const darkRoastCreamTint = Color(0xFFF0DCB8);

  /// Water-drop fill for the loading-screen brew animation.
  static const darkRoastWaterDrop = Color(0xFF6FA3C8);

  /// Water-drop highlight for the loading-screen brew animation.
  static const darkRoastWaterDropHi = Color(0xFFA9CFE3);
}
