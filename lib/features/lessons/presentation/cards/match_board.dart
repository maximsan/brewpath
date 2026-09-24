/// The rules a match board is judged by, with no widget attached.
///
/// A board clears when every fact is placed, but pays only when it clears
/// with no wrong drop — all-or-nothing, so a board finished the hard way
/// scores zero and still lets the learner move on. Kept here so the rule is
/// unit-testable and the widget holds none of it (#122).
library;

import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';

/// The distinct answers the facts sort into, in first-appearance order.
///
/// Order is deliberately stable: the display shuffle is seeded by the host,
/// so this must not introduce a second, unseeded source of order.
List<String> matchTargets(Iterable<MatchPair> pairs) {
  final targets = <String>[];
  for (final pair in pairs) {
    if (!targets.contains(pair.right)) targets.add(pair.right);
  }
  return targets;
}

/// Whether [pair] belongs under [target].
bool matchAccepts(MatchPair pair, String target) => pair.right == target;

/// Whether every fact has been placed. An empty board never clears — there is
/// nothing to have achieved.
bool matchBoardCleared({required int solvedCount, required int total}) =>
    total > 0 && solvedCount >= total;

/// Whether the board earns the card's one success signal: cleared, and
/// cleared without a wrong drop.
bool matchBoardPaysSignal({required bool cleared, required bool faulted}) =>
    cleared && !faulted;

/// What a finished board is called: clean, or the drops it cost.
///
/// The design names the cost rather than only the miss — `2 WRONG DROPS` — so
/// the count has to reach the wording, and the singular has to be right at one.
/// Here rather than in the widget so it can be checked without pumping a board.
String matchBoardVerdict(AppLocalizations strings, int wrongDrops) =>
    wrongDrops == 0
    ? strings.matchCleanBoard
    : strings.matchWrongDrops(wrongDrops);
