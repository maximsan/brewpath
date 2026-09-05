/// What the learner asked to be called, and the words the app asks with.
///
/// The name is written in two places — the onboarding name step and the
/// Settings name sheet — which the design draws as *"the identical input"*.
/// The cap, the prompt and the collapse live here once so the two fields
/// cannot drift apart.
abstract final class LearnerName {
  /// The design's cap on the field: longer than any name worth greeting.
  static const int maxLength = 24;

  /// The empty field's prompt, in both places the field appears.
  static const placeholder = 'Your first name';

  /// What a screen reader calls the field, and the sheet's title.
  static const sheetTitle = 'Your name';

  /// The line under the sheet's title.
  static const sheetBody =
      'How Roasty greets you, here and anywhere the app speaks to you.';

  /// The sheet's one action.
  static const sheetAction = 'Save name';

  /// What the Settings row reads while no name is kept.
  static const notSet = 'Not set';

  /// The name as it would be kept: trimmed, or null when there is none.
  ///
  /// Trailing spaces are not a name, and a learner who typed only spaces has
  /// given none — so blank and empty collapse to the one "no name" the
  /// greeting already handles.
  static String? normalize(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// What the Settings row shows for [name].
  static String rowValue(String? name) => name ?? notSet;
}
