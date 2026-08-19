/// CSS filter chains as Flutter colour matrices.
///
/// The content banks carry CSS — the prototype's medium — and Flutter has no
/// CSS. Each filter primitive is a 4×5 colour matrix and a chain of them is
/// their product, so a whole chain collapses to one matrix applied once.
///
/// The primitive matrices are the CSS Filter Effects spec's, including its
/// luminance coefficients (0.213 / 0.715 / 0.072) and the hue-rotation sine
/// terms, which are not derivable from them. They are written out as the spec
/// states them rather than computed.
///
/// **One deliberate infidelity.** CSS clamps each channel to its range
/// *between* primitives; a single composed matrix cannot, since the whole
/// point is that the chain becomes one multiplication. A chain that would
/// clip mid-way therefore lands slightly differently here than in a browser.
/// The authored chains are gentle enough that nothing clips, and the
/// alternative — applying one filter per layer — costs a `saveLayer` each.
library;

import 'dart:math' as math;

/// The 4×5 matrix that changes nothing.
const List<double> identityColorMatrix = [
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// Rows and columns of a Flutter colour matrix.
const int _rows = 4;
const int _columns = 5;

/// CSS luminance coefficients, as the filter spec states them.
const double _luminanceRed = 0.213;
const double _luminanceGreen = 0.715;
const double _luminanceBlue = 0.072;

/// The green row's sine terms in the spec's hue-rotation matrix. Not the
/// luminance coefficients and not derivable from them — the spec simply
/// states these three.
const double _hueGreenSineRed = 0.143;
const double _hueGreenSineGreen = 0.140;
const double _hueGreenSineBlue = 0.283;

/// Full sepia, as the spec states it. Partial amounts interpolate from the
/// identity toward this.
const List<double> _fullSepiaMatrix = [
  0.393, 0.769, 0.189, 0, 0, //
  0.349, 0.686, 0.168, 0, 0, //
  0.272, 0.534, 0.131, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// The matrix's fifth column is an offset in Flutter's 0–255 channel range,
/// while CSS states intercepts as fractions. Everything crossing that boundary
/// goes through this, because a fraction left unscaled is invisible rather
/// than wrong-looking, and so survives review.
const double _channelMax = 255;

/// Degrees in a half turn, for the radian conversion.
const double _degreesPerHalfTurn = 180;

/// How close two matrix entries must be to count as the same. A product of
/// several primitives reaches the identity only to within rounding, so an
/// exact comparison would call `saturate(1)` a change.
const double colorMatrixEpsilon = 1e-9;

/// A filter term and its argument: `saturate(1.2)`, `hue-rotate(-8deg)`.
final RegExp _filterTerm = RegExp(r'([a-z-]+)\(([^)]*)\)');

/// The composed colour matrix for a whole CSS filter [chain].
///
/// A term this build cannot read is skipped rather than thrown on. The
/// extractor refuses such a chain, so meeting one here means a bank from a
/// newer build — and a slightly wrong tint beats a Profile that will not open.
List<double> colorMatrixFromFilters(String chain) {
  var composed = identityColorMatrix;
  for (final term in _filterTerm.allMatches(chain)) {
    final primitive = _primitiveMatrix(term.group(1)!, term.group(2)!.trim());
    if (primitive == null) continue;
    // Later terms apply to the result of earlier ones, so the new primitive
    // goes on the outside — CSS's left-to-right reading.
    composed = _multiply(primitive, composed);
  }
  return List.unmodifiable(composed);
}

/// Whether two matrices agree to within [colorMatrixEpsilon].
bool sameColorMatrix(List<double> left, List<double> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if ((left[index] - right[index]).abs() > colorMatrixEpsilon) return false;
  }
  return true;
}

/// One CSS primitive as a colour matrix, or null when unreadable.
List<double>? _primitiveMatrix(String primitive, String rawArgument) {
  final amount = double.tryParse(rawArgument.replaceAll(RegExp('deg|%'), ''));
  if (amount == null) return null;
  final value = rawArgument.contains('%') ? amount / 100 : amount;

  switch (primitive) {
    case 'brightness':
      return _brightness(value);
    case 'contrast':
      return _contrast(value);
    case 'saturate':
      return _saturate(value);
    case 'hue-rotate':
      return _hueRotate(value);
    case 'sepia':
      return _sepia(value);
    default:
      return null;
  }
}

List<double> _brightness(double amount) => [
  amount, 0, 0, 0, 0, //
  0, amount, 0, 0, 0, //
  0, 0, amount, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// Slope [amount] pivoted about mid-grey, so the intercept is `(1 - a) / 2`.
List<double> _contrast(double amount) {
  final intercept = (1 - amount) / 2 * _channelMax;
  return [
    amount, 0, 0, 0, intercept, //
    0, amount, 0, 0, intercept, //
    0, 0, amount, 0, intercept, //
    0, 0, 0, 1, 0, //
  ];
}

List<double> _saturate(double amount) => [
  _luminanceRed + (1 - _luminanceRed) * amount,
  _luminanceGreen - _luminanceGreen * amount,
  _luminanceBlue - _luminanceBlue * amount,
  0, 0, //
  _luminanceRed - _luminanceRed * amount,
  _luminanceGreen + (1 - _luminanceGreen) * amount,
  _luminanceBlue - _luminanceBlue * amount,
  0, 0, //
  _luminanceRed - _luminanceRed * amount,
  _luminanceGreen - _luminanceGreen * amount,
  _luminanceBlue + (1 - _luminanceBlue) * amount,
  0, 0, //
  0, 0, 0, 1, 0, //
];

List<double> _hueRotate(double degrees) {
  final radians = degrees * math.pi / _degreesPerHalfTurn;
  final cos = math.cos(radians);
  final sin = math.sin(radians);
  return [
    _luminanceRed + cos * (1 - _luminanceRed) - sin * _luminanceRed,
    _luminanceGreen - cos * _luminanceGreen - sin * _luminanceGreen,
    _luminanceBlue - cos * _luminanceBlue + sin * (1 - _luminanceBlue),
    0, 0, //
    _luminanceRed - cos * _luminanceRed + sin * _hueGreenSineRed,
    _luminanceGreen + cos * (1 - _luminanceGreen) + sin * _hueGreenSineGreen,
    _luminanceBlue - cos * _luminanceBlue - sin * _hueGreenSineBlue,
    0, 0, //
    _luminanceRed - cos * _luminanceRed - sin * (1 - _luminanceRed),
    _luminanceGreen - cos * _luminanceGreen + sin * _luminanceGreen,
    _luminanceBlue + cos * (1 - _luminanceBlue) + sin * _luminanceBlue,
    0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

/// Interpolates between the identity and full sepia by [amount].
List<double> _sepia(double amount) => [
  for (var index = 0; index < _fullSepiaMatrix.length; index++)
    identityColorMatrix[index] +
        (_fullSepiaMatrix[index] - identityColorMatrix[index]) * amount,
];

/// `outer × inner`, treating both as 5×5 with an implicit `[0,0,0,0,1]` row so
/// an inner matrix's offsets carry through the outer one's scaling.
List<double> _multiply(List<double> outer, List<double> inner) {
  final product = List<double>.filled(_rows * _columns, 0);
  for (var row = 0; row < _rows; row++) {
    for (var column = 0; column < _columns; column++) {
      var sum = 0.0;
      for (var term = 0; term < _rows; term++) {
        sum += outer[row * _columns + term] * inner[term * _columns + column];
      }
      // The implicit fifth row contributes only to the offset column.
      if (column == _columns - 1) sum += outer[row * _columns + _columns - 1];
      product[row * _columns + column] = sum;
    }
  }
  return product;
}
