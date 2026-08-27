// Self-descriptive UI string constants — no per-member docs needed.
// ignore_for_file: public_member_api_docs

/// User-facing string constants.
abstract class AppLabels {
  static const appName = 'BrewPath';
  // The design letters the tab bar in smallcaps, and names the first tab for
  // the day rather than the verb — the same word its header eyebrow already
  // used. The branch behind it stays `/learn`.
  static const tabToday = 'TODAY';
  static const tabPath = 'PATH';
  static const tabCards = 'CARDS';
  static const tabProfile = 'PROFILE';
  static const lockedModuleMessage =
      'Complete the previous module to unlock this one.';
  static const continueLabel = 'Continue';

  /// Announced for a finished module. The design signals completion by
  /// *removing* the trailing chevron and the lesson-count line, which leaves a
  /// screen reader nothing to read — so the state is carried here instead.
  static String moduleCompleteSemantics(String title) => '$title, complete';
}
