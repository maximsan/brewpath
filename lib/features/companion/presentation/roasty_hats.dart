import 'package:brew_path/shared/theme/roasty_outfit_colors.dart';
import 'package:flutter/material.dart';

/// What Roasty can wear on his head.
///
/// Drawn inside the body transform, so a hat rides the hop and the shake with
/// the head it sits on. An id with no art here draws nothing, which is what
/// `none` is.
void paintRoastyHat(Canvas canvas, String hat) => _hats[hat]?.call(canvas);

/// Every hat this file draws, by the id the bank ships it under.
///
/// One table rather than a switch beside a set of the same ids: a drawing this
/// does not list cannot be reached, and an id it lists cannot draw nothing.
const _hats = <String, void Function(Canvas)>{
  'beanie': _paintBeanie,
  'field': _paintFieldHat,
  'cap': _paintCap,
};

/// The hats this file can draw, guarded against the bank's ids.
final Set<String> roastyHatIds = _hats.keys.toSet();

/// Whether [hat] draws anything — which is also whether the sprout has to
/// grow up through it.
bool hatIsBare(String hat) => !_hats.containsKey(hat);

void _paintBeanie(Canvas canvas) {
  canvas
    ..drawPath(
      Path()
        ..moveTo(44, 120)
        ..quadraticBezierTo(48, 76, 100, 74)
        ..quadraticBezierTo(152, 76, 156, 120)
        ..close(),
      Paint()..color = RoastyOutfitColors.ember,
    )
    ..drawPath(
      Path()
        ..moveTo(42, 114)
        ..quadraticBezierTo(100, 126, 158, 114)
        ..lineTo(158, 129)
        ..quadraticBezierTo(100, 140, 42, 129)
        ..close(),
      Paint()..color = RoastyOutfitColors.emberDeep,
    );

  // The two knit lines across the crown, at the design's own opacities.
  Paint knit(double opacity) => Paint()
    ..color = RoastyOutfitColors.emberDeep.withValues(alpha: opacity)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  canvas
    ..drawPath(
      Path()
        ..moveTo(66, 96)
        ..quadraticBezierTo(100, 89, 134, 96),
      knit(0.55),
    )
    ..drawPath(
      Path()
        ..moveTo(64, 105)
        ..quadraticBezierTo(100, 98, 136, 105),
      knit(0.4),
    );
}

void _paintFieldHat(Canvas canvas) {
  const brim = Rect.fromLTRB(20, 101, 180, 133);
  canvas
    ..drawOval(brim, Paint()..color = RoastyOutfitColors.strawBrim)
    ..drawOval(
      brim,
      Paint()
        ..color = RoastyOutfitColors.strawBand
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    )
    ..drawPath(
      Path()
        ..moveTo(48, 116)
        ..quadraticBezierTo(50, 80, 100, 78)
        ..quadraticBezierTo(150, 80, 152, 116)
        ..close(),
      Paint()..color = RoastyOutfitColors.strawCrown,
    )
    ..drawPath(
      Path()
        ..moveTo(62, 110)
        ..quadraticBezierTo(100, 119, 138, 110),
      Paint()
        ..color = RoastyOutfitColors.strawBand
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke,
    );
}

void _paintCap(Canvas canvas) {
  canvas
    ..drawPath(
      Path()
        ..moveTo(54, 118)
        ..quadraticBezierTo(58, 80, 100, 78)
        ..quadraticBezierTo(142, 80, 146, 118)
        ..close(),
      Paint()..color = RoastyOutfitColors.moss,
    )
    ..drawPath(
      Path()
        ..moveTo(142, 115)
        ..quadraticBezierTo(177, 113, 182, 126)
        ..quadraticBezierTo(154, 128, 142, 122)
        ..close(),
      Paint()..color = RoastyOutfitColors.mossDeep,
    )
    ..drawCircle(
      const Offset(100, 80),
      3,
      Paint()..color = RoastyOutfitColors.mossDeep,
    );
}
