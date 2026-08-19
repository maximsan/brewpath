/// The grove's two axes, resolved into something a widget can paint.
///
/// A plant contributes a silhouette and a leaf tone; a light contributes a
/// tint. Both collapse here into one colour matrix and one scale, so the tree
/// widget receives a treatment rather than a pair of ids to look up, and
/// "what does Robusta look like at Moonlit" is answerable without pumping
/// anything. The matrix algebra itself lives in `color_matrix.dart`.
library;

import 'package:brew_path/features/progress/domain/color_matrix.dart';
import 'package:brew_path/shared/models/content/grove_light.dart';
import 'package:brew_path/shared/models/content/grove_variety.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/foundation.dart';

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

  /// Whether this changes nothing, so a caller can paint the real art with no
  /// wrappers at all.
  ///
  /// Tolerant of rounding, unlike [==]: a chain that composes to the identity
  /// only to within float error still means "no treatment", where equality
  /// has to stay exact to keep faith with [hashCode].
  bool get isIdentity =>
      silhouette.isUnscaled &&
      sameColorMatrix(colorMatrix, identityColorMatrix);

  /// Exact, deliberately.
  ///
  /// An epsilon here would make `==` non-transitive and, worse, inconsistent
  /// with [hashCode] — two treatments could compare equal and hash apart,
  /// which quietly breaks any `Set` or `Map` holding them. Tolerance belongs
  /// to [isIdentity], which asks a different question.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroveTreatment &&
          other.silhouette == silhouette &&
          listEquals(other.colorMatrix, colorMatrix);

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
  final plant = _resolve(
    varieties,
    (entry) => entry.id,
    wanted: variety,
    fallback: Grove.defaultVariety,
  );
  final lit = _resolve(
    lights,
    (entry) => entry.id,
    wanted: light,
    fallback: Grove.defaultLight,
  );

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

/// The silhouette scale a variety's `shape` describes.
GroveSilhouette silhouetteFromShape(String shape) {
  final match = _scaleTerm.firstMatch(shape);
  if (match == null) return GroveSilhouette.unscaled;

  final scaleX = double.tryParse(match.group(1)!);
  if (scaleX == null) return GroveSilhouette.unscaled;
  final scaleY = double.tryParse(match.group(2) ?? '') ?? scaleX;
  return GroveSilhouette(scaleX, scaleY);
}

/// The entry named [wanted], else the one named [fallback], else nothing.
///
/// The fallback is named rather than taken as the bank's first entry: the two
/// coincide today, and a reorder of the bank would otherwise silently change
/// what an unknown id resolves to.
T? _resolve<T>(
  List<T> entries,
  String Function(T) idOf, {
  required String wanted,
  required String fallback,
}) {
  T? fallen;
  for (final entry in entries) {
    final id = idOf(entry);
    if (id == wanted) return entry;
    if (id == fallback) fallen = entry;
  }
  return fallen;
}
