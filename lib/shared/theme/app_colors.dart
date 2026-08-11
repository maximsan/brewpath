import 'package:flutter/material.dart';

/// Colours that do **not** flip with the mood.
///
/// Everything that swaps between Cupping and Dark Roast lives on
/// `MoodColors` and is read via `context.mood`. What is left here is the
/// design's literal-coffee palette: a ripe cherry is the same colour under any
/// theme, which is exactly why these are not theme tokens.
abstract class AppColors {
  /// Highlight on illustration fills (`--cream` in the design bundle).
  static const cream = Color(0xFFF0DCB8);
}
