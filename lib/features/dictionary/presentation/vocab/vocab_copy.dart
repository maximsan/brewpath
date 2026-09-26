/// The pieces of *Guess the term* that are chosen rather than written.
///
/// The words are in `app_en.arb`; what is left here is which of them a deck,
/// a length or a score reaches for.
library;

import 'package:brew_path/core/utils/drill_bands.dart';
import 'package:brew_path/features/dictionary/domain/vocab_setup.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';

/// Which lines the drill picks per deck, length and score.
abstract final class VocabCopy {
  /// The name of an offered round length, or empty for one not offered.
  ///
  /// Indexed off [vocabLengths] rather than matched on the numbers, so the
  /// three names stay tied to the three lengths the setup screen offers.
  static String lengthName(AppLocalizations strings, int length) =>
      switch (vocabLengths.indexOf(length)) {
        0 => strings.vocabLengthQuick,
        1 => strings.vocabLengthStandard,
        2 => strings.vocabLengthDeep,
        _ => '',
      };

  /// What a deck row says: its name, and what it holds.
  ///
  /// One lookup rather than a switch per line, so a fourth deck is a case
  /// here and nowhere else.
  static ({String title, String note}) deckRow(
    AppLocalizations strings,
    VocabDeck deck, {
    required bool hasCourse,
    required bool available,
  }) => switch (deck) {
    VocabDeck.saved => (
      title: strings.vocabSavedDeck,
      note: available
          ? strings.vocabSavedDeckReady
          : strings.vocabSavedDeckShort(vocabMinimumPool),
    ),
    // Calling a free learner's pool "the whole glossary" would be a claim
    // their own dictionary screen contradicts — it shows every entry to
    // everyone, and the drill reaches only part of it.
    VocabDeck.all =>
      hasCourse
          ? (title: strings.vocabAllDeck, note: strings.vocabAllDeckNote)
          : (
              title: strings.vocabYourTermsDeck,
              note: strings.vocabYourTermsNote,
            ),
    VocabDeck.misses => (
      title: strings.vocabMissesDeck,
      note: available
          ? strings.vocabMissesDeckReady
          : strings.vocabMissesDeckShort,
    ),
  };

  /// What a screen reader is told about a choice once it has been answered.
  static String answeredChoice(
    AppLocalizations strings,
    String term, {
    required bool isCorrect,
  }) => isCorrect
      ? strings.vocabAnsweredChoiceCorrect(term)
      : strings.vocabAnsweredChoiceIncorrect(term);

  /// The verdict over an answered question.
  ///
  /// The wrong line names the term, which is the whole teaching moment.
  static String verdict(
    AppLocalizations strings,
    String answer, {
    required bool isCorrect,
  }) => isCorrect
      ? strings.vocabCorrectVerdict
      : strings.vocabVerdictWrong(strings.verdictNotQuite, answer);

  /// What the score adds about the review deck, for a drill drawn from
  /// [fromReviewDeck] that missed [count] terms.
  ///
  /// The design writes only the *added* half, false on the deck this is read
  /// on most: a term missed while drilling the review deck was already in it.
  static String reviewDeckLine(
    AppLocalizations strings,
    int count, {
    required bool fromReviewDeck,
  }) {
    if (count == 0) return '';
    return fromReviewDeck
        ? strings.vocabReviewDeckKept(count)
        : strings.vocabReviewDeckAdded(count);
  }

  /// The line under the score.
  ///
  /// The bands are the drills' shared ones; only these words are the vocab
  /// game's own.
  static String encouragement(
    AppLocalizations strings, {
    required int score,
    required int total,
  }) {
    if (total == 0) return strings.vocabNothingToDrill;
    if (score == total) return strings.vocabWholeDeckScore;
    if (isCelebratoryScore(score: score, total: total)) {
      return strings.vocabSharpPalate;
    }
    if (isMiddlingScore(score: score, total: total)) {
      return strings.vocabSolidRound;
    }
    return strings.vocabWorthAnotherPass;
  }
}
