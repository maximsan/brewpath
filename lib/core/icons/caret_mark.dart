import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:flutter/material.dart';

/// The expand/collapse caret, pointing down when closed and up when open.
///
/// The design has **one** caret for this, not a pair: *"Accordions, review
/// toggles. Rotates 180° when open."* Material's `expand_more`/`expand_less`
/// are two glyphs, and swapping between them is what the app did — so this
/// exists to keep the design's rule in one place rather than leaving each
/// accordion to remember it.
///
/// The turn is instant. The design states the rotation and not an animation
/// for it, and a rotation that animates would need a duration this layer has
/// no token for.
class CaretMark extends StatelessWidget {
  /// Creates a caret for a section that is [open] or closed.
  const CaretMark({required this.open, this.size, this.color, super.key});

  /// Whether the section it belongs to is open, which is what it points at.
  final bool open;

  /// The box to fit the caret into. Null draws it at the size the design did.
  final double? size;

  /// The caret's ink. Null takes the ambient icon colour, as any mark does.
  final Color? color;

  /// Half a turn — the design's own 180°.
  static const int _openTurns = 2;

  @override
  Widget build(BuildContext context) => RotatedBox(
    quarterTurns: open ? _openTurns : 0,
    child: IconMark(AppIcon.caret, size: size, color: color),
  );
}
