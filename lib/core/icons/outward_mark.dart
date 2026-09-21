import 'dart:math' as math;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:flutter/material.dart';

/// The affordance on anything that leaves the app, in place of the chevron.
///
/// The design's outward arrow is the app's arrow turned a quarter up, so
/// nothing new is drawn for it and the icon catalogue stays the extractor's.
class OutwardMark extends StatelessWidget {
  /// Draws the outward arrow in [color], or the mood's muted ink.
  const OutwardMark({this.color, super.key});

  static const double _quarterTurnUp = -math.pi / 4;

  /// The mark's ink.
  final Color? color;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: _quarterTurnUp,
    child: IconMark(AppIcon.arrow, color: color),
  );
}
