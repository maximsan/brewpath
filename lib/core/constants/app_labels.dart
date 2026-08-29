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
