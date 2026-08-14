// PROTOTYPE — throwaway. Not shipped, not tested, not a spec.
//
// Answers one question for issue #83: can the grove's 30 illustrations be
// painted in Dart instead of shipped as raster assets? Judge the output beside
// `brew-path/assets/trees/10.png`, which this deliberately imitates.
//
// Lives under test/ rather than lib/ so it cannot reach production by
// accident. No tokens, no `context.mood`, no lint compliance — every rule the
// real thing would follow is skipped on purpose.
//
// ignore_for_file: public_member_api_docs, prefer_const_constructors
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The three species the grove ships (#24's `variety` axis).
enum Species {
  /// Broad almond leaf, dense canopy.
  arabica(leafLength: 34, leafWidth: 20, density: 1, leafTilt: 0.0),

  /// Rounder, smaller leaf, sparser and more upright.
  robusta(leafLength: 28, leafWidth: 21, density: 0.8, leafTilt: -0.12),

  /// Famously huge leaf, few of them.
  liberica(leafLength: 45, leafWidth: 28, density: 0.62, leafTilt: 0.08);

  const Species({
    required this.leafLength,
    required this.leafWidth,
    required this.density,
    required this.leafTilt,
  });

  final double leafLength;
  final double leafWidth;
  final double density;
  final double leafTilt;
}

/// Flat palette sampled off `10.png`. The light axis would swap this whole
/// object — that is the entire "four light treatments" mechanism.
class GrovePalette {
  const GrovePalette({
    required this.potLight,
    required this.potMid,
    required this.potShade,
    required this.potRim,
    required this.soil,
    required this.stem,
    required this.leafDark,
    required this.leafLight,
    required this.vein,
    required this.cherry,
    required this.cherryHi,
    required this.shadow,
  });

  static const daylight = GrovePalette(
    potLight: Color(0xFFE0BC93),
    potMid: Color(0xFFC79A6B),
    potShade: Color(0xFFA97C50),
    potRim: Color(0xFFB98B5D),
    soil: Color(0xFF3B2A1C),
    stem: Color(0xFF5E7F3C),
    leafDark: Color(0xFF3F7538),
    leafLight: Color(0xFF6E9E52),
    vein: Color(0xFF2E5B2A),
    cherry: Color(0xFFA81C22),
    cherryHi: Color(0xFFCC3A38),
    shadow: Color(0x14000000),
  );

  final Color potLight;
  final Color potMid;
  final Color potShade;
  final Color potRim;
  final Color soil;
  final Color stem;
  final Color leafDark;
  final Color leafLight;
  final Color vein;
  final Color cherry;
  final Color cherryHi;
  final Color shadow;
}

/// Paints one grove stage.
///
/// [stage] runs 1..10 and drives plant height, branch count and fruiting;
/// [species] drives leaf geometry and canopy density. Layout is seeded off
/// `stage * 31 + species.index`, so a given cell is stable across rebuilds
/// while neighbouring stages differ.
class CoffeePlantPrototypePainter extends CustomPainter {
  CoffeePlantPrototypePainter({
    required this.stage,
    this.species = Species.arabica,
    this.palette = GrovePalette.daylight,
  });

  final int stage;
  final Species species;
  final GrovePalette palette;

  /// 0 at stage 1, 1 at stage 10.
  double get _growth => ((stage - 1) / 9).clamp(0.0, 1.0);

  /// Cherries appear only once the plant is mature — stage 8 onward.
  double get _fruiting => stage < 8 ? 0 : ((stage - 7) / 3).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(stage * 31 + species.index);
    final centerX = size.width / 2;

    // The pot grows with the plant — the reference scales it stage to stage
    // rather than holding it fixed.
    final potWidth = ui.lerpDouble(74, 172, _growth)!;
    final potHeight = potWidth * 0.78;
    final potBottom = size.height * 0.84;
    final potTop = potBottom - potHeight;

    _paintShadow(canvas, centerX, potBottom, potWidth);
    _paintPot(canvas, centerX, potTop, potWidth, potHeight);

    final soilY = potTop + potHeight * 0.10;
    _paintSoil(canvas, centerX, soilY, potWidth);

    if (stage == 1) {
      _paintSprout(canvas, centerX, soilY);
      return;
    }

    final trunkTop = soilY - ui.lerpDouble(34, 196, _growth)!;
    _paintTrunk(canvas, centerX, soilY, trunkTop);
    _paintCanopy(canvas, centerX, soilY, trunkTop, random);
  }

  void _paintShadow(Canvas canvas, double cx, double baseY, double potWidth) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, baseY + 4),
        width: potWidth * 1.12,
        height: potWidth * 0.17,
      ),
      Paint()
        ..color = palette.shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  /// Rounded tapered bowl with a rim band and one soft highlight — the whole
  /// pot is three fills and an ellipse.
  void _paintPot(
    Canvas canvas,
    double cx,
    double top,
    double width,
    double height,
  ) {
    final halfTop = width / 2;
    final halfBottom = width * 0.36;
    final bottom = top + height;

    // Bowl, not bucket: the sides bow outward before drawing in to the base.
    final body = Path()
      ..moveTo(cx - halfTop, top)
      ..cubicTo(
        cx - halfTop * 1.04, top + height * 0.44,
        cx - halfBottom * 1.32, bottom - height * 0.16,
        cx - halfBottom * 0.78, bottom - height * 0.02,
      )
      ..quadraticBezierTo(cx, bottom + height * 0.05, cx + halfBottom * 0.78,
          bottom - height * 0.02)
      ..cubicTo(
        cx + halfBottom * 1.32, bottom - height * 0.16,
        cx + halfTop * 1.04, top + height * 0.44,
        cx + halfTop, top,
      )
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx - halfTop, top),
          Offset(cx + halfTop, bottom),
          [palette.potLight, palette.potMid, palette.potShade],
          [0.0, 0.55, 1.0],
        ),
    );

    // Rim band across the mouth of the pot.
    canvas
      ..save()
      ..clipPath(body)
      ..drawRect(
        Rect.fromLTWH(cx - halfTop, top, width, height * 0.10),
        Paint()..color = palette.potRim,
      )
      ..restore();

    // The single specular highlight the reference paints on the left face.
    canvas
      ..save()
      ..clipPath(body)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx - width * 0.22, top + height * 0.52),
          width: width * 0.16,
          height: height * 0.46,
        ),
        Paint()..color = palette.potLight.withValues(alpha: 0.75),
      )
      ..restore();
  }

  void _paintSoil(Canvas canvas, double cx, double y, double potWidth) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, y),
        width: potWidth * 0.86,
        height: potWidth * 0.22,
      ),
      Paint()..color = palette.soil,
    );
  }

  /// Stage 1: two cotyledons on a stub.
  void _paintSprout(Canvas canvas, double cx, double soilY) {
    final top = soilY - 26;
    canvas.drawLine(
      Offset(cx, soilY),
      Offset(cx, top),
      Paint()
        ..color = palette.stem
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    _paintLeaf(canvas, Offset(cx, top), -2.5, 22, 10, palette.leafDark);
    _paintLeaf(canvas, Offset(cx, top), -0.65, 22, 10, palette.leafLight);
  }

  /// Tapered trunk — drawn as a filled sliver rather than a stroke so it can
  /// narrow toward the tip the way the reference does.
  void _paintTrunk(Canvas canvas, double cx, double soilY, double topY) {
    final baseHalf = ui.lerpDouble(2.5, 6.5, _growth)!;
    final path = Path()
      ..moveTo(cx - baseHalf, soilY)
      ..quadraticBezierTo(cx - baseHalf * 0.7, (soilY + topY) / 2, cx - 1.4, topY)
      ..lineTo(cx + 1.4, topY)
      ..quadraticBezierTo(
        cx + baseHalf * 0.7,
        (soilY + topY) / 2,
        cx + baseHalf,
        soilY,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = palette.stem);
  }

  /// Opposite branch pairs up the trunk, each carrying leaves and — once the
  /// plant is fruiting — a cherry cluster at its base.
  void _paintCanopy(
    Canvas canvas,
    double cx,
    double soilY,
    double trunkTop,
    math.Random random,
  ) {
    final trunkLength = soilY - trunkTop;
    final pairs = (2 + (_growth * 5).round() * species.density).round().clamp(
      1,
      7,
    );
    final branchPaint = Paint()
      ..color = palette.stem
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (var pair = 0; pair < pairs; pair++) {
      // Lowest pair sits a little above the soil, highest just below the tip.
      final along = 0.30 + 0.62 * (pair / math.max(pairs - 1, 1));
      final anchorY = soilY - trunkLength * along;
      // Branches shorten toward the top, giving the round canopy.
      final taper = 1.0 - 0.45 * along;
      final reach = trunkLength * 0.56 * taper * (0.85 + random.nextDouble() * 0.3);

      for (final side in const [-1.0, 1.0]) {
        // Lower branches reach out and slightly down, upper ones swing up —
        // together they trace the round canopy the reference draws, instead of
        // the vase shape a constant lift produces.
        final swing = ui.lerpDouble(-0.16, 0.58, along)! +
            (random.nextDouble() - 0.5) * 0.30;
        final tip = Offset(cx + side * reach, anchorY - reach * swing);
        canvas.drawLine(Offset(cx, anchorY), tip, branchPaint);

        _paintBranchLeaves(canvas, Offset(cx, anchorY), tip, side, random);

        if (_fruiting > 0 && random.nextDouble() < 0.75 * _fruiting + 0.2) {
          _paintCherryCluster(
            canvas,
            Offset.lerp(Offset(cx, anchorY), tip, 0.45 + random.nextDouble() * 0.4)!,
            random,
          );
        }
      }
    }
  }

  void _paintBranchLeaves(
    Canvas canvas,
    Offset base,
    Offset tip,
    double side,
    math.Random random,
  ) {
    final axis = (tip - base).direction;
    final leafCount = (2 + (species.density * 2).round()).clamp(2, 4);

    for (var i = 0; i < leafCount; i++) {
      final along = 0.34 + 0.66 * (i / math.max(leafCount - 1, 1));
      final at = Offset.lerp(base, tip, along)!;
      final scale = 0.72 + 0.28 * along;
      // Opposite pairs: one leaf above the branch line, one below.
      for (final flip in const [-1.0, 1.0]) {
        // Near-perpendicular to the branch: coffee leaves sit out to the
        // sides in opposite pairs, they do not sweep back along the stem.
        final spread = (1.16 + random.nextDouble() * 0.22) * flip;
        canvas.save();
        _paintLeaf(
          canvas,
          at,
          axis + spread + species.leafTilt * side,
          species.leafLength * scale,
          species.leafWidth * scale,
          flip < 0 ? palette.leafDark : palette.leafLight,
        );
        canvas.restore();
      }
    }

    // Terminal leaf along the branch axis.
    _paintLeaf(
      canvas,
      tip,
      axis,
      species.leafLength * 0.9,
      species.leafWidth * 0.9,
      palette.leafDark,
    );
  }

  /// Almond blade with a single centre vein — two quadratics and a line.
  void _paintLeaf(
    Canvas canvas,
    Offset base,
    double angle,
    double length,
    double width,
    Color color,
  ) {
    canvas
      ..save()
      ..translate(base.dx, base.dy)
      ..rotate(angle);

    final blade = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.42, -width * 0.62, length, 0)
      ..quadraticBezierTo(length * 0.42, width * 0.62, 0, 0)
      ..close();
    canvas
      ..drawPath(blade, Paint()..color = color)
      ..drawLine(
        Offset.zero,
        Offset(length * 0.92, 0),
        Paint()
          ..color = palette.vein.withValues(alpha: 0.55)
          ..strokeWidth = 1.1,
      )
      ..restore();
  }

  /// A bunch of cherries: circles with one highlight arc each.
  void _paintCherryCluster(Canvas canvas, Offset at, math.Random random) {
    final count = 3 + random.nextInt(4);
    final radius = 5.2;

    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = random.nextDouble() * radius * 1.7;
      final center = at + Offset(math.cos(angle), math.sin(angle)) * distance;

      canvas
        ..drawCircle(center, radius, Paint()..color = palette.cherry)
        ..drawCircle(
          center.translate(-radius * 0.32, -radius * 0.34),
          radius * 0.34,
          Paint()..color = palette.cherryHi,
        );
    }
  }

  @override
  bool shouldRepaint(CoffeePlantPrototypePainter old) =>
      old.stage != stage ||
      old.species != species ||
      old.palette != palette;
}
