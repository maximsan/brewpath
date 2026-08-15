// Self-descriptive UI string constants — no per-member docs needed.
// ignore_for_file: public_member_api_docs

/// User-facing string constants.
abstract class AppLabels {
  static const appName = 'BrewPath';
  static const tabLearn = 'Learn';
  static const tabPath = 'Path';
  static const tabCards = 'Cards';
  static const tabProfile = 'Profile';
  static const lockedModuleMessage =
      'Complete the previous module to unlock this one.';
  static const continueLabel = 'Continue';

  /// Announced for a finished module. The design signals completion by
  /// *removing* the trailing chevron and the lesson-count line, which leaves a
  /// screen reader nothing to read — so the state is carried here instead.
  static String moduleCompleteSemantics(String title) => '$title, complete';
}
