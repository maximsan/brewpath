/// Keep Sharp: the pure rotation behind the Today card's caught-up state.
///
/// The pick is a function of the local calendar day and nothing else — no
/// stored pick, no history — so it is stable for the day by construction and
/// there is nothing to clear on reset. Ruled in #56; build shape in #120.
library;

import 'package:brew_path/core/utils/date_utils.dart';
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

/// The day's resolution: which practice type, and the one screen its CTA opens.
typedef KeepSharpResolution = ({
  PracticeType type,
  RouteDestination destination,
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
  required List<String> playableFormatIds,
  required Set<String> formatsPlayedToday,
  required List<String> completedLessonIds,
}) {
  final eligible = {
    if (playableFormatIds.length >= miniGamesPerQualifyingDay)
      PracticeType.miniGames,
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
    // Gated out by `builtPracticeSurfaces` until their surfaces register.
    PracticeType.vocabGame || PracticeType.flashcards => null,
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
