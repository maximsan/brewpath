/// Keep Sharp: the pure rotation behind the Today card's caught-up state.
///
/// The pick is a function of the local calendar day and nothing else — no
/// stored pick, no history — so it is stable for the day by construction and
/// there is nothing to clear on reset. Ruled in #56; build shape in #120.
library;

import 'package:brew_path/core/utils/date_utils.dart';

/// The four practice types Keep Sharp rotates over, in canonical order.
///
/// The declaration order **is** the rotation order; `keepSharpPick` indexes
/// into [values] directly.
enum PracticeType {
  /// Standalone game rounds (currently the game-type practice drills).
  miniGames,

  /// The vocabulary game. No surface yet; registers when built.
  vocabGame,

  /// Flashcard review of saved terms. No surface yet; registers when built.
  flashcards,

  /// Replaying a completed lesson.
  lessonReplay,
}

/// The practice types with a surface in this build. Vocab game and flashcards
/// have no screens yet; they join the rotation by joining this set — no
/// schema change, no new decision (#120's eligibility registry).
const Set<PracticeType> builtPracticeSurfaces = {
  PracticeType.miniGames,
  PracticeType.lessonReplay,
};

/// The day's recommendation: the type at the day's index in rotation order,
/// advancing past ineligible types. Returns null when nothing is eligible.
PracticeType? keepSharpPick({
  required int dayNumber,
  required Set<PracticeType> eligible,
}) {
  const order = PracticeType.values;
  for (var offset = 0; offset < order.length; offset++) {
    final candidate = order[(dayNumber + offset) % order.length];
    if (eligible.contains(candidate)) return candidate;
  }
  return null;
}

/// Index of [date]'s local calendar day — [epochDay]'s scheme, so the
/// rotation and the snapshot's day-valued fields agree on what "a day" is.
int keepSharpDayNumber(DateTime date) => epochDay(date);

/// The day's pick from a list of concrete entry points (a game type to open,
/// a lesson to replay). Same day number as the rotation, so the CTA's target
/// is stable all day and stores nothing — while the recommendation itself
/// stays type-level.
T keepSharpDailyChoice<T>(int dayNumber, List<T> options) =>
    options[dayNumber % options.length];

/// Card copy for one practice type: what it is called, and the type's own
/// completion rule — stated on the card so doing what Today asks always
/// protects the streak (the reason item-level recommendation was rejected).
typedef KeepSharpCopy = ({String title, String rule});

/// The copy table, authored once against the product rulings (§5/§6) so the
/// rule text cannot drift between surfaces.
KeepSharpCopy keepSharpCopyFor(PracticeType type) => switch (type) {
  PracticeType.miniGames => (
    title: 'Mini-games',
    rule: 'Play two different games today.',
  ),
  PracticeType.vocabGame => (
    title: 'Vocab game',
    rule: 'Finish one vocab round.',
  ),
  PracticeType.flashcards => (
    title: 'Flashcards',
    rule: 'Review your saved terms.',
  ),
  PracticeType.lessonReplay => (
    title: 'Replay a lesson',
    rule: "Finish a replay of any lesson you've completed.",
  ),
};
