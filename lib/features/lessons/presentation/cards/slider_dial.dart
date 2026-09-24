/// The rules a calibrate card is judged by, with no widget attached.
///
/// One value on a fixed track, a target, and a tolerance either side. The
/// verdict is all-or-nothing rather than a distance, because mastery counts
/// whole cards (`card_boundary.dart`); the arithmetic lives here so it can be
/// checked without pumping a widget (#124).
library;

import 'package:brew_path/l10n/generated/app_localizations.dart';

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

/// The words a round reads its track back in.
///
/// Almost always the round's own `scale`, which every shipped round carries.
/// One that carries none falls back to a scale built from its end labels, as
/// the design source does, so a position on the track always reads as
/// something concrete rather than a bare number.
List<String> sliderBands({
  required AppLocalizations strings,
  required List<String> scale,
  required String leftLabel,
  required String rightLabel,
}) => scale.isNotEmpty
    ? scale
    : [
        strings.sliderVeryLeft(leftLabel),
        leftLabel,
        strings.sliderMiddle,
        rightLabel,
        strings.sliderVeryLeft(rightLabel),
      ];

/// Which of [bandCount] descriptive bands [value] reads as.
///
/// The bands divide the track evenly. The top of the track belongs to the last
/// band rather than to one past the end of the list, which is what the clamp
/// below is for; asking for a band out of none is a programming error, since
/// [sliderBands] guarantees there are always some.
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
/// Read off the round's own end labels, as the design source does:
/// `FINER`/`COARSER` is the vocabulary of one axis, and a field on the card
/// saying "draw the dial" would put a rendering decision in the bank.
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
