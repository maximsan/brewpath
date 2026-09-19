/// Parking the challenge card, as arithmetic and as the numbers that set it.
///
/// Pure Dart beside the card, so the two opacities that carry the whole
/// affordance can be asserted without pumping a widget.
library;

/// How far the card must travel to park on release — `PARK_AT = 104`.
///
/// Set by the label rather than by feel: 104 past a 12px track inset uncovers
/// 92px of an ~84px destination label, so the destination reads whole at the
/// moment of release.
const double challengeParkAt = 104;

/// How far the card may move at all — `maxDragDistance: 190`.
const double challengeParkMaxDrag = 190;

/// How far a parked card flies before Today lets it go — `exitDistance: 340`.
const double challengeParkExit = 340;

/// The flight's length — `exitDurationMs: 240`.
const Duration challengeParkExitDuration = Duration(milliseconds: 240);

/// How far the first-run hint nudges the card, rightwards — `nudge: 38`.
const double challengeParkNudge = 38;

/// The travel at which the track is fully uncovered — `Math.min(1, dx / 60)`.
const double challengeTrackRevealAt = 60;

/// How far up the track behind the card has come at [offset].
///
/// A wrong-way drag uncovers nothing: left parks nothing, so there is no
/// destination to name.
double challengeTrackReveal(double offset) =>
    (offset / challengeTrackRevealAt).clamp(0.0, 1.0);

/// The chevron under the hint, before the gesture is used, and after —
/// `hint ? 1 : (used ? 0.35 : 0.7)`.
///
/// It steps back; it never retires. A Coffee Challenge surfaces roughly once
/// per module, so by the next card the gesture has been forgotten and — with
/// the hint spent — nothing on screen would recall it.
double challengeChevronOpacity({
  required bool hinting,
  required bool used,
}) {
  if (hinting) return 1;
  return used ? _chevronUsed : _chevronStanding;
}

const double _chevronStanding = 0.7;
const double _chevronUsed = 0.35;
