/// The rules a calibrate card is judged by, with no widget attached.
///
/// A calibrate round is one value on a fixed track, a target somewhere along
/// it, and a tolerance either side. The learner drags, commits, and the card
/// pays its one success signal only if the committed value landed inside the
/// band — a single all-or-nothing verdict, never a distance score, because a
/// fraction here would have to mean something to mastery and mastery counts
/// whole cards. See `card_boundary.dart`.
///
/// The arithmetic lives here so "is 62 inside 55 ± 14", "which band does 88
/// read as" and "where does the band sit on the track" are answerable without
/// pumping a widget (#124).
library;

/// The low end of the track. Every authored target and tolerance is on this
/// scale, so nothing rescales between the bank and the dial.
const double sliderTrackMin = 0;

/// The high end of the track.
const double sliderTrackMax = 100;

/// Where the handle rests before the learner has touched it — dead centre, so
/// no round opens leaning toward either end.
const double sliderTrackStart = 50;

/// The span the track covers, named because the band arithmetic divides by it.
const double sliderTrackSpan = sliderTrackMax - sliderTrackMin;

/// Which of [bandCount] descriptive bands [value] reads as.
///
/// The bands divide the track evenly and are what the learner actually reads —
/// "Sea salt — pour-over" rather than 71. The top of the track belongs to the
/// last band rather than to a band past the end of the list, which is the whole
/// of the clamp below and the reason it is not left to the division alone.
///
/// A round with no scale has no band to name, and asking for one is a
/// programming error rather than a value to fall back on.
int sliderBandIndex({required double value, required int bandCount}) {
  assert(bandCount > 0, 'a track with no bands has nothing to read back');
  final width = sliderTrackSpan / bandCount;
  final band = ((value - sliderTrackMin) / width).floor();
  return band.clamp(0, bandCount - 1);
}

/// Whether a committed [value] landed inside the target band.
///
/// Inclusive at both edges: the band the card draws is the band it grades, and
/// a learner who lands exactly on the edge of the zone they can see has to be
/// right or the drawing is a lie.
bool sliderWithinTarget({
  required double value,
  required double target,
  required double tolerance,
}) => (value - target).abs() <= tolerance;

/// Whether this round is about grind size, and so draws the grinder's collar.
///
/// Read off the round's own end labels, which is the test the design source
/// makes: `FINER`/`COARSER` is the vocabulary of exactly one axis, and it is
/// the one axis a real grinder has a numbered part for. The alternative — a
/// field on the card saying "draw the dial" — would put a rendering decision
/// in the content bank, which the extractor would then have to author.
bool sliderIsGrind({required String leftLabel, required String rightLabel}) =>
    leftLabel == 'FINER' && rightLabel == 'COARSER';

/// The accepted band as a span of the track, clamped to its ends.
///
/// Returned as a start and a width rather than two ends because that is what
/// drawing it needs, and computing the width at the call site is where the
/// clamp gets forgotten: a target near either end has a band that runs off the
/// track, and an unclamped width paints past it.
({double start, double width}) sliderTargetZone({
  required double target,
  required double tolerance,
}) {
  final start = (target - tolerance).clamp(sliderTrackMin, sliderTrackMax);
  final end = (target + tolerance).clamp(sliderTrackMin, sliderTrackMax);
  return (start: start, width: end - start);
}
