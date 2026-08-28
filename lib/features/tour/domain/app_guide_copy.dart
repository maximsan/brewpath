/// One entry on the App Guide: a part of the app, and what it does.
class AppGuideSection {
  /// Creates an [AppGuideSection].
  const AppGuideSection({required this.title, required this.body});

  /// The part being explained, in the words the app calls it elsewhere.
  final String title;

  /// A line or two on what it does.
  final String body;
}

/// Every word the App Guide says.
///
/// Transcribed from the design (`prototype/guide.jsx`, `APP_GUIDE_SECTIONS`),
/// which is the source for this screen the way `TourCopy` is for the Tour. The
/// order is the design's, and it is not alphabetical or arbitrary — it walks
/// the app the way a learner meets it, from the daily start outwards.
abstract final class AppGuideCopy {
  /// The screen's title, and the label of the Settings row that opens it.
  static const title = 'App Guide';

  /// The Settings row's supporting line.
  static const settingsRowBody = 'What each part does, plus the Today intro';

  /// The sentence under the screen's title.
  static const lead = 'What each part of BrewPath does, in a line or two.';

  /// The section the Settings row sits in.
  static const helpSectionLabel = 'Help & Support';

  /// The section the replay row sits in, at the foot of the guide.
  static const introSectionLabel = 'Introduction';

  /// The parts of the app, in the order the guide walks them.
  static const sections = [
    AppGuideSection(
      title: 'Today',
      body:
          'Your daily start: the next lesson, any active Coffee Challenge, and '
          'practice worth revisiting.',
    ),
    AppGuideSection(
      title: 'Learning Path',
      body:
          'The whole course in order. Each finished lesson unlocks the next; '
          'diamonds along the line are Coffee Challenges.',
    ),
    AppGuideSection(
      title: 'Practice',
      body:
          'Replay finished lessons or drill the practice formats from Today. '
          'Reviews sharpen you but never change your points.',
    ),
    AppGuideSection(
      title: 'Brew Challenges',
      body:
          'Real-world brewing tasks. Start one, make it within 48 hours, then '
          'log the result on Today to earn its stamp.',
    ),
    AppGuideSection(
      title: 'Dictionary & Saved',
      body:
          'Terms join the Dictionary as lessons introduce them. Anything you '
          'bookmark waits in Saved, at the top of Today.',
    ),
    AppGuideSection(
      title: 'Coffee Tree',
      body:
          'Grows a stage as you complete core lessons, from seed to harvest. '
          'Only lessons grow it — it lives on your Profile.',
    ),
    AppGuideSection(
      title: 'Streak',
      body:
          'One lesson a day keeps it alive. Every 7 days in a row earns a '
          'streak freeze (you hold one at a time); it covers a missed day '
          'automatically.',
    ),
  ];
}
