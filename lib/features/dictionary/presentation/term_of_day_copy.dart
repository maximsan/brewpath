/// Every word Term of the Day says, in one place.
///
/// Two surfaces name it — the banner on the dictionary's index and the screen
/// that banner opens — and a screen that calls itself something its entry point
/// does not is two features to a learner.
library;

/// The drill's copy, verbatim from the design's banner and its screen unless
/// noted otherwise.
abstract final class TermOfDayCopy {
  /// The kicker both surfaces open with, and the screen's name.
  static const title = 'Term of the Day';

  /// The banner's footer, which says what tapping it does.
  static const openEntry = 'Open entry';

  /// The screen's one action.
  ///
  /// **It promises the full entry**, so for a learner without the course it
  /// must raise the gate rather than deliver the short explanation they are
  /// already reading, which the design says in as many words.
  static const readFullEntry = 'Read the full entry';

  /// The screen's way out, under the action.
  static const back = 'Back';
}
