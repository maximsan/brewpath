/// Every word the onboarding name step says.
library;

/// The step's strings, as the design writes them. The field's own prompt is
/// `LearnerName.placeholder`, shared with the Settings sheet that asks again.
abstract final class NameCopy {
  /// The question.
  static const title = 'And you are…?';

  /// The line under it, which says why the app is asking.
  static const support = 'Just a first name — it’s how Roasty greets you.';

  /// The action that keeps the name.
  static const continueLabel = 'Continue';

  /// The action that does not. Named for the learner's benefit, not the
  /// app's: it says the question can come back, which Settings makes true.
  static const skip = 'Skip for now';
}
