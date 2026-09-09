/// The geometry every dashed line in the app is drawn from.
///
/// Pure, and in its own file, so the pattern can be checked at its edges
/// without painting: a run that overshot the end of a line used to be
/// invisible, because the walk lived inside a painter.
library;

/// One drawn segment, as distances along the line it sits on.
typedef DashRun = ({double from, double to});

/// The app's dash pattern, shared by every dashed line it draws. The design
/// writes `dashed` and leaves the sizing to the browser, so these are the
/// app's own: one vocabulary rather than a pattern per painter.
const double dashPatternLength = 5;

/// The gap between two dashes.
const double dashPatternGap = 4;

/// The segments of a line [length] long, walking [dash] on and [gap] off.
///
/// The last run is clipped to the end of the line rather than overshooting it,
/// and a gap that would land on the end draws no stub — a zero-length run is a
/// dot when it reaches a stroking painter.
List<DashRun> dashRuns(
  double length, {
  required double dash,
  required double gap,
}) {
  if (length <= 0) return const [];

  final runs = <DashRun>[];
  var from = 0.0;
  while (from < length) {
    final to = (from + dash).clamp(0.0, length);
    runs.add((from: from, to: to));
    from = to + gap;
  }
  return runs;
}
