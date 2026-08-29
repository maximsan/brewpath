/// The words Settings and the four screens behind it are **built from** — the
/// section headings, the row labels, the titles, and About's own copy.
///
/// Held together the way `AppGuideCopy` and `TourCopy` are: the design owns
/// these strings (`prototype/screens.jsx`, `prototype/settings.jsx`), and a
/// screen that spelled its own would be a second place to change them.
///
/// Not *every* string on the surface: the two confirmation dialogs keep their
/// copy beside the action they confirm, where the wording and the consequence
/// can only be read together.
abstract final class SettingsCopy {
  /// The screen's own name.
  static const title = 'Settings';

  /// The `APPEARANCE` group.
  static const appearanceSection = 'Appearance';

  /// The `PRACTICE` group — where the design files the four preference rows.
  static const practiceSection = 'Practice';

  /// The `ACCOUNT` group.
  static const accountSection = 'Account';

  /// The `SUPPORT` group.
  static const supportSection = 'Support';

  /// Row: the daily reminder's switch.
  static const notificationsRow = 'Notifications';

  /// Row: the time that reminder arrives.
  static const reminderRow = 'Daily reminder';

  /// Row: audio feedback in lessons and mini-games.
  static const soundRow = 'Sound effects';

  /// Row: vibration on taps and answers.
  static const hapticsRow = 'Haptics';

  /// Row: into [accountSyncTitle].
  static const accountRow = 'Account and sync';

  /// Row: into [purchasesTitle].
  static const purchasesRow = 'Purchases';

  /// Row: into [helpTitle].
  static const helpRow = 'Help and support';

  /// Row: into [aboutTitle].
  static const aboutRow = 'About';

  /// Row: clears the learner's progress.
  static const resetProgressRow = 'Reset progress';

  /// Row: sends them back through the intro.
  static const restartOnboardingRow = 'Restart onboarding';

  /// The tier a learner without the purchase is on.
  static const freeTier = 'Free';

  /// Account and sync's title.
  static const accountSyncTitle = 'Account and sync';

  /// Purchases' title.
  static const purchasesTitle = 'Purchases';

  /// Help and support's title.
  static const helpTitle = 'Help and support';

  /// About's title.
  static const aboutTitle = 'About';

  /// The kicker under the app's name on About
  /// (`prototype/settings.jsx:308`).
  ///
  /// Ordinary English, not the collectible: *Field Guide* was the retired name
  /// for a Module Reward, and the glossary guard rules it out everywhere
  /// except phrases like this one, which it carries by name.
  static const aboutTagline = 'A field guide to coffee';

  /// What closes the version line (`prototype/screens.jsx:559`) — the same
  /// ordinary-English sense, shorter because the line already carries two
  /// other parts.
  static const versionTagline = 'A field guide';

  /// About's own description of the app.
  static const aboutBlurb =
      'A quiet place to learn coffee — one short lesson at a time. No noise, '
      'no pressure. Just you, a growing tree, and Roasty for company.';

  /// Section on Help: where the written guide lives.
  static const learnTheAppSection = 'Learn the app';

  /// Section on Help: the FAQ and how to reach a human.
  static const commonQuestionsSection = 'Common questions';

  /// Section on Account and sync.
  static const cloudSyncSection = 'Cloud sync';

  /// Section on About: the legal rows.
  static const finePrintSection = 'The fine print';

  /// What the unbuilt half of Account and sync will hold.
  static const cloudSyncComing =
      'Signing in, and keeping your progress on more than one device.';

  /// What the unbuilt half of Purchases will hold.
  static const purchasesComing =
      'What Foundations includes, and restoring a purchase you already made.';

  /// What the unbuilt half of Help will hold.
  static const helpComing =
      'Answers to the questions people ask most, and a way to reach us.';

  /// What the unbuilt half of About will hold.
  static const aboutComing =
      'Privacy policy, terms, acknowledgements and the open-source licenses.';
}
