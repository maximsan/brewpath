/// Everything about drawing a grinder's adjustment dial that is not drawing.
///
/// The painter beside this file owns strokes and canvases and nothing else:
/// every coordinate is decided here, by plain functions over plain values. So
/// "does the marker ride the rim", "do the ticks light up as the value rises"
/// and "what click count does this setting read" are answerable without a
/// canvas.
///
/// The dial is the grind card's illustration only. It is not a second control:
/// the learner drags the track below it, and this watches. Grind is the one
/// axis a real grinder has a numbered part for, so the design draws that part
/// — a click ring tilted back in perspective, the way you sight the setting on
/// a hand grinder's collar — and leaves every other calibrate round to the
/// track alone.
library;

import 'dart:math' as math;

import 'package:brew_path/features/lessons/presentation/cards/slider_dial.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The dial is authored on the design source's own 220×200 viewBox.
const Size grinderCanvas = Size(220, 200);

/// Centre of the tilted top face.
const Offset grinderCentre = Offset(110, 96);

const double _radiusX = 82;
const double _radiusY = 50;

/// Depth of the cylinder below the top face.
const double _thickness = 15;

/// Inset of the ring scribed inside the top face.
const double _ringInsetX = 12;
const double _ringInsetY = 8;

/// The gauge sweeps across the near edge of the disc: fine at upper-left,
/// coarse at upper-right, passing the bottom.
const double _startDegrees = 150;
const double _sweepDegrees = 240;

/// Ticks along the arc, one at each end and eleven between.
const int _tickCount = 13;

/// How far in from the rim a tick's inner end sits.
const double _tickInnerScale = 0.86;

/// The marker rides just inside the rim so it reads as sitting on the face.
const double _markerScale = 0.9;

/// A tick within half a degree of the marker counts as passed, so the tick the
/// marker sits on lights rather than trailing it by one.
const double _passedSlack = 0.5;

/// Clicks a hand grinder's collar counts end to end. The dial reads out in
/// clicks because that is the unit the part itself is marked in.
const int grinderClickSpan = 30;

/// Degrees to radians, so the trigonometry below names its conversion rather
/// than spelling `/ 180` at each call.
const double _radiansPerDegree = math.pi / 180;

/// Contact shadow, drawn under the cylinder.
const double _shadowDrop = 16;
const double _shadowScaleX = 0.82;
const double _shadowRadiusY = 13;

/// The click count set inside the ring, and the unit under it.
///
/// **Sizes on the canvas grid, not steps of the type ladder** — which is why
/// they are here with the other coordinates rather than reached for through
/// `AppText`. The dial is drawn on [grinderCanvas] and then scaled to whatever
/// width it is given, so a size chosen in logical pixels would be multiplied by
/// that fit and land somewhere nobody picked. The *faces* still come from the
/// ladder's own vocabulary; only the numbers are canvas units.
const double grinderClicksSize = 36;

/// Size of the `CLICKS` line under the count.
const double grinderUnitSize = 10;

/// Its tracking — `0.22em` resolved at [grinderUnitSize], because Flutter
/// wants logical units.
///
/// **App-authored, like the sizes above**, and not a step of `AppTracking`:
/// the design draws no grinder, so there is no `prototype/` rule to cite, and
/// the dial has no rung to letter against. Ruled to stay as it is rather than
/// snap to the ladder's smallcaps 0.14em — a canvas the design never drew is
/// not made truer by borrowing a rule written for type on a rung.
const double grinderUnitTracking = 0.22 * grinderUnitSize;

/// Where the two readings sit relative to the face's centre, on the canvas
/// grid: the count straddles the centre and the unit sits under it.
const double grinderClicksBaseline = -2;

/// Baseline of the `CLICKS` line, from the face's centre.
const double grinderUnitBaseline = 20;

/// What the collar reads at [value].
int grinderClicks(double value) =>
    ((value / sliderTrackSpan) * grinderClickSpan).round();

/// A point on the ellipse at [degrees], scaled toward the centre by [scale].
Offset _pointAt(double degrees, {double scale = 1}) {
  final radians = degrees * _radiansPerDegree;
  return Offset(
    grinderCentre.dx + _radiusX * scale * math.cos(radians),
    grinderCentre.dy + _radiusY * scale * math.sin(radians),
  );
}

/// Where along the arc [value] puts the marker.
double _markerDegrees(double value) =>
    _startDegrees + (value / sliderTrackSpan) * _sweepDegrees;

/// The live marker's centre at [value].
Offset grinderMarker(double value) =>
    _pointAt(_markerDegrees(value), scale: _markerScale);

/// One tick on the gauge arc.
@immutable
class GrinderTick {
  /// Creates a [GrinderTick].
  const GrinderTick({
    required this.outer,
    required this.inner,
    required this.passed,
  });

  /// The end sitting on the rim.
  final Offset outer;

  /// The end pointing at the centre.
  final Offset inner;

  /// Whether the marker has reached this tick, which is what lights it.
  final bool passed;

  @override
  bool operator ==(Object other) =>
      other is GrinderTick &&
      other.outer == outer &&
      other.inner == inner &&
      other.passed == passed;

  @override
  int get hashCode => Object.hash(outer, inner, passed);
}

/// The tick at [index], lit if the marker at [markerDegrees] has reached it.
GrinderTick _tickAt(int index, double markerDegrees) {
  final degrees = _startDegrees + (index / (_tickCount - 1)) * _sweepDegrees;
  return GrinderTick(
    outer: _pointAt(degrees),
    inner: _pointAt(degrees, scale: _tickInnerScale),
    passed: degrees <= markerDegrees + _passedSlack,
  );
}

/// Every tick on the arc, in sweep order, marked against [value].
List<GrinderTick> grinderTicks(double value) {
  final marker = _markerDegrees(value);
  return [
    for (var index = 0; index < _tickCount; index++) _tickAt(index, marker),
  ];
}

/// The tilted top face.
Rect get grinderFace => Rect.fromCenter(
  center: grinderCentre,
  width: _radiusX * 2,
  height: _radiusY * 2,
);

/// The ring scribed inside the face.
Rect get grinderInnerRing => Rect.fromCenter(
  center: grinderCentre,
  width: (_radiusX - _ringInsetX) * 2,
  height: (_radiusY - _ringInsetY) * 2,
);

/// The soft contact shadow the dial sits on.
Rect get grinderShadow => Rect.fromCenter(
  center: Offset(grinderCentre.dx, grinderCentre.dy + _thickness + _shadowDrop),
  width: _radiusX * _shadowScaleX * 2,
  height: _shadowRadiusY * 2,
);

/// The cylinder wall below the face — the dial's thickness.
Path grinderRim() {
  final left = grinderCentre.dx - _radiusX;
  final right = grinderCentre.dx + _radiusX;
  final top = grinderCentre.dy;
  final bottom = top + _thickness;

  return Path()
    ..moveTo(left, top)
    ..lineTo(left, bottom)
    ..arcToPoint(
      Offset(right, bottom),
      radius: const Radius.elliptical(_radiusX, _radiusY),
      clockwise: false,
    )
    ..lineTo(right, top)
    ..close();
}
