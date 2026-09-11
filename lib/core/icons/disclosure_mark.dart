import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_motion.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The mark a disclosure header carries, and what it promises.
///
/// Two on purpose: a caret means *more of the same, below* — things that were
/// already countable while shut — and a plus means *there is an answer here*,
/// prose that did not exist until it was asked for.
enum DisclosureGlyph {
  /// Lists: practice groups, Path's modules, a shelf of guides.
  caret,

  /// Prose: an FAQ answer.
  plus,

  /// No mark, for a header that is a heading rather than a toggle.
  none,
}

/// The glyph on a disclosure header, turning as its panel opens.
///
/// The caret turns 180°, the plus 45° into a cross — both over the design's
/// `240ms cubic-bezier(.4,0,.2,1)`, cut to nothing when motion is reduced.
class DisclosureMark extends StatelessWidget {
  /// Draws [glyph] for a panel that is [open] or shut.
  const DisclosureMark({
    required this.glyph,
    required this.open,
    this.size,
    this.color,
    super.key,
  });

  /// The caret's drawn size — the design's `size || 18`.
  static const double caretSize = 18;

  /// The plus's drawn size — the design's `size || 12`.
  static const double plusSize = 12;

  /// Half a turn: the design's 180° on the caret.
  static const double _caretOpenTurns = 0.5;

  /// An eighth: the design's 45°, which makes a plus into a cross.
  static const double _plusOpenTurns = 0.125;

  /// Which mark to draw.
  final DisclosureGlyph glyph;

  /// Whether the panel it belongs to is open, which is what it points at.
  final bool open;

  /// The box to fit the mark into. Null draws it at the size the design did.
  final double? size;

  /// The mark's ink. Null takes the muted ink the design gives every glyph.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (glyph == DisclosureGlyph.none) return const SizedBox.shrink();

    final ink = color ?? context.mood.inkMute;
    final isCaret = glyph == DisclosureGlyph.caret;
    final openTurns = isCaret ? _caretOpenTurns : _plusOpenTurns;

    return AnimatedRotation(
      turns: open ? openTurns : 0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.disclosure,
      curve: AppMotion.disclosureGlyph,
      child: isCaret
          ? IconMark(AppIcon.caret, size: size ?? caretSize, color: ink)
          : CustomPaint(
              size: Size.square(size ?? plusSize),
              painter: _PlusPainter(ink),
            ),
    );
  }
}

/// The design's own plus, which no icon in the mark family draws: `M6 1v10M1
/// 6h10` at `strokeWidth: 1.4` and `strokeOpacity: 0.7` in a 12-unit box.
class _PlusPainter extends CustomPainter {
  const _PlusPainter(this.color);

  static const double _box = 12;
  static const double _armInset = 1;
  static const double _strokeWidth = 1.4;
  static const double _strokeOpacity = 0.7;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _box;
    final paint = Paint()
      ..color = color.withValues(alpha: color.a * _strokeOpacity)
      ..strokeWidth = _strokeWidth * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final middle = size.width / 2;
    final start = _armInset * scale;
    final end = size.width - start;

    canvas
      ..drawLine(Offset(middle, start), Offset(middle, end), paint)
      ..drawLine(Offset(start, middle), Offset(end, middle), paint);
  }

  @override
  bool shouldRepaint(_PlusPainter oldDelegate) => oldDelegate.color != color;
}
