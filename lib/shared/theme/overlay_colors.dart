import 'package:brew_path/shared/theme/app_overlay.dart';
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
/// Each overlay is an `AppOverlay`: a colour **and** the blur that goes with
/// it, because the design gives both in one breath and the first port kept only
/// the colour (#379). Only `scrimInk` is a bare colour — it is ink drawn on top
/// of an overlay, not an overlay itself.
///
/// Values are transcribed from the design bundle CSS
/// (`prototype/index.html`). `color-mix(in oklab, X n%, transparent)` scales
/// only the alpha channel, so each is its literal at that opacity.
abstract final class OverlayColors {
  /// Opacity of [scrim] — the design's `color-mix(… #1B1614 58%, transparent)`.
  static const scrimOpacity = 0.58;

  /// Opacity of [dimModal] — the same mix over `#0E0A07` at 62%.
  static const dimModalOpacity = 0.62;

  /// Blur behind [scrim] — the design's *"8px behind a media control"*.
  static const scrimBlurRadius = 8.0;

  /// Blur behind [dimModal] — the design's *"5px for the modal dim"*, which the
  /// bundle also writes out as `.sheet-backdrop { backdrop-filter: blur(5px) }`
  /// (`prototype/index.html:725`).
  static const dimModalBlurRadius = 5.0;

  /// The tint behind a control that sits on video or photography.
  ///
  /// **No call site yet.** The design's only scrim is the sound toggle on the
  /// seed-to-tree video (`prototype/screens.jsx:54`), and the app's Welcome
  /// hero plays that video with no control on it. #383 builds that control.
  ///
  /// It is the one overlay of the four that is **not full-screen**, so it is
  /// also the one the `OverlayBarrier` seam cannot render: the blur has to be
  /// clipped to the control's own shape. A caller therefore takes both halves
  /// by hand — this colour as the fill, and `backdropFilter` inside the same
  /// clip — which is the one shape of call site the pairing guard allows to
  /// read `.color`.
  ///
  /// It was previously the coach-mark scrim, which the design draws in
  /// [dimModal] instead (`prototype/guide.jsx:61`).
  static const scrim = AppOverlay(
    color: Color.fromRGBO(0x1B, 0x16, 0x14, scrimOpacity),
    blurRadius: scrimBlurRadius,
  );

  /// The glyph on top of a [scrim].
  ///
  /// **No call site yet**, for the same reason as [scrim]: it is the ink of a
  /// control the app has not built.
  static const scrimInk = Color(0xFFFBF7EE);

  /// The dim behind a bottom sheet — the app's one blocking overlay.
  static const dimModal = AppOverlay(
    color: Color.fromRGBO(0x0E, 0x0A, 0x07, dimModalOpacity),
    blurRadius: dimModalBlurRadius,
  );
}
