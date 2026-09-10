import 'package:brew_path/features/lessons/presentation/cards/match_line.dart';
import 'package:flutter/material.dart';

/// One connector, already measured: where it runs, in what colour, and how
/// far through drawing itself in it is.
typedef MatchConnector = ({
  /// The trait's right edge, mid-height.
  Offset from,

  /// The answer's left edge, mid-height.
  Offset to,

  /// Sage for a landed pair, berry for a bad drop.
  Color color,

  /// 0 to 1 — how much of the line is on screen.
  double draw,

  /// 0 to 1 — how far the arrowhead has faded in.
  double arrow,
});

/// Draws a match board's connectors over the two columns.
///
/// Nothing here decides anything: the board measures the anchors and drives
/// the timing, so this is the one place a stroke is actually laid down and it
/// can be read as a drawing rather than as a state machine.
class MatchLinesPainter extends CustomPainter {
  /// Creates a [MatchLinesPainter] for [connectors].
  const MatchLinesPainter({required this.connectors});

  /// Every line to draw, in the order they landed.
  final List<MatchConnector> connectors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final connector in connectors) {
      _paintOne(canvas, connector);
    }
  }

  void _paintOne(Canvas canvas, MatchConnector connector) {
    if (connector.draw <= 0) return;

    final stroke = Paint()
      ..color = connector.color
      ..strokeWidth = matchLineStroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // The design reveals the line with `stroke-dashoffset`, which walks the
    // stroke out from its start rather than fading it in.
    final head = Offset.lerp(connector.from, connector.to, connector.draw)!;
    canvas.drawLine(connector.from, head, stroke);

    if (connector.arrow <= 0) return;
    _paintArrow(canvas, connector);
  }

  void _paintArrow(Canvas canvas, MatchConnector connector) {
    final barbs = matchArrowBarbs(from: connector.from, to: connector.to);
    final head = Path()
      ..moveTo(connector.to.dx, connector.to.dy)
      ..lineTo(barbs[0].dx, barbs[0].dy)
      ..lineTo(barbs[1].dx, barbs[1].dy)
      ..close();

    canvas.drawPath(
      head,
      Paint()..color = connector.color.withValues(alpha: connector.arrow),
    );
  }

  @override
  bool shouldRepaint(MatchLinesPainter old) => old.connectors != connectors;
}
