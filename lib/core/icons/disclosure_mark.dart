import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// The plus that turns into a cross as its answer opens.
///
/// The design's own mark, and its `transition: transform 200ms ease` — unlike
/// `CaretMark`, which the design states without one. The glyph is `close`
/// rotated: that mark is already the symmetric cross this ends on, so the two
/// share one stroke weight rather than two drawings of the same lines.
class DisclosureMark extends StatelessWidget {
  /// Creates a mark for a row that is [open] or closed.
  const DisclosureMark({required this.open, this.size, this.color, super.key});

  /// Whether the row it belongs to is open, which is what it states.
  final bool open;

  /// The box to fit the mark into. Null draws it at the mark's own size.
  final double? size;

  /// The mark's ink. Null takes the ambient icon colour, as any mark does.
  final Color? color;

  /// An eighth of a turn — the design's 45°, which makes a cross a plus.
  static const double _closedTurns = 0.125;

  @override
  Widget build(BuildContext context) => AnimatedRotation(
    turns: open ? 0 : _closedTurns,
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.markTurn,
    curve: Curves.ease,
    child: IconMark(AppIcon.close, size: size, color: color),
  );
}
