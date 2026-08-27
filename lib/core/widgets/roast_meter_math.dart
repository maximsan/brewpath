/// The roast meter's derivations, kept out of the widgets so each is testable
/// without pumping one.
library;

/// How far along the roast ramp a run has got: 0 at the start, 1 at the end.
///
/// [position] is 1-based — the card being played, not the number finished — and
/// the ramp is spread across the **gaps between cards**, so the first card
/// reads raw green and the last reads espresso. That is what the design asks
/// for in prose: *"raw green at the first question, espresso at the last"*.
///
/// The prototype's own arithmetic does not deliver it — `RoastBean` there is
/// passed `done={idx + 1}` over `total`, so its first card already sits an
/// eighth along the ramp and never shows the green the comment above it
/// promises. The comment is the intent; this is the reading that honours it.
///
/// A run of one card, or of none, has no gap to spread the ramp over, so it
/// reads raw green rather than dividing by zero. A position past either end
/// clamps rather than running off the ramp.
double roastProgress({required int position, required int total}) =>
    total <= 1 ? 0 : (position.clamp(1, total) - 1) / (total - 1);

/// A count as the design sets it: `1` of `8` reads `01 / 08`.
///
/// Counts of three digits or more are left as they are — padding is the
/// design's fixed-width look for a short run, not a truncation.
String zeroPadded(int count) => count.toString().padLeft(2, '0');
