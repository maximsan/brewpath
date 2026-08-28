import 'package:brew_path/features/lessons/presentation/cards/grinder_dial.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Widest the dial is drawn, from the design source's own `maxWidth`.
const double _maxWidth = 300;

/// The grinder's adjustment collar, reading back the setting in clicks.
///
/// An illustration, not a control: it takes the value the track below it holds
/// and shows what that setting looks like on the part itself. It is kept out of
/// the semantics tree for the same reason — the slider is what a screen reader
/// should meet, and a second reading of the same setting would only be
/// something to scrub past.
///
/// Holds no logic of its own: every coordinate comes from `grinder_dial.dart`,
/// so this widget and its painter are only strokes. What is worth testing about
/// the dial is tested there, without a canvas.
class GrinderDialView extends StatelessWidget {
  /// Creates a [GrinderDialView].
  const GrinderDialView({required this.value, super.key});

  /// The setting the track currently holds.
  final double value;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ExcludeSemantics(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: AspectRatio(
            aspectRatio: grinderCanvas.width / grinderCanvas.height,
            child: CustomPaint(
              painter: _GrinderDialPainter(
                value: value,
                mood: mood,
                clicksStyle: _clicksStyle(mood),
                unitStyle: _unitStyle(mood),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The count, in the display face at the dial's own canvas size.
  ///
  /// Face from the ladder, size from the drawing — see [grinderClicksSize] for
  /// why the two come from different places here and nowhere else.
  TextStyle _clicksStyle(MoodColors mood) => TextStyle(
    fontFamily: AppFace.display.family,
    fontWeight: AppFace.display.weight,
    fontSize: grinderClicksSize,
    color: mood.ink,
  );

  TextStyle _unitStyle(MoodColors mood) => TextStyle(
    fontFamily: AppFace.mono.family,
    fontWeight: AppFace.mono.weight,
    fontSize: grinderUnitSize,
    letterSpacing: grinderUnitTracking,
    color: mood.inkMute,
  );
}

class _GrinderDialPainter extends CustomPainter {
  const _GrinderDialPainter({
    required this.value,
    required this.mood,
    required this.clicksStyle,
    required this.unitStyle,
  });

  static const double _outlineWidth = 2.5;
  static const double _ringWidth = 1.5;
  static const double _tickWidth = 2;
  static const double _passedTickWidth = 2.5;
  static const double _markerRadius = 7;
  static const double _shadowOpacity = 0.07;
  static const double _passedOpacity = 0.9;
  static const double _pendingOpacity = 0.55;

  final double value;
  final MoodColors mood;
  final TextStyle clicksStyle;
  final TextStyle unitStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(
        size.width / grinderCanvas.width,
        size.height / grinderCanvas.height,
      );

    _paintBody(canvas);
    _paintTicks(canvas);
    _paintMarker(canvas);
    _paintReadout(canvas);

    canvas.restore();
  }

  void _paintBody(Canvas canvas) {
    final rim = grinderRim();
    canvas
      ..drawOval(
        grinderShadow,
        Paint()..color = mood.ink.withValues(alpha: _shadowOpacity),
      )
      ..drawPath(rim, Paint()..color = mood.surface2)
      ..drawPath(rim, _stroke(mood.ink, _outlineWidth))
      ..drawOval(grinderFace, Paint()..color = mood.surface)
      ..drawOval(grinderFace, _stroke(mood.ink, _outlineWidth))
      ..drawOval(grinderInnerRing, _stroke(mood.rule, _ringWidth));
  }

  void _paintTicks(Canvas canvas) {
    for (final tick in grinderTicks(value)) {
      canvas.drawLine(
        tick.outer,
        tick.inner,
        _stroke(
          (tick.passed ? mood.accent : mood.inkMute).withValues(
            alpha: tick.passed ? _passedOpacity : _pendingOpacity,
          ),
          tick.passed ? _passedTickWidth : _tickWidth,
        ),
      );
    }
  }

  /// The marker is ringed in the surface colour so it stays legible where it
  /// crosses the rim, as the design source draws it.
  void _paintMarker(Canvas canvas) {
    final centre = grinderMarker(value);
    canvas
      ..drawCircle(centre, _markerRadius, Paint()..color = mood.accent)
      ..drawCircle(centre, _markerRadius, _stroke(mood.surface, _outlineWidth));
  }

  void _paintReadout(Canvas canvas) {
    _paintCentred(
      canvas,
      '${grinderClicks(value)}',
      clicksStyle,
      grinderClicksBaseline,
    );
    _paintCentred(canvas, 'CLICKS', unitStyle, grinderUnitBaseline);
  }

  /// Draws [text] centred on the face, sitting on a baseline [offsetY] below
  /// the face's centre.
  void _paintCentred(
    Canvas canvas,
    String text,
    TextStyle style,
    double offsetY,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final baseline = painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    painter.paint(
      canvas,
      Offset(
        grinderCentre.dx - painter.width / 2,
        grinderCentre.dy + offsetY - baseline,
      ),
    );
  }

  Paint _stroke(Color colour, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..color = colour;

  @override
  bool shouldRepaint(_GrinderDialPainter old) =>
      old.value != value || old.mood != mood;
}
