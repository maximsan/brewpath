import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

/// An overlay: the tint it lays over the screen and the blur it puts behind
/// itself, held as **one** value.
///
/// The design registers five overlays and gives each its filter in the same
/// breath as its colour — *"Blur is part of the token's job, not a decoration:
/// 5px for the modal dim, 3px for a covering wash, 8px behind a media control,
/// none on the plain veil"* (`prototype/ds-content.js:1090`, restated for
/// `--dim-modal` in the colour table at `:38`).
///
/// The first port transcribed all four colours and dropped all four radii
/// (#379). That was possible only because they were two separate values, so a
/// call site could take one and leave the other. Here they are one value, and
/// the things that render an overlay — a modal route's barrier via
/// `OverlayBarrier`, and the sticky header's bar — take the whole token, so
/// the parts cannot come apart at a call site.
@immutable
class AppOverlay {
  /// Creates an overlay from its [color], its [blurRadius] and the
  /// [saturation] it lifts what is behind to.
  const AppOverlay({
    required this.color,
    required this.blurRadius,
    this.saturation = unsaturated,
  }) : assert(blurRadius >= 0, 'a blur radius is a length, never negative'),
       assert(saturation >= 0, 'saturation is a multiplier, never negative');

  /// Saturation that changes nothing — what three of the four overlays ask
  /// for, because the design gives them a plain blur.
  static const double unsaturated = 1;

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

  /// How far the colour behind this overlay is lifted before it is tinted.
  ///
  /// The design writes the sticky header's filter as `blur(16px)
  /// saturate(1.3)` — one instruction, two parts — and the second part is
  /// what keeps a warm page from going grey the moment sixteen pixels of
  /// blur average it out. It lives here for the reason the radius does: a
  /// filter written in one breath must not be takeable in halves.
  ///
  /// [unsaturated] leaves the colour alone, and costs nothing: the matrix is
  /// built only when there is a lift to apply.
  final double saturation;

  /// Whether this overlay lifts saturation at all.
  bool get isSaturated => saturation != unsaturated;

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
  ImageFilter? get backdropFilter {
    final blur = isBlurred
        ? ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius)
        : null;
    if (!isSaturated) return blur;

    // `ColorFilter` is an `ImageFilter`, so the pair composes into the single
    // filter a `BackdropFilter` takes. Outer is the saturation: the design
    // blurs first and lifts what the blur averaged out, not the other way
    // round.
    final lift = ColorFilter.matrix(_saturationMatrix(saturation));
    return blur == null ? lift : ImageFilter.compose(outer: lift, inner: blur);
  }

  /// The luminance weights CSS `saturate()` is defined against — the same
  /// three SVG's `feColorMatrix type="saturate"` uses, which is where the CSS
  /// filter takes its definition from.
  static const double _lumaRed = 0.213;
  static const double _lumaGreen = 0.715;
  static const double _lumaBlue = 0.072;

  /// The 4×5 matrix that lifts saturation to [amount], leaving alpha alone.
  ///
  /// Each channel keeps its own weight plus what the lift adds, and loses the
  /// other two channels in proportion — so at [unsaturated] this is the
  /// identity, and the colour behind is untouched.
  static List<double> _saturationMatrix(double amount) {
    final red = _lumaRed - _lumaRed * amount;
    final green = _lumaGreen - _lumaGreen * amount;
    final blue = _lumaBlue - _lumaBlue * amount;

    return <double>[
      red + amount,
      green,
      blue,
      0,
      0,
      red,
      green + amount,
      blue,
      0,
      0,
      red,
      green,
      blue + amount,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is AppOverlay &&
      other.color == color &&
      other.blurRadius == blurRadius &&
      other.saturation == saturation;

  @override
  int get hashCode => Object.hash(color, blurRadius, saturation);

  @override
  String toString() =>
      'AppOverlay($color, blur ${blurRadius}px, saturation $saturation)';
}
