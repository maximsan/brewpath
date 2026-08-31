// Self-descriptive UI string constants — no per-member docs needed.
// ignore_for_file: public_member_api_docs

/// User-facing string constants.
abstract class AppLabels {
  static const appName = 'BrewPath';
  // The design names the first tab for the day rather than the verb — the same
  // word its header eyebrow already used. The branch behind it stays `/learn`.
  // The bar letters these uppercase; that is the tab bar's type rule, so it is
  // applied where the bar is built, never frozen into the words themselves.
  static const tabToday = 'Today';
  static const tabPath = 'Path';
  static const tabCards = 'Cards';
  static const tabProfile = 'Profile';
  static const continueLabel = 'Continue';

  // The module ending. `MODULE COMPLETE` is the kicker and the module's own
  // name is the headline — the design's way up, which the app had inverted.
  static const moduleCompleteKicker = 'Module complete';
  static const moduleCompleteTitle = "Look how far you've come.";
  static const rewardWaiting = 'A reward card is waiting on the other side.';
  static const turnItOver = 'Turn it over';
  static const flipBack = 'Flip back';
  static const rewardUnlocked = 'Reward unlocked';
  static const newCollectibleCard = 'New collectible card';
  static const beginNextModule = 'Begin next module';
  static const backToPath = 'Back to Path';
  static const close = 'Close';

  /// What a screen reader is told the tree is showing.
  static String treeAtStage(int stage) => 'Your coffee tree, stage $stage';

  // The eyebrow under the lesson the learner is on, in the path's own
  // list. Announced as written; the row letters it.
  static const currentLesson = 'Current';

  // The eyebrow over the day's lead card. It names which of the card's two
  // states is showing, which is the only thing distinguishing a Keep Sharp
  // pick from a lesson at a glance.
  static const continueLearning = 'Continue learning';
  static const allCaughtUp = 'All caught up';

  // Practice is one section with two groups under it, which is how the design
  // names them: `PRACTICE`, then `Lessons` and `Games`.
  static const practiceSection = 'Practice';
  static const practiceLessonsGroup = 'Lessons';
  static const practiceGamesGroup = 'Games';

  /// Announced for a finished module. The design signals completion by
  /// *removing* the trailing chevron and the lesson-count line, which leaves a
  /// screen reader nothing to read — so the state is carried here instead.
  static String moduleCompleteSemantics(String title) => '$title, complete';
}
