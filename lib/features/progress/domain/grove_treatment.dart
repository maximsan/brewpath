/// Turns the grove's two axes into something a widget can paint: one colour
/// matrix and one scale.
///
/// The banks carry CSS — the prototype's medium — and Flutter has no CSS. Each
/// filter primitive is a 4×5 colour matrix, and a chain of them is their
/// product, so the whole treatment collapses to a single matrix applied once.
/// The maths lives here rather than in the widget so "what does Robusta look
/// like at Moonlit" is answerable without pumping anything.
///
/// The primitive matrices follow the CSS Filter Effects spec, including its
/// luminance coefficients (0.213 / 0.715 / 0.072). They are the spec's numbers
/// rather than derived, so they are written out as the spec states them.
library;

import 'dart:math' as math;

import 'package:brew_path/shared/models/content/grove_light.dart';
import 'package:brew_path/shared/models/content/grove_variety.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/foundation.dart';

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

/// The green row's sine terms in the spec's hue-rotation matrix. They are not
/// the luminance coefficients and are not derivable from them — the spec
/// simply states these three, so they are named rather than inlined.
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

/// How close two matrix entries must be to count as the same. Products of
/// several primitives accumulate float error, so the identity check cannot be
/// exact — `saturate(1)` composes to the identity only to within rounding.
const double _matrixEpsilon = 1e-9;

/// A filter term and its argument: `saturate(1.2)`, `hue-rotate(-8deg)`.
final RegExp _filterTerm = RegExp(r'([a-z-]+)\(([^)]*)\)');

/// A CSS `scale()`, with one argument or two.
final RegExp _scaleTerm = RegExp(
  r'scale\(\s*([-\d.]+)\s*(?:,\s*([-\d.]+)\s*)?\)',
);

/// The anisotropic scale that tells one species' silhouette from another.
@immutable
class GroveSilhouette {
  /// Creates a [GroveSilhouette].
  const GroveSilhouette(this.scaleX, this.scaleY);

  /// The plant drawn at its own proportions.
  static const unscaled = GroveSilhouette(1, 1);

  /// Horizontal scale.
  final double scaleX;

  /// Vertical scale.
  final double scaleY;

  /// Whether this leaves the art untouched.
  bool get isUnscaled => scaleX == 1 && scaleY == 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroveSilhouette &&
          other.scaleX == scaleX &&
          other.scaleY == scaleY;

  @override
  int get hashCode => Object.hash(scaleX, scaleY);

  @override
  String toString() => 'GroveSilhouette($scaleX, $scaleY)';
}

/// One plant under one light, ready to paint.
@immutable
class GroveTreatment {
  /// Creates a [GroveTreatment].
  const GroveTreatment({required this.colorMatrix, required this.silhouette});

  /// The treatment that paints the art exactly as drawn.
  static const identity = GroveTreatment(
    colorMatrix: identityColorMatrix,
    silhouette: GroveSilhouette.unscaled,
  );

  /// The composed 4×5 colour matrix.
  final List<double> colorMatrix;

  /// The species' silhouette scale.
  final GroveSilhouette silhouette;

  /// Whether this changes nothing, so a caller can skip both wrappers and
  /// paint the real art untouched.
  bool get isIdentity =>
      silhouette.isUnscaled && _sameMatrix(colorMatrix, identityColorMatrix);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroveTreatment &&
          other.silhouette == silhouette &&
          _sameMatrix(other.colorMatrix, colorMatrix);

  @override
  int get hashCode => Object.hash(silhouette, Object.hashAll(colorMatrix));
}

/// The treatment for [variety] under [light], resolved against the banks.
///
/// An id naming nothing resolves to the axis default rather than throwing: a
/// grove is stored as two plain strings that sync between devices, so a
/// snapshot written by a newer build can legitimately name a plant this build
/// has never heard of. The tree still has to render.
GroveTreatment groveTreatmentFor({
  required List<GroveVariety> varieties,
  required List<GroveLight> lights,
  required String variety,
  required String light,
}) {
  final plant = _resolveVariety(varieties, variety);
  final lit = _resolveLight(lights, light);

  // Leaf tone first, then the light over it — the order the prototype
  // composes them in, and the one that reads as a plant standing in a light
  // rather than a light with a plant tinted onto it.
  final chain = [
    if (plant?.leaf.isNotEmpty ?? false) plant!.leaf,
    if (lit?.filter.isNotEmpty ?? false) lit!.filter,
  ].join(' ');

  return GroveTreatment(
    colorMatrix: colorMatrixFromFilters(chain),
    silhouette: silhouetteFromShape(plant?.shape ?? ''),
  );
}

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
    // Later terms apply to the result of earlier ones.
    composed = _multiply(primitive, composed);
  }
  return composed;
}

/// The silhouette scale a variety's `shape` describes.
GroveSilhouette silhouetteFromShape(String shape) {
  final match = _scaleTerm.firstMatch(shape);
  if (match == null) return GroveSilhouette.unscaled;

  final scaleX = double.tryParse(match.group(1)!);
  if (scaleX == null) return GroveSilhouette.unscaled;
  final scaleY = double.tryParse(match.group(2) ?? '') ?? scaleX;
  return GroveSilhouette(scaleX, scaleY);
}

/// The named variety, else the snapshot's declared default, else nothing.
///
/// The default is named rather than taken as the bank's first entry: the two
/// coincide today, and a reorder of the bank would silently change what an
/// unknown id falls back to.
GroveVariety? _resolveVariety(List<GroveVariety> varieties, String id) =>
    _firstWhereId(varieties, id, (variety) => variety.id) ??
    _firstWhereId(varieties, Grove.defaultVariety, (variety) => variety.id);

GroveLight? _resolveLight(List<GroveLight> lights, String id) =>
    _firstWhereId(lights, id, (light) => light.id) ??
    _firstWhereId(lights, Grove.defaultLight, (light) => light.id);

T? _firstWhereId<T>(List<T> entries, String id, String Function(T) idOf) {
  for (final entry in entries) {
    if (idOf(entry) == id) return entry;
  }
  return null;
}

/// One CSS primitive as a colour matrix, or null when unreadable.
List<double>? _primitiveMatrix(String primitive, String rawArgument) {
  final amount = double.tryParse(rawArgument.replaceAll(RegExp('deg|%'), ''));
  if (amount == null) return null;
  final value = rawArgument.contains('%') ? amount / 100 : amount;

  switch (primitive) {
    case 'brightness':
      return _scaleChannels(value);
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

List<double> _scaleChannels(double amount) => [
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
  final radians = degrees * math.pi / 180;
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
/// the offset column carries through the product.
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

bool _sameMatrix(List<double> left, List<double> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if ((left[index] - right[index]).abs() > _matrixEpsilon) return false;
  }
  return true;
}
