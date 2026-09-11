/// Every word the Tour says, in one place.
///
/// The four stops are the design's own `TOUR_STEPS`, word for word, ruled on
/// #536 (which reopened #195's set). Editing a stop here edits the design's
/// script, so a change belongs in a ticket that reopens the ruling. It lives
/// apart from the widgets that render it so the whole script reads in order.
abstract final class TourCopy {
  /// Stop 1 — the Today card.
  static const todayTitle = 'Today starts here';

  /// Stop 1's body.
  static const todayBody = 'Your next lesson always waits in this card.';

  /// Stop 2 — the practice area: the replay list and the mini-games together.
  static const practiceTitle = 'Practice again, any time';

  /// Stop 2's body.
  static const practiceBody =
      'Lessons you finish collect here, with quick practice formats beside '
      'them.';

  /// Stop 3 — the header's Saved and Dictionary entries.
  static const headerTitle = 'Saved and Dictionary';

  /// Stop 3's body.
  static const headerBody =
      'Anything you bookmark lands behind the ribbon; every coffee term you '
      'meet joins the book beside it.';

  /// Stop 4 — the bottom tab bar.
  static const tabsTitle = 'Find your way';

  /// Stop 4's body.
  static const tabsBody =
      'Path holds the whole course, Collection your earned cards, Profile your '
      'streak and coffee tree.';

  /// The card's left-hand button, on every stop — the way out.
  static const stopSkip = 'Skip';

  /// What Skip is announced as — the design's own `aria-label`, which says
  /// what is being skipped rather than leaving one word to stand alone in a
  /// screen reader's list of controls.
  static const stopSkipSemanticLabel = 'Skip the introduction';

  /// The card's right-hand button on stops 1–3.
  static const stopNext = 'Next';

  /// The same button on the last stop, where advancing *is* finishing.
  static const stopDone = 'Done';

  /// What assistive technology calls the running Tour — the design's own
  /// `aria-label` on the layer.
  static const layerSemanticLabel = 'Introduction to Today';

  /// The App Guide row that replays the Tour.
  static const replayTitle = 'Replay Today introduction';

  /// That row's supporting line.
  static const replayBody = 'Runs the short first-open tour again';
}
