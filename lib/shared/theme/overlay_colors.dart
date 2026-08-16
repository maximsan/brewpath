import 'package:flutter/painting.dart';

/// The overlays that do **not** flip with the mood.
///
/// A scrim sits on media, and media does not invert with the theme; a modal dim
/// must darken the canvas in *both* moods. Bind either to `--ink` and it
/// lightens the Cupping canvas instead of dimming it — so the design declares
/// them identically in every mood block, and they are constants here rather
/// than coincidentally-equal theme values.
///
/// They follow the same rule as `ArtColors`: `static const` on a class that
/// cannot be extended, implemented or instantiated, with no `of(context)`
/// accessor, so there is nothing to vary by mood.
///
/// The overlays that *do* follow the mood — `--veil` and `--veil-strong`, the
/// page background pulled over the page — are on `MoodColors`, derived from its
/// background.
///
/// Values are transcribed from the design bundle CSS
/// (`prototype/index.html`). `color-mix(in oklab, X n%, transparent)` scales
/// only the alpha channel, so each is its literal at that opacity.
abstract final class OverlayColors {
  /// Opacity of [scrim] — the design's `color-mix(… #1B1614 58%, transparent)`.
  static const scrimOpacity = 0.58;

  /// Opacity of [dimModal] — the same mix over `#0E0A07` at 62%.
  static const dimModalOpacity = 0.62;

  /// The tint behind a control that sits on video or photography.
  static const scrim = Color.fromRGBO(0x1B, 0x16, 0x14, scrimOpacity);

  /// The glyph on top of a [scrim].
  static const scrimInk = Color(0xFFFBF7EE);

  /// The dim behind a bottom sheet — the app's one blocking overlay.
  static const dimModal = Color.fromRGBO(0x0E, 0x0A, 0x07, dimModalOpacity);
}
