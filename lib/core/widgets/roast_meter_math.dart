/// The roast meter's derivations, kept out of the widgets so each is testable
/// without pumping one.
library;

/// How far along the roast ramp a run has got: 0 at the start, 1 at the end.
///
/// [position] is 1-based — the card being played, not the number finished — so
/// the last card of a run reads 1 and lands on espresso. A run with nothing in
/// it has not started, so it reads raw green rather than dividing by zero, and
/// a position past the end clamps rather than running off the ramp.
double roastProgress({required int position, required int total}) =>
    total <= 0 ? 0 : position.clamp(0, total) / total;

/// A count as the design sets it: `1` of `8` reads `01 / 08`.
///
/// Counts of three digits or more are left as they are — padding is the
/// design's fixed-width look for a short run, not a truncation.
String zeroPadded(int count) => count.toString().padLeft(2, '0');
