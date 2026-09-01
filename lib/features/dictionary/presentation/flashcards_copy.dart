/// Every word the flashcards drill says, in one place.
///
/// Authored once because four surfaces name this drill — the dictionary chip,
/// the shelf's study row, the Learn tab's practice row and the drill itself —
/// and a screen that calls itself something its entry point does not is two
/// features to a learner.
library;

/// The drill's copy, verbatim from `prototype/dictionary-extras.jsx:118-278`
/// unless a line is noted otherwise.
abstract final class FlashcardsCopy {
  /// The screen's name, and what every entry point calls it.
  static const title = 'Flashcards';

  /// The empty state's whole explanation: what a deck is made of, and how to
  /// make one. It teaches rather than apologises, which is why the screen
  /// opens at all when there is nothing to deal.
  static const emptyBody =
      'Bookmark terms in the dictionary and they become a flashcard deck '
      'here — flip to test yourself.';

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

  /// Walking the deck.
  static const previous = 'Prev';

  /// The action on every card but the last.
  static const next = 'Next';

  /// The action on the last card, which ends the review.
  static const finish = 'Finish';

  /// Re-deals the same cards in a new order.
  static const shuffle = 'Shuffle deck';

  /// The results kicker.
  static const resultsKicker = 'Flashcards';

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

  /// The shelf's row into the drill (`library.jsx:197`).
  static String studyRow(int cards) =>
      'Study $cards ${cards == 1 ? 'term' : 'terms'} as flashcards';

  /// The eyebrow on the Learn tab's practice row (`screens.jsx:950`).
  static const practiceRowEyebrow = 'Flip and recall';
}
