/// Everything *Guess the term* says, in one place.
///
/// The drill's words live apart from its screens for the reason every copy
/// table in this app does: a string that appears on a screen is a string that
/// appears in a test, and hunting the same sentence through three widgets is
/// how two of them end up disagreeing.
library;

import 'package:brew_path/core/utils/drill_bands.dart';
import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';

/// The drill's name, on every surface that opens it.
abstract final class VocabCopy {
  /// The screen's name, and the label of every entry point.
  static const title = 'Guess the term';

  /// The eyebrow on a practice row — what the drill asks of you.
  static const rowSubtitle = 'From the definition';

  /// The line under the title on setup.
  static const setupBlurb =
      'Read a definition, pick the term. Choose your deck and how long a '
      'round you want.';

  /// The two section headings on setup.
  static const deckHeading = 'Deck';

  /// Heading over the length choices.
  static const lengthHeading = 'Round length';

  /// The names of the three offered lengths, by round count.
  static const lengthNames = {5: 'Quick', 8: 'Standard', 12: 'Deep'};

  /// The Saved deck's row.
  static const savedDeck = 'Saved terms';

  /// What the Saved deck offers, once it has enough on it.
  static const savedDeckReady = 'The terms you have bookmarked';

  /// What it says before then. Stated as the number it needs, so the row
  /// explains itself rather than only refusing.
  static const savedDeckShort =
      'Save $vocabMinimumPool or more terms to unlock';

  /// The Misses deck's row.
  static const missesDeck = 'Review misses';

  /// What the Misses deck offers, once enough terms are owed a review.
  static const missesDeckReady = 'Terms you have missed before';

  /// What it says before then. Not phrased as an instruction the way the
  /// Saved deck's is: nobody sets out to miss four questions, so the row
  /// states the condition rather than asking for it.
  static const missesDeckShort = 'Miss a few first';

  /// The All deck's row, for a learner who owns the course.
  static const allDeck = 'Whole glossary';

  /// The All deck's row for a free learner — *their* terms, which is the
  /// honest name for a pool the course scoped rather than the shelf did.
  static const yourTermsDeck = 'Your terms';

  /// What the All deck holds, by tier.
  static const allDeckNote = 'Every term in the dictionary';

  /// What a free learner's All deck holds. *Mentioned*, not taught —
  /// ADR-0014's rule, and the difference is a term a lesson named in
  /// passing without stopping to teach it.
  static const yourTermsNote = 'Every term your lessons mention';

  /// The whole-deck length card, shown when no offered length fits.
  static const wholeDeck = 'Every term in this deck';

  /// What a deck row says: its name, and what it holds.
  ///
  /// One lookup rather than a switch per line, so a fourth deck is a case
  /// here and nowhere else — the row was drifting towards a cascade for the
  /// title and a second, differently-shaped one for the note.
  static ({String title, String note}) deckRow(
    VocabDeck deck, {
    required bool hasCourse,
    required bool available,
  }) => switch (deck) {
    VocabDeck.saved => (
      title: savedDeck,
      note: available ? savedDeckReady : savedDeckShort,
    ),
    // Calling a free learner's pool "the whole glossary" would be a claim
    // their own dictionary screen contradicts — it shows every entry to
    // everyone, and the drill reaches only part of it.
    VocabDeck.all =>
      hasCourse
          ? (title: allDeck, note: allDeckNote)
          : (title: yourTermsDeck, note: yourTermsNote),
    VocabDeck.misses => (
      title: missesDeck,
      note: available ? missesDeckReady : missesDeckShort,
    ),
  };

  /// The nudge under a short Saved deck.
  static const longerRoundsHint =
      'Longer rounds unlock as you bookmark more terms.';

  /// The same nudge under a short Misses deck, which grows a different way.
  static const longerMissRoundsHint =
      'Longer rounds unlock as you log more misses.';

  /// Starts the drill.
  static const start = 'Start round';

  /// The question's lead-in.
  static const questionLead = 'Which term means…';

  /// Advances past an answered question.
  static const next = 'Next question';

  /// Ends the last question.
  static const seeScore = 'See score';

  /// The link out of an answered question into the full entry.
  static const readEntry = 'See the full entry';

  /// Runs the drill again, with a fresh draw.
  static const playAgain = 'Play again';

  /// Returns to setup to pick a different deck or length.
  static const changeRound = 'Change round';

  /// The teaching state's heading — shown when the pool cannot fill a
  /// question. It never pads from the full glossary, so it says what would
  /// actually help instead.
  static const teachingTitle = 'A few more terms first';

  /// The teaching state's body.
  static const teachingBody =
      'The game draws on the terms your lessons mention, and it needs at '
      'least $vocabMinimumPool. Play a lesson or two and come back.';

  /// The teaching state's way out.
  static const teachingAction = 'Back to learning';

  /// What a screen reader is told while the pools resolve.
  static const loading = 'Loading the drill';

  /// And when they do not resolve.
  static const loadFailed = 'This drill could not be loaded.';

  /// What a screen reader announces for the drill's progress.
  static String progress(int position, int total) =>
      'Question $position of $total';

  /// What a screen reader announces for a choice once it has been answered.
  static String answeredChoice(String term, {required bool isCorrect}) =>
      '$term, ${isCorrect ? 'correct' : 'incorrect'}';

  /// The verdict over an answered question.
  ///
  /// The wrong line names the term, which is the whole teaching moment — and
  /// it is built from [notQuiteVerdict] rather than spelling the words again.
  static String verdict(String answer, {required bool isCorrect}) =>
      isCorrect ? correctVerdict : "$notQuiteVerdict — it's $answer";

  /// The right-answer line.
  static const correctVerdict = 'Correct';

  /// What the score adds about the review deck, for a drill drawn from
  /// [fromReviewDeck] that missed [count] terms.
  ///
  /// The design writes only the *added* half, which is false on the one deck
  /// the line is read on most: a term missed while drilling the review deck
  /// was already in it and stayed. The divergence is registered in
  /// `docs/design/11-open-items.md`.
  static String reviewDeckLine(int count, {required bool fromReviewDeck}) {
    if (count == 0) return '';
    final terms = count == 1 ? 'term' : 'terms';
    final verb = count == 1 ? 'was' : 'were';
    return fromReviewDeck
        ? ' The $count $terms you missed $verb kept in your review deck.'
        : ' The $count $terms you missed $verb added to your review deck.';
  }

  /// The line under the score.
  ///
  /// The bands are the drills' shared ones; only these words are the vocab
  /// game's own.
  static String encouragement({required int score, required int total}) {
    if (total == 0) return 'Nothing to drill here yet.';
    if (score == total) return 'Every one of them. That is the whole deck.';
    if (isCelebratoryScore(score: score, total: total)) {
      return 'Sharp palate. You know these cold.';
    }
    if (isMiddlingScore(score: score, total: total)) {
      return 'Solid round — run it back to sharpen up.';
    }
    return 'Worth another pass. The definitions stick faster the second time.';
  }
}
