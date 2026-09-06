/// Every word the Tour says, in one place.
///
/// The copy is **locked** by the Tour spec (the resolution of
/// [#195](https://github.com/maximsan/brewpath/issues/195)) — it was reviewed
/// as a set, and each stop was written to explain a *mechanic* rather than to
/// name the widget it points at. Editing a string here edits the spec, not the
/// implementation; a change belongs in a ticket that reopens the ruling.
///
/// They live apart from the widgets that render them so the whole script can be
/// read in scroll order without reading a widget tree, and so the widget tests
/// can assert the words without restating them.
abstract final class TourCopy {
  /// The intro overlay's heading.
  static const introTitle = 'Quick tour?';

  /// The intro overlay's one line of body copy.
  static const introBody =
      'Four stops, thirty seconds — see how BrewPath works.';

  /// The intro overlay's accept button. Answering *either* button writes
  /// `tourSeen`; only this one runs the stops.
  static const introAccept = 'Show me';

  /// The intro overlay's decline button.
  static const introDecline = 'Skip';

  /// Screen-reader label for the intro overlay as a whole.
  static const introSemanticLabel =
      'Quick tour. Four stops, thirty seconds — see how BrewPath works.';

  /// Stop 1 — the Today card.
  static const todayTitle = 'One lesson a day.';

  /// Stop 1's body.
  static const todayBody =
      'Your next Foundations lesson is always here. Finish any activity today '
      'and your streak is safe.';

  /// Stop 2 — the practice area: the replay list and the mini-games together.
  static const practiceTitle = 'Practice, your way.';

  /// Stop 2's body.
  static const practiceBody =
      'Replay finished lessons to raise your mastery, or play a mini-game — '
      'practice protects your streak too.';

  /// Stop 3 — the header's Saved and Dictionary entries.
  ///
  /// The design's own third stop. It used to be the module list, which was
  /// never the design's — and the course's own "five modules, in order" line is
  /// already stop 4's job, where the Path tab it names is what the learner is
  /// being pointed at.
  static const headerTitle = 'Saved and Dictionary.';

  /// Stop 3's body.
  static const headerBody =
      'Anything you bookmark lands behind the ribbon; every coffee term you '
      'meet joins the book beside it.';

  /// Stop 4 — the bottom tab bar.
  static const tabsTitle = 'And beyond.';

  /// Stop 4's body.
  static const tabsBody =
      'Path grows your coffee tree, Cards keeps your collection, Profile holds '
      'your streak and settings.';

  /// The card's left-hand button, on every stop — the way out the shipped Tour
  /// had none of. Spelled apart from [introDecline] even though the word is
  /// the same: one answers the offer, the other abandons a run, and either can
  /// be re-worded without dragging the other with it.
  static const stopSkip = 'Skip';

  /// The card's right-hand button on stops 1–3.
  static const stopNext = 'Next';

  /// The same button on the last stop, where advancing *is* finishing.
  static const stopDone = 'Done';

  /// The App Guide row that replays the Tour.
  static const replayTitle = 'Replay Today introduction';

  /// That row's supporting line.
  static const replayBody = 'Runs the short first-open tour again';
}
