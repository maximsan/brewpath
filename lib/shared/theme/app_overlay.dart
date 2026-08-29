import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

/// An overlay: the tint it lays over the screen and the blur it puts behind
/// itself, held as **one** value.
///
/// The design registers four overlays and gives each its blur in the same
/// breath as its colour — *"Blur is part of the token's job, not a decoration:
/// 5px for the modal dim, 3px for a covering wash, 8px behind a media control,
/// none on the plain veil"* (`prototype/ds-content.js:1090`, restated for
/// `--dim-modal` in the colour table at `:38`).
///
/// The first port transcribed all four colours and dropped all four radii
/// (#379). That was possible only because they were two separate values, so a
/// call site could take one and leave the other. Here they are one value, and
/// the two things that render an overlay — a modal route's barrier via
/// `OverlayBarrier`, and nothing else yet — take the whole token, so the pair
/// cannot come apart at a call site.
@immutable
class AppOverlay {
  /// Creates an overlay from its [color] and its [blurRadius].
  const AppOverlay({required this.color, required this.blurRadius})
    : assert(blurRadius >= 0, 'a blur radius is a length, never negative');

  /// The tint laid over whatever is behind.
  final Color color;

  /// The radius of the blur applied to everything behind, in logical pixels.
  ///
  /// This is the design's own number, carried over unscaled. CSS
  /// `backdrop-filter: blur(<length>)` defines that length as the *standard
  /// deviation* of the Gaussian it applies — the same quantity SVG's
  /// `feGaussianBlur` takes as `stdDeviation` — and [ImageFilter.blur] takes
  /// that same standard deviation as its sigma. So there is no conversion
  /// constant here to get wrong: 5px in the bundle is sigma 5 on screen.
  final double blurRadius;

  /// Whether this overlay blurs at all.
  ///
  /// False for exactly one of the four: the plain veil, which the design leaves
  /// unblurred because the screen under it is meant to stay readable — *"that
  /// legibility **is** the pitch"* (`ds-content.js:1085`).
  bool get isBlurred => blurRadius > 0;

  /// The filter to hand a `BackdropFilter`, or null when there is no blur.
  ///
  /// Null rather than a zero-sigma filter on purpose: a `BackdropFilter` takes
  /// a `saveLayer` over everything behind it whatever its sigma, and an overlay
  /// the design gives no blur must not pay for one.
  ImageFilter? get backdropFilter => isBlurred
      ? ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius)
      : null;

  @override
  bool operator ==(Object other) =>
      other is AppOverlay &&
      other.color == color &&
      other.blurRadius == blurRadius;

  @override
  int get hashCode => Object.hash(color, blurRadius);

  @override
  String toString() => 'AppOverlay($color, blur ${blurRadius}px)';
}
