/// Which parts of the app the App Guide walks, and in what order.
///
/// The words are in `app_en.arb`; the order is the design's own
/// `APP_GUIDE_SECTIONS`, which walks the app the way a learner meets it. The
/// streak entry is rewritten from the design under #338 — its own sentence
/// named one of six qualifying activities; the rule is `05-mechanics.md` §5.
library;

import 'package:brew_path/l10n/generated/app_localizations.dart';

/// One entry on the App Guide: a part of the app, and what it does.
class AppGuideSection {
  /// Creates an [AppGuideSection].
  const AppGuideSection({required this.title, required this.body});

  /// The part being explained, in the words the app calls it elsewhere.
  final String title;

  /// A line or two on what it does.
  final String body;
}

/// The parts of the app, in the order the guide walks them.
List<AppGuideSection> appGuideSections(AppLocalizations strings) => [
  AppGuideSection(
    title: strings.appGuideTodayTitle,
    body: strings.appGuideTodayBody,
  ),
  AppGuideSection(
    title: strings.appGuidePathTitle,
    body: strings.appGuidePathBody,
  ),
  AppGuideSection(
    title: strings.appGuidePracticeTitle,
    body: strings.appGuidePracticeBody,
  ),
  AppGuideSection(
    title: strings.appGuideChallengesTitle,
    body: strings.appGuideChallengesBody,
  ),
  AppGuideSection(
    title: strings.appGuideDictionaryTitle,
    body: strings.appGuideDictionaryBody,
  ),
  AppGuideSection(
    title: strings.appGuideTreeTitle,
    body: strings.appGuideTreeBody,
  ),
  AppGuideSection(
    title: strings.appGuideStreakTitle,
    body: strings.appGuideStreakBody,
  ),
];
