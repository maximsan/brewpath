/// Keep Sharp: the pure rotation behind the Today card's caught-up state.
///
/// The pick is a function of the local calendar day and nothing else — no
/// stored pick, no history — so it is stable for the day by construction and
/// there is nothing to clear on reset. Ruled in #56; build shape in #120.
library;

import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_destination.dart';
import 'package:brew_path/features/dictionary/domain/vocab_destination.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_destination.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';

/// The four practice types Keep Sharp rotates over, in canonical order.
///
/// The declaration order **is** the rotation order; `keepSharpPick` indexes
/// into [values] directly.
enum PracticeType {
  /// Standalone mini-games — the authored formats, played from their own
  /// intro. Two different ones mark the day (§5, #59).
  miniGames,

  /// The vocabulary game — *Guess the term*.
  vocabGame,

  /// Flashcard review of saved terms.
  flashcards,

  /// Replaying a completed lesson.
  lessonReplay,
}

/// The practice types with a surface in this build — all four, now that the
/// vocab game (#98) and flashcards (#97) have landed. A type joins the
/// rotation by joining this set: no schema change, no new decision (#120's
/// eligibility registry). The set stays, because the next practice type
/// authored joins it unruled and the registry is where someone says so.
const Set<PracticeType> builtPracticeSurfaces = {
  PracticeType.miniGames,
  PracticeType.vocabGame,
  PracticeType.flashcards,
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

/// The day's resolution: which practice type, and the one screen its CTA opens.
typedef KeepSharpResolution = ({
  PracticeType type,
  RouteDestination destination,
});

/// Everything the rotation is asked of — one value, not one parameter per
/// practice type.
///
/// It travels as a clump because it is one: every field is material some
/// type's eligibility rule reads, they are gathered from one place and passed
/// to one function, and the fifth type added here was the one that made the
/// argument list longer than the rule it feeds.
typedef PracticeMaterial = ({
  /// The mini-game formats this build can actually run.
  List<String> playableFormatIds,

  /// Which of them the learner already played today.
  Set<String> formatsPlayedToday,

  /// The lessons they have finished, which a replay picks from.
  List<String> completedLessonIds,

  /// How many terms their tier can be drilled on (ADR-0014).
  int drillableTermCount,

  /// How many of those they have bookmarked — the flashcard deck.
  int flashcardDeckSize,
});

/// The whole recommendation, as a function of the day and the learner's
/// material. No clock, no storage, no widgets — the caller supplies the day.
///
/// **Eligibility is the type's own rule, asked of the material.** Mini-games
/// need [miniGamesPerQualifyingDay] playable formats, because that is what the
/// card's rule demands; a card must never ask for something the learner's
/// material makes impossible.
KeepSharpResolution? keepSharpResolutionFor({
  required int dayNumber,
  required PracticeMaterial material,
}) {
  final (
    :playableFormatIds,
    :formatsPlayedToday,
    :completedLessonIds,
    :drillableTermCount,
    :flashcardDeckSize,
  ) = material;

  final eligible = {
    if (playableFormatIds.length >= miniGamesPerQualifyingDay)
      PracticeType.miniGames,
    // The drill's own rule, asked of the learner's material: a pool that
    // cannot fill four options cannot honestly be recommended, and the card
    // must never ask for something the material makes impossible.
    if (drillableTermCount >= vocabMinimumPool) PracticeType.vocabGame,
    // The one type whose material is the learner's own bookmarks rather than
    // the course's content, so an empty pool is an ordinary state rather than
    // a gap. Recommending it then sends them to a screen that can only
    // explain why it has nothing for them.
    if (flashcardDeckSize > 0) PracticeType.flashcards,
    if (completedLessonIds.isNotEmpty) PracticeType.lessonReplay,
  }.intersection(builtPracticeSurfaces);

  final pick = keepSharpPick(dayNumber: dayNumber, eligible: eligible);
  return switch (pick) {
    null => null,
    PracticeType.miniGames => (
      type: pick,
      destination: miniGameRun(
        _nextUnplayed(dayNumber, playableFormatIds, formatsPlayedToday),
      ),
    ),
    PracticeType.lessonReplay => (
      type: pick,
      destination: lessonRun(
        keepSharpDailyChoice(dayNumber, completedLessonIds),
      ),
    ),
    // The drill's setup, not a round: the deck and the length are the
    // learner's to choose, and dealing straight into a round takes that away.
    PracticeType.vocabGame => (type: pick, destination: vocabGame),
    // No setup to choose and nothing to parameterise: the deck is whatever
    // the learner has bookmarked.
    PracticeType.flashcards => (type: pick, destination: flashcardReview),
  };
}

/// The day's game, skipping any already played today.
///
/// Skipping is what makes the card honest. The rule is "two different games",
/// so a pick that stayed fixed all day would send the learner back into the
/// game they just finished, and pressing Start twice could never satisfy the
/// card — this ticket's own defect, one layer down.
///
/// Once every playable format has been played the rule is already met and the
/// card stops offering a CTA; the fall back to the full list exists because
/// [keepSharpDailyChoice] indexes modulo length and an empty list would throw.
String _nextUnplayed(
  int dayNumber,
  List<String> playable,
  Set<String> playedToday,
) {
  final remaining = [
    for (final id in playable)
      if (!playedToday.contains(id)) id,
  ];
  return keepSharpDailyChoice(
    dayNumber,
    remaining.isEmpty ? playable : remaining,
  );
}
