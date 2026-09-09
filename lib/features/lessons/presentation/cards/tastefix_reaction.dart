import 'dart:ui';

/// How the cup answered the fix the learner committed to.
///
/// Its own type rather than a nullable bool: *not yet asked* and *asked and
/// unrelieved* draw differently, and the panel reads all three.
enum TastefixReaction {
  /// Nothing committed yet — the cup as the round set it out.
  unfixed,

  /// The fix worked. The symptoms give way to the design's Balanced state.
  relieved,

  /// The fix did not work, so the symptoms it should have relieved dim.
  worsened;

  /// Whether the cup is fixed, which is the state that replaces the symptoms.
  bool get isBalanced => this == TastefixReaction.relieved;

  /// Whether the symptoms are drawn dimmed.
  bool get isWorsened => this == TastefixReaction.worsened;
}

/// The design's `duration: 380` on the panel's shake.
const Duration tastefixShakeDuration = Duration(milliseconds: 380);

/// The design's `duration: 460` on the panel's pulse.
const Duration tastefixPulseDuration = Duration(milliseconds: 460);

/// The design's `transition: opacity .3s ease` on a dimming symptom.
const Duration tastefixDimDuration = Duration(milliseconds: 300);

/// The design's `transition: background .45s ease` on the panel settling.
const Duration tastefixSettleDuration = Duration(milliseconds: 450);

/// How dim a symptom is drawn once the fix failed to relieve it — the design's
/// `opacity: worsened ? 0.6 : 1`.
const double tastefixDimmedOpacity = 0.6;

/// The design's `translateX(0 → -5px → 5px → -3px → 0)`, evenly spaced.
const List<double> _shakeStops = [0, -5, 5, -3, 0];

/// The design's `scale(1 → 1.035 → 1)`, evenly spaced.
const List<double> _pulseStops = [1, 1.035, 1];

/// How far the panel has slid sideways at [progress] through its shake.
///
/// [progress] is already eased — the design carries one `ease-in-out` across
/// the whole run and interpolates its stops linearly within it.
double tastefixShakeOffset(double progress) =>
    _atStop(_shakeStops, progress, atRest: 0);

/// How large the panel is drawn at [progress] through its pulse, eased like
/// [tastefixShakeOffset] and against the design's own `ease-out`.
double tastefixPulseScale(double progress) =>
    _atStop(_pulseStops, progress, atRest: 1);

/// Reads evenly spaced [stops] at [progress], holding [atRest] off either end
/// so a controller that has not started cannot draw a half-played frame.
double _atStop(List<double> stops, double progress, {required double atRest}) {
  if (progress <= 0 || progress >= 1) return atRest;
  final span = stops.length - 1;
  final scaled = progress * span;
  final index = scaled.floor().clamp(0, span - 1);
  return lerpDouble(stops[index], stops[index + 1], scaled - index)!;
}
