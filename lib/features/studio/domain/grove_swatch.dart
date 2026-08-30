import 'dart:ui';

/// How many hex digits a `#RRGGBB` swatch carries.
const int _rgbDigits = 6;

/// Opaque alpha, which every swatch takes — the bank authors no transparency.
const int _opaque = 0xFF000000;

/// The colour a light's pill shows, from the bank's authored `#RRGGBB`.
///
/// A parser rather than a lookup table because the swatches are content: the
/// bank is their authority, and a table here would be a second one that could
/// disagree.
///
/// Returns null for anything it cannot read, so a malformed swatch costs the
/// pill its dot rather than costing the learner the screen.
Color? swatchColor(String swatch) {
  final digits = swatch.startsWith('#') ? swatch.substring(1) : swatch;
  if (digits.length != _rgbDigits) return null;
  final rgb = int.tryParse(digits, radix: 16);
  return rgb == null ? null : Color(_opaque | rgb);
}
