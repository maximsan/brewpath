import 'package:brew_path/features/tour/domain/tour_copy.dart';

/// The Tour's four stops, in the order it plays them.
///
/// The order of the enum *is* the Tour, so the sequence lives here rather than
/// in the four places that anchor it. Each stop names the copy it carries and
/// says whether reaching it means returning the feed to the top — the two stops
/// that frame chrome do, because the header and the tab bar have to read in
/// their natural context rather than over a half-scrolled page.
enum TourStep {
  /// The Today card: the daily loop and the streak.
  today(title: TourCopy.todayTitle, body: TourCopy.todayBody),

  /// The practice area: the replay list and the mini-games, together, because
  /// they are one idea ("practice, your way") rather than two.
  practice(title: TourCopy.practiceTitle, body: TourCopy.practiceBody),

  /// The header's Saved and Dictionary entries.
  header(
    title: TourCopy.headerTitle,
    body: TourCopy.headerBody,
    returnsFeedToTop: true,
  ),

  /// The bottom tab bar: the three tabs the Tour never visits.
  tabs(
    title: TourCopy.tabsTitle,
    body: TourCopy.tabsBody,
    returnsFeedToTop: true,
  );

  const TourStep({
    required this.title,
    required this.body,
    this.returnsFeedToTop = false,
  });

  /// The stop's heading — locked copy from [TourCopy].
  final String title;

  /// The stop's body — locked copy from [TourCopy].
  final String body;

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
