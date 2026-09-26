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
import 'package:brew_path/features/learn/domain/practice_group.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter/foundation.dart';

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

/// Card copy for one practice type: what it is called, and the type's own
/// completion rule — stated on the card so doing what Today asks always
/// protects the streak (the reason item-level recommendation was rejected).
typedef KeepSharpCopy = ({String title, String rule});

/// The copy table, authored once against the product rulings (§5/§6) so the
/// rule text cannot drift between surfaces.
KeepSharpCopy keepSharpCopyFor(AppLocalizations strings, PracticeType type) =>
    switch (type) {
      PracticeType.miniGames => (
        title: strings.keepSharpMiniGamesTitle,
        rule: strings.keepSharpMiniGamesRule,
      ),
      PracticeType.vocabGame => (
        title: strings.keepSharpVocabTitle,
        rule: strings.keepSharpVocabRule,
      ),
      PracticeType.flashcards => (
        title: strings.keepSharpFlashcardsTitle,
        rule: strings.keepSharpFlashcardsRule,
      ),
      PracticeType.lessonReplay => (
        title: strings.keepSharpReplayTitle,
        rule: strings.keepSharpReplayRule,
      ),
    };

/// What Keep Sharp's Start does for the day's type.
///
/// Never a specific item: the rule, not the card, names the work. A type
/// whose material is listed on the Today tab has its group opened; a drill
/// with a surface of its own is opened there.
sealed class KeepSharpStart {
  const KeepSharpStart();
}

/// Opens one of the practice list's groups, leaving the item to the learner.
@immutable
final class OpenPracticeGroup extends KeepSharpStart {
  /// Creates a start that opens [group].
  const OpenPracticeGroup(this.group);

  /// The group the day's type lives in.
  final PracticeGroupKind group;

  @override
  bool operator ==(Object other) =>
      other is OpenPracticeGroup && other.group == group;

  @override
  int get hashCode => group.hashCode;
}

/// Opens a drill's own surface.
@immutable
final class OpenSurface extends KeepSharpStart {
  /// Creates a start that goes to [destination].
  const OpenSurface(this.destination);

  /// The screen the CTA opens.
  final RouteDestination destination;

  @override
  bool operator ==(Object other) =>
      other is OpenSurface && other.destination == destination;

  @override
  int get hashCode => destination.hashCode;
}

/// The day's resolution: which practice type, and what its CTA does.
typedef KeepSharpResolution = ({PracticeType type, KeepSharpStart start});

/// Everything the rotation is asked of — one value, not one parameter per
/// practice type.
///
/// Every field is material some type's eligibility rule reads, gathered from
/// one place and passed to one function.
typedef PracticeMaterial = ({
  /// The mini-game formats this build can actually run.
  List<String> playableFormatIds,

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
/// Eligibility is the type's own rule asked of the material, so a card never
/// asks for something the learner's material makes impossible.
KeepSharpResolution? keepSharpResolutionFor({
  required int dayNumber,
  required PracticeMaterial material,
}) {
  final (
    :playableFormatIds,
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
    // The two types whose work is listed on the Today tab open their group
    // and stop there: which game, or which lesson, is the learner's to pick,
    // and a lesson chosen from the list is asked about first (#573).
    PracticeType.miniGames => (
      type: pick,
      start: const OpenPracticeGroup(PracticeGroupKind.games),
    ),
    PracticeType.lessonReplay => (
      type: pick,
      start: const OpenPracticeGroup(PracticeGroupKind.lessons),
    ),
    // The drill's setup, not a round: the deck and the length are the
    // learner's to choose, and dealing straight into a round takes that away.
    PracticeType.vocabGame => (type: pick, start: OpenSurface(vocabGame)),
    // No setup to choose and nothing to parameterise: the deck is whatever
    // the learner has bookmarked.
    PracticeType.flashcards => (
      type: pick,
      start: OpenSurface(flashcardReview),
    ),
  };
}
