import 'package:flutter/material.dart';

abstract class AppColors {
  // Legacy seed tokens retained for screens that haven't been re-tokenized.
  static const coffeeBrown = Color(0xFF6B3A2A);
  static const espresso = Color(0xFF3B1F0F);
  static const latte = Color(0xFFD4A574);
  static const cream = Color(0xFFF5E6D3);
  static const surface = Color(0xFFFAF7F4);
  static const locked = Color(0xFFBDBDBD);

  // ── Dark-roast palette (onboarding + mascot screens) ───────────
  // Sourced 1:1 from the design bundle CSS at
  // coffee_quest/brew-path-app/project/index.html [data-mood="dark-roast"].
  static const darkRoastBg = Color(0xFF1A130E);
  static const darkRoastSurface = Color(0xFF251B14);
  static const darkRoastSurface2 = Color(0xFF30231A);
  static const darkRoastInk = Color(0xFFF3E7D2);
  static const darkRoastInkMute = Color(0xFFB59E84);
  static const darkRoastRule = Color(0xFF44321E);
  static const darkRoastAccent = Color(0xFFE07A4F);
  static const darkRoastAccentInk = Color(0xFF1A130E);
  static const darkRoastSage = Color(0xFF97A285);
  static const darkRoastWarn = Color(0xFFE6A35C);
  static const darkRoastBerry = Color(0xFFC75450);
  static const darkRoastCreamTint = Color(0xFFF0DCB8);

  // Water-drop accent used by the loading-screen brew animation.
  static const darkRoastWaterDrop = Color(0xFF6FA3C8);
  static const darkRoastWaterDropHi = Color(0xFFA9CFE3);
}
