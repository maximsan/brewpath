import 'package:flutter/painting.dart';

/// `100%` — the span a CSS percentage is a fraction of.
const double _percentScale = 100;

/// A CSS `object-position` as the bank carries it — `'50% 42%'` — read as the
/// [Alignment] a cover-fit image is anchored by.
///
/// CSS runs both axes 0–100% from the top-left corner and [Alignment] runs
/// them −1..1 from the centre, so `50% 42%` becomes `(0, −0.16)`: centred
/// across, and a little above centre. Null, or anything not two percentages,
/// centres the picture rather than throwing — a typo in the design's data is
/// not worth a blank card.
Alignment alignmentFromObjectPosition(String? position) {
  if (position == null) return Alignment.center;
  final parts = position.trim().split(RegExp(r'\s+'));
  if (parts.length != 2) return Alignment.center;

  final x = _fraction(parts[0]);
  final y = _fraction(parts[1]);
  if (x == null || y == null) return Alignment.center;
  return Alignment(x * 2 - 1, y * 2 - 1);
}

/// `'42%'` → `0.42`, or null for anything else.
double? _fraction(String token) {
  if (!token.endsWith('%')) return null;
  final value = double.tryParse(token.substring(0, token.length - 1));
  return value == null ? null : value / _percentScale;
}
