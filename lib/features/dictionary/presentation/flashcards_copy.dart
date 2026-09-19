/// Every word the flashcards drill says, in one place.
///
/// Authored once because four surfaces name this drill — the dictionary chip,
/// the shelf's study row, the Learn tab's practice row and the drill itself —
/// and a screen that calls itself something its entry point does not is two
/// features to a learner.
library;

/// Every line is the design's own, verbatim, unless noted otherwise.
abstract final class FlashcardsCopy {
  /// The screen's name, and what every entry point calls it.
  static const title = 'Flashcards';

  /// The empty state's whole explanation: what a deck is made of, and how to
  /// make one. It teaches rather than apologises, which is why the screen
  /// opens at all when there is nothing to deal.
  static const emptyBody =
      'Bookmark terms in the dictionary and they become a flashcard deck '
      'here — flip to test yourself.';

  /// The empty state's other body: they *did* bookmark, and none of it is a
  /// word their free lessons cover, so the line above would be a lie (#468).
  /// Not the design's — its dictionary is gated, so it never had this state.
  /// Names both ways out, because both are real.
  static const emptyOutOfReachBody =
      'The terms you saved are not in your free lessons, so there is nothing '
      'to flip yet. Bookmark a term one of your lessons mentions, or unlock '
      'the full course to practise all of them.';

  /// The empty state's one action.
  static const browse = 'Browse the dictionary';

  /// The label over the front face.
  static const front = 'Term';

  /// The label over the back face.
  static const back = 'Definition';

  /// The foot of the front face — what a tap will do.
  static const tapToReveal = 'Tap to reveal';

  /// The foot of the back face.
  static const tapToSeeTerm = 'Tap to see term';

  /// The link under a revealed card.
  static const viewEntry = 'View full entry';

  /// The action on the last card, which ends the review.
  ///
  /// The only button the deck keeps: completing it is the one state a swipe
  /// cannot announce. Prev and Next are gone — they used the opposite
  /// direction model to the gesture, and the stack behind the card now says
  /// the deck can be moved through.
  static const finish = 'Finish';

  /// The focus-revealed pair, which the pointer user never sees.
  static const previousCard = 'Previous card';
  static const nextCard = 'Next card';

  /// Re-deals the same cards in a new order.
  static const shuffle = 'Shuffle deck';

  /// What the results number counts.
  static String reviewedNote(int cards) =>
      cards == 1 ? 'Term reviewed' : 'Terms reviewed';

  /// The results message.
  static const resultsMessage =
      'That’s every term you’ve saved. Run it back shuffled, or bookmark more '
      'in the dictionary.';

  /// The results' primary action.
  static const goAgain = 'Shuffle and go again';

  /// The results' way out.
  static const done = 'Done';

  /// The line over the deck: how many cards are in it.
  static String deckLine(int cards) =>
      '$cards saved ${cards == 1 ? 'term' : 'terms'}';

  /// The shelf's row into the drill.
  static String studyRow(int cards) =>
      'Study $cards ${cards == 1 ? 'term' : 'terms'} as flashcards';

  /// The eyebrow on the Learn tab's practice row.
  static const practiceRowEyebrow = 'Flip and recall';
}
