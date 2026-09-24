/// One run of a mini-game: the order it plays in, and how it is judged.
///
/// Everything here is pure. A run writes nothing — no points, no tree growth,
/// no cards, no progress — so all of it is decided from a nonce and a score,
/// and all of it is testable without pumping a widget (#121).
library;

import 'package:brew_path/core/utils/drill_bands.dart';
import 'package:brew_path/features/lessons/domain/card_seed.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';

/// The games whose kind renderers exist in this build.
///
/// A registry, so a game is playable only when someone says so; read by the
/// intro's action and Keep Sharp, never by a row that would look paywalled.
/// Holds the whole catalog as of #124; two games once sat unplayable for want
/// of a line (#311), so the guard test pairs it with [deliberatelyNotPlayable].
const Set<String> playableMiniGameIds = {
  'g-quiz',
  'g-match',
  'g-quiz-roast-basics',
  'g-match-washed-natural',
  // The flavor kind serves both of these, so one renderer opened two games.
  // `g-flavor-origin-signatures` is the third free game ADR-0007 promises, and
  // was the 7 rounds standing between the free tier's advertised 18 and the 11
  // a learner could actually reach.
  'g-flavor',
  'g-flavor-origin-signatures',
  // Likewise two games on one kind: the pour-over cup and the shot.
  'g-tastefix',
  'g-tastefix-espresso',
  // The one kind with a single game, and the only one that is a real widget
  // rather than a picker with framing.
  'g-bagpick',
  // The last two kinds, and with them the last four games (#124). Neither is a
  // picker: calibrate commits a value against a band, sequence arranges steps
  // into an order.
  'g-calibrate',
  'g-calibrate-grind-brewer',
  'g-sequence',
  'g-sequence-v60',
};

/// Games that have rounds to play, kept out of [playableMiniGameIds] on
/// purpose.
///
/// Empty, and that is the point: an exclusion here carries a reason, where an
/// absence from the set above is indistinguishable from an oversight.
const Map<String, String> deliberatelyNotPlayable = <String, String>{};

/// Mints the nonce for one run. One draw per run, held for its duration and
/// never stored — see `card_seed.dart` for why storing it would defeat the
/// shuffle.
int mintRunNonce() => mintLessonNonce();

/// The rounds in the order this run plays them.
///
/// A permutation of the bank: every round appears exactly once, decided by
/// [nonce] alone, so the same nonce replays the same run and Play again — which
/// mints a fresh nonce — does not.
List<T> roundsForRun<T>(List<T> rounds, int nonce) =>
    shuffledBySeed(rounds, nonce);

/// The supporting line under the score.
String runEncouragement(
  AppLocalizations strings, {
  required int score,
  required int total,
}) {
  if (total == 0) return strings.drillNothingToPlay;
  if (score == total) return strings.drillCleanSweep;
  if (isCelebratoryScore(score: score, total: total)) {
    return strings.drillSharpWork;
  }
  if (score == 0) return strings.drillAllMissed;
  return strings.drillWorthAnotherRun;
}
