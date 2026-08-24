/// Everything about drawing a green bean that is not actually drawing.
///
/// The painter beside this file owns strokes and canvases and nothing else:
/// every colour and every coordinate is decided here, by plain functions over
/// plain values. That is what makes "does this bean draw the right colour" and
/// "do the patches stay inside the bean" answerable without pumping a widget —
/// and in a game where the *colour is the question the learner is asked*, those
/// are the two things most worth being able to ask.
library;

import 'dart:math' as math;
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The bean is authored on a 24×24 grid, as the design source draws it.
const double beanCanvas = 24;

const Offset _centre = Offset(12, 12);
const double _radiusX = 7.5;
const double _radiusY = 9.5;

/// Patches per step of the round's `mottle` value.
const int _patchesPerMottleStep = 3;

/// The colour a bean's `body` or `crease` field names.
///
/// Extracted rounds carry these in **two forms**, and both appear across the
/// five authored bags: a hex literal such as `#9E7C45`, or a reference to the
/// design source's own colour token, `var(--art-cherry-seed)`. The author wrote
/// whichever was to hand, and the bank preserves it faithfully.
///
/// **Throws on anything else, including a token the palette does not carry.**
/// A fallback colour here would draw a bean that looks entirely plausible and
/// is simply the wrong process — in the one game whose whole mechanic is
/// judging process from the look of the seed. There is no reading of a bad
/// value that is better than stopping.
Color beanColour(String value) {
  final trimmed = value.trim();

  final variable = RegExp(r'^var\(\s*(--[a-z-]+)\s*\)$').firstMatch(trimmed);
  if (variable != null) return ArtColors.ofToken(variable.group(1)!);

  final hex = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(trimmed);
  if (hex != null) {
    return Color(0xFF000000 | int.parse(hex.group(1)!, radix: 16));
  }

  throw ArgumentError.value(
    value,
    'value',
    'not a bean colour; expected #RRGGBB or var(--art-token)',
  );
}

/// One mottled patch on the face of a bean.
@immutable
class BeanPatch {
  /// Creates a [BeanPatch].
  const BeanPatch({
    required this.centre,
    required this.radius,
    required this.opacity,
  });

  /// Where it sits on the 24×24 grid.
  final Offset centre;

  /// Its two radii — patches are ellipses, like the bean itself.
  final Size radius;

  /// How strongly it reads against the body colour.
  final double opacity;
}

/// The mottling for one bean of a sample.
///
/// [mottle] is the round's own step — 0 draws a clean bean, and each step adds
/// three patches. [seed] is the bean's place in the sample, so the three beans
/// on screen differ from one another while each stays the same across a
/// rebuild.
///
/// Placement is **polar**, and that is not a stylistic choice: an offset drawn
/// independently in x and y would put patches outside the ellipse and need
/// clipping to hide it. Choosing an angle and a distance *within* the radii
/// keeps every patch on the bean by construction.
List<BeanPatch> beanPatches({required int mottle, required int seed}) {
  if (mottle <= 0) return const [];

  final random = _BeanNoise(seed);
  return [
    for (var index = 0; index < mottle * _patchesPerMottleStep; index++)
      _patchAt(index, random),
  ];
}

BeanPatch _patchAt(int index, _BeanNoise random) {
  final angle = random.at(index) * 2 * math.pi;
  final distance = 0.28 + random.at(index + 9) * 0.3;

  return BeanPatch(
    centre: Offset(
      _centre.dx + math.cos(angle) * _radiusX * distance,
      _centre.dy + math.sin(angle) * _radiusY * distance,
    ),
    radius: Size(
      1.5 + random.at(index + 3) * 1.6,
      1.1 + random.at(index + 5) * 1.3,
    ),
    opacity: 0.16 + random.at(index + 7) * 0.14,
  );
}

/// The chaff clinging in the crease, when the round says the sample has any.
///
/// Fixed rather than seeded, because it is two specks of silverskin left in the
/// fold — a detail of the process, not of the individual bean, so every bean in
/// a sample carries it identically.
List<BeanPatch> beanChaff({required bool chaff}) => chaff
    ? const [
        BeanPatch(
          centre: Offset(11.2, 8.2),
          radius: Size(0.85, 0.42),
          opacity: 0.6,
        ),
        BeanPatch(
          centre: Offset(12.7, 16),
          radius: Size(0.7, 0.38),
          opacity: 0.5,
        ),
      ]
    : const [];

/// The bean's outline, as an ellipse on the 24×24 grid.
Rect get beanBody =>
    Rect.fromCenter(center: _centre, width: _radiusX * 2, height: _radiusY * 2);

/// The shadow the bean sits on — the same ellipse, dropped slightly.
Rect get beanShadow => beanBody.translate(0, 0.6);

/// The centre cut: the fold where the two halves of the seed meet.
///
/// The single most-read feature of the whole card — a clean pale line says
/// washed, and anything packed into it says otherwise — so it is drawn from
/// the design source's own curve rather than approximated.
Path get beanCrease => Path()
  ..moveTo(12, 3.5)
  ..cubicTo(13.5, 7, 10.5, 9, 12, 12)
  ..cubicTo(13.5, 15, 13.5, 17, 12, 20.5);

/// The design source's hash noise, kept exactly.
///
/// Reproduced rather than replaced by `dart:math`'s generator because the
/// authored bags were tuned against *these* placements: the bag whose tell is
/// its mottling was checked by eye, and a different sequence would move the
/// patches the round's own explanation points at.
class _BeanNoise {
  const _BeanNoise(this.seed);

  final int seed;

  double at(int index) {
    final value = math.sin((seed + 1) * 12.9898 + index * 78.233) * 43758.5453;
    return value - value.floorToDouble();
  }
}
