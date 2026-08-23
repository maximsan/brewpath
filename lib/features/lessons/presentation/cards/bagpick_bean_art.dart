/// The green bean's arithmetic: what colour it is, and where its mottling
/// falls.
///
/// Pure by design. The scatter is seeded rather than random, so a round redrawn
/// mid-run — a rebuild, a theme change, a scroll — shows the same bean it
/// showed a moment ago, and a test can pin a drawing an eye could never check.
library;

import 'dart:math' as math;

import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The bean's centre, in the drawing's own 24×24 space.
const Offset beanCentre = Offset(12, 12);

/// The bean's half-extents, in the same space.
const Size beanRadius = Size(7.5, 9.5);

/// Patches per step of a bean's `mottle` value.
const int _patchesPerStep = 3;

/// The band the design keeps mottling within — visible, never a blotch.
const double _minOpacity = 0.16;
const double _opacitySpread = 0.14;

/// How far from the centre a patch may sit, as a fraction of the bean's own
/// half-extents. Capped well inside 1 so no patch reaches the outline.
const double _minPull = 0.28;
const double _pullSpread = 0.3;

/// A patch's half-extents, in the drawing's 24x24 space.
const double _minPatchWidth = 1.5;
const double _patchWidthSpread = 1.6;
const double _minPatchHeight = 1.1;
const double _patchHeightSpread = 1.3;

/// Offsets into the design's hash, one per property a patch needs, so its
/// angle, distance, size and opacity are four independent draws rather than
/// one value reused four times.
const int _angleChannel = 0;
const int _pullChannel = 9;
const int _widthChannel = 3;
const int _heightChannel = 5;
const int _opacityChannel = 7;

/// Hex notation is six digits with no alpha; the design authors nothing
/// translucent here.
const int _opaque = 0xFF000000;
const int _hexLength = 7;

/// One fleck of fruit staining left on the seed.
@immutable
class MottlePatch {
  /// Creates a [MottlePatch].
  const MottlePatch({
    required this.centre,
    required this.radius,
    required this.opacity,
  });

  /// Where it sits, in the drawing's 24×24 space.
  final Offset centre;

  /// Its half-extents.
  final Size radius;

  /// How strongly it stains.
  final double opacity;
}

/// The colour the content names, in either notation the design source uses.
///
/// Content carries a colour two ways: as `var(--art-cherry-seed)`, naming the
/// illustration palette, or as a plain `#RRGGBB`. Both appear in a single
/// bean — the body names a token and the crease gives a literal — so one
/// resolver has to read both.
///
/// **Throws on anything else**, for the reason [ArtColors.ofToken] throws: a
/// fallback colour would render a bean that looks entirely plausible and is
/// simply wrong, and no reviewer could see it.
Color beanColour(String value) {
  final trimmed = value.trim();

  if (trimmed.startsWith('#')) {
    if (trimmed.length != _hexLength) {
      throw ArgumentError.value(
        value,
        'value',
        'expected #RRGGBB, six hex digits with no alpha',
      );
    }
    final digits = int.tryParse(trimmed.substring(1), radix: 16);
    if (digits == null) {
      throw ArgumentError.value(value, 'value', 'not hexadecimal');
    }
    return Color(_opaque | digits);
  }

  if (trimmed.startsWith('var(') && trimmed.endsWith(')')) {
    return ArtColors.ofToken(
      trimmed.substring('var('.length, trimmed.length - 1).trim(),
    );
  }

  if (trimmed.startsWith('--')) return ArtColors.ofToken(trimmed);

  throw ArgumentError.value(
    value,
    'value',
    'expected a #RRGGBB literal or a --art-* token, optionally in var()',
  );
}

/// Where [bean]'s mottling falls, for the sample drawn at [seed].
///
/// Placed in polar coordinates around the centre and pulled inward, so every
/// patch lands inside the bean without a clip path — the drawing stays a few
/// ellipses rather than a layer stack. A bean with no mottling scatters
/// nothing.
List<MottlePatch> mottlePatches(BagpickBean bean, {required int seed}) {
  final count = bean.mottle * _patchesPerStep;

  return [
    for (var index = 0; index < count; index++)
      _patch(index: index, seed: seed),
  ];
}

MottlePatch _patch({required int index, required int seed}) {
  final angle = _noise(seed, index + _angleChannel) * 2 * math.pi;
  final pull = _minPull + _noise(seed, index + _pullChannel) * _pullSpread;

  return MottlePatch(
    centre: Offset(
      beanCentre.dx + math.cos(angle) * beanRadius.width * pull,
      beanCentre.dy + math.sin(angle) * beanRadius.height * pull,
    ),
    radius: Size(
      _minPatchWidth + _noise(seed, index + _widthChannel) * _patchWidthSpread,
      _minPatchHeight +
          _noise(seed, index + _heightChannel) * _patchHeightSpread,
    ),
    opacity:
        _minOpacity + _noise(seed, index + _opacityChannel) * _opacitySpread,
  );
}

/// The design's own hash, kept digit for digit.
///
/// Reproducing it rather than reaching for `Random(seed)` is deliberate: the
/// beans are authored art, tuned against these exact positions, and a
/// different generator would scatter a different — and unreviewed — bean.
double _noise(int seed, int index) {
  final value = math.sin((seed + 1) * 12.9898 + index * 78.233) * 43758.5453;
  return value - value.floorToDouble();
}
