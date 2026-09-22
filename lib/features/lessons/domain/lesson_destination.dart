/// Every way a lesson can be opened, named once.
///
/// A route rename compiles perfectly against a hand-spelled path and fails at
/// the tap, which `AppRoutes` exists to make impossible. No destination carries
/// a mode: what a finished run records is derived from the progress store.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// A resolved navigation target: the route's name and everything it needs.
///
/// Deliberately inert — it holds no `BuildContext` and performs no navigation,
/// so a destination can be derived far from the widget that eventually follows
/// it, and asserted in a unit test with no widget pumped.
@immutable
class RouteDestination {
  /// Creates a [RouteDestination].
  const RouteDestination({
    required this.name,
    this.pathParams = const {},
    this.queryParams = const {},
    this.startsActivity = false,
  });

  /// The route's name, never its path.
  final String name;

  /// Path parameters, keyed as the route declares them.
  final Map<String, String> pathParams;

  /// Query parameters. The lesson flow carries its mode and its graded result
  /// this way because the completion screen is a separate route from the run.
  final Map<String, String> queryParams;

  /// Whether following this begins a **full learning/practice activity** — one
  /// of the two a free local day holds (§8, #216).
  ///
  /// On the destination, because a screen handed one — Keep Sharp's card, a
  /// lesson ending — cannot otherwise tell a replay from the Path tab.
  final bool startsActivity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteDestination &&
          other.name == name &&
          other.startsActivity == startsActivity &&
          mapEquals(other.pathParams, pathParams) &&
          mapEquals(other.queryParams, queryParams);

  @override
  int get hashCode => Object.hash(
    name,
    startsActivity,
    Object.hashAllUnordered(_pairs(pathParams)),
    Object.hashAllUnordered(_pairs(queryParams)),
  );

  /// Order-independent, so two equal maps cannot hash apart.
  static Iterable<String> _pairs(Map<String, String> map) =>
      map.entries.map((entry) => '${entry.key}=${entry.value}');

  @override
  String toString() => 'RouteDestination($name, $pathParams, $queryParams)';
}

/// Opening a lesson. **One destination, no mode.**
///
/// What a finished run pays is not the caller's to say: the service resolves
/// first completion versus replay from the progress store, so there is no flag
/// here for a caller to get wrong and no URL that can disagree with what the
/// learner has actually done (#188).
RouteDestination lessonRun(String lessonId) => RouteDestination(
  name: AppRoutes.lesson.name,
  pathParams: {'lessonId': lessonId},
  startsActivity: true,
);

/// The completion screen for a finished run.
///
/// The graded pair travels **whole**. Rounding it to a percentage here would
/// destroy the wrong-answer count the mastery band derives from — `{4,5}` and
/// `{18,20}` both read 80%, and only the pair tells them apart.
RouteDestination lessonCompletion(
  String lessonId, {
  required int correct,
  required int total,
}) => RouteDestination(
  name: AppRoutes.lessonComplete.name,
  pathParams: {'lessonId': lessonId},
  queryParams: {'correct': '$correct', 'total': '$total'},
);

/// The module ending — **the one ending a module's last lesson plays** (#458),
/// so it also carries what that lesson's own ending would have reported.
///
/// [runLessonId] is where the points and the collectible are read from;
/// [freezeEarned], [fromStage] and [toStage] travel because they cannot be
/// re-derived. All optional: a deep link shows the module with nothing claimed.
RouteDestination moduleSummary(
  String moduleId, {
  String? runLessonId,
  bool freezeEarned = false,
  int? fromStage,
  int? toStage,
}) => RouteDestination(
  name: AppRoutes.moduleSummary.name,
  pathParams: {'moduleId': moduleId},
  queryParams: {
    'lesson': ?runLessonId,
    if (freezeEarned) 'freeze': 'true',
    if (fromStage != null) 'from': '$fromStage',
    if (toStage != null) 'to': '$toStage',
  },
);

/// The Learn tab, where every lesson flow returns to.
///
/// Not `const`: Dart cannot evaluate a field access on a const object inside a
/// const expression, and naming the route rather than repeating its string is
/// worth more here than the constant.
final RouteDestination learnTab = RouteDestination(name: AppRoutes.learn.name);

/// The Path tab — the course itself, which is where a finished run that has
/// nothing queued behind it goes back to.
///
/// Named because the design's completion CTA reads *"Back to Path"*, and the
/// course moved onto this tab (#394). Sending that button to Today instead
/// would be a label pointing at the wrong place.
final RouteDestination pathTab = RouteDestination(name: AppRoutes.path.name);

/// Navigating by [RouteDestination], so no caller spells a path out.
extension GoToDestination on BuildContext {
  /// Goes to [destination], replacing the current location.
  ///
  /// **Not for a destination that starts an activity.** Those go through
  /// `BuildContext.goToActivity`, which asks the free day's allowance first
  /// (ADR-0020); the assert is a backstop that fires in debug and in tests.
  void goTo(RouteDestination destination) {
    assert(
      !destination.startsActivity,
      'an activity destination goes through goToActivity, which asks the '
      "free day's allowance first",
    );
    goToAfterAllowance(destination);
  }

  /// Goes to [destination] for a caller that has **already asked** the free
  /// day's allowance.
  ///
  /// Deliberately unpleasant to reach for: the one caller is
  /// `BuildContext.goToActivity`, and a name this specific cannot be typed by
  /// accident the way [goTo] can.
  void goToAfterAllowance(RouteDestination destination) =>
      GoRouter.of(this).goToAfterAllowance(destination);

  /// Pushes [destination] for a caller that has already asked the allowance —
  /// the one caller being `BuildContext.pushActivity`.
  ///
  /// Pushed rather than gone to where closing the surface has to return the
  /// learner to whichever screen opened it — the drills, which are reached
  /// from four places each.
  Future<void> pushAfterAllowance(RouteDestination destination) =>
      GoRouter.of(this).pushAfterAllowance(destination);
}

/// The same two moves on a router captured **before** an async gap, for a
/// caller whose own context may be unmounted by the time the answer lands —
/// a row rebuilt under a sheet still owes the run it was tapped for.
extension RouterToDestination on GoRouter {
  /// Goes to [destination]; the caller has already asked the allowance.
  void goToAfterAllowance(RouteDestination destination) => goNamed(
    destination.name,
    pathParameters: destination.pathParams,
    queryParameters: destination.queryParams,
  );

  /// Pushes [destination] under the same condition.
  Future<void> pushAfterAllowance(RouteDestination destination) => pushNamed(
    destination.name,
    pathParameters: destination.pathParams,
    queryParameters: destination.queryParams,
  );
}
