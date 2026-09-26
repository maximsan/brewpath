import 'package:brew_path/l10n/generated/app_localizations.dart';

/// The Tour's four stops, in the order it plays them.
///
/// The order of the enum *is* the Tour, so the sequence lives here rather than
/// in the four places that anchor it. Each stop names the copy it carries and
/// says whether reaching it returns the feed to the top — the two that frame
/// chrome do, so the header and tab bar read in their natural context.
enum TourStep {
  /// The Today card: the daily loop and the streak.
  today,

  /// The practice area: the replay list and the mini-games, together, because
  /// they are one idea ("practice, your way") rather than two.
  practice,

  /// The header's Saved and Dictionary entries.
  header(returnsFeedToTop: true),

  /// The bottom tab bar: the three tabs the Tour never visits.
  tabs(returnsFeedToTop: true);

  const TourStep({this.returnsFeedToTop = false});

  /// The stop's heading, which is the design's own script (#536).
  String title(AppLocalizations strings) => switch (this) {
    TourStep.today => strings.tourTodayTitle,
    TourStep.practice => strings.tourPracticeTitle,
    TourStep.header => strings.tourHeaderTitle,
    TourStep.tabs => strings.tourTabsTitle,
  };

  /// The stop's body, likewise.
  String body(AppLocalizations strings) => switch (this) {
    TourStep.today => strings.tourTodayBody,
    TourStep.practice => strings.tourPracticeBody,
    TourStep.header => strings.tourHeaderBody,
    TourStep.tabs => strings.tourTabsBody,
  };

  /// Whether arriving here scrolls the feed back to the top.
  ///
  /// The two chrome stops do. Their targets do not move with the feed, so
  /// there is nothing to scroll *to* — what the scroll is for is putting the
  /// page under them back where the learner will find it.
  final bool returnsFeedToTop;

  /// How many stops the Tour has.
  static int get count => TourStep.values.length;

  /// This stop's place in the run, counting from one — the card's `N of 4`.
  int get position => index + 1;

  /// Whether this is the stop the Tour ends on.
  ///
  /// Asked by the card, which labels its right-hand button *Done* rather than
  /// *Next* here. Answered from the order rather than by naming [tabs], so
  /// re-ordering the Tour re-labels the card by itself.
  bool get isLast => this == TourStep.values.last;

  /// The stop after this one, or null where this is the last.
  TourStep? get next => isLast ? null : TourStep.values[index + 1];
}
