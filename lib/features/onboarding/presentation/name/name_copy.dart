/// Every word the onboarding name step says.
library;

/// The step's strings, as the design writes them.
abstract final class NameCopy {
  /// The question.
  static const title = 'And you are…?';

  /// The line under it, which says why the app is asking.
  static const support = 'Just a first name — it’s how Roasty greets you.';

  /// The empty field's prompt, and what a screen reader calls the field.
  static const placeholder = 'Your first name';

  /// The action that keeps the name.
  static const continueLabel = 'Continue';

  /// The action that does not. Named for the learner's benefit, not the
  /// app's: it says the question can come back, which Settings makes true.
  static const skip = 'Skip for now';
}
