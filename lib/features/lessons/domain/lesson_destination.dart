/// Every way a lesson can be opened, named once.
///
/// Four call sites used to assemble these URLs by hand — path segments spelled
/// out, mode flags appended as query strings. A route rename compiles perfectly
/// against a string literal and fails at the tap, which is exactly the failure
/// `AppRoutes` exists to make impossible.
///
/// No destination below carries a mode. What a finished run records is derived
/// from the progress store, so the only thing a lesson URL has to say is which
/// lesson — and the graded pair the completion screen renders.
library;

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/domain/daily_allowance.dart';
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
  /// It rides on the destination because the two screens that navigate to a
  /// destination they were *handed* — Keep Sharp's card and a lesson ending —
  /// cannot otherwise tell a replay from the Path tab. Deriving it from the
  /// route name instead would put that knowledge in a second place, keyed on
  /// something a rename changes.
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

/// The module ending — **the one ending a module's last lesson plays**.
///
/// A lesson that closes its module comes straight here and plays no lesson
/// ending of its own (#458). So this route also carries what that ending would
/// have reported, because nothing else will say it.
///
/// [runLessonId] names the lesson that closed the module, which is where the
/// screen reads the points it paid and the collectible it handed over.
/// [freezeEarned] cannot be re-derived at all — it is a transition, true only
/// on the run that crossed it. [fromStage] and [toStage] travel rather than
/// being recomputed, so the tree the learner sees and the tree the run wrote
/// can never disagree.
///
/// Every one is optional: opened without them — a deep link, a review — the
/// screen simply shows the module and its reward, with nothing claimed about a
/// run that did not happen.
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
  /// `WidgetRef.goToActivity`, which asks the free day's allowance first. The
  /// assert is what stops a new call site from routing around the cap: it
  /// fires in debug and in every test, where a leak is cheap to find, and the
  /// alternative is a rule that holds only where someone remembered it.
  void goTo(RouteDestination destination) {
    assert(
      !destination.startsActivity,
      'an activity destination goes through goToActivity — a free day holds '
      'only $freeDailyActivities of them',
    );
    goToAfterAllowance(destination);
  }

  /// Goes to [destination] for a caller that has **already asked** the free
  /// day's allowance.
  ///
  /// Deliberately unpleasant to reach for: the one caller is
  /// `WidgetRef.goToActivity`, and a name this specific cannot be typed by
  /// accident the way [goTo] can.
  void goToAfterAllowance(RouteDestination destination) => goNamed(
    destination.name,
    pathParameters: destination.pathParams,
    queryParameters: destination.queryParams,
  );

  /// Pushes [destination] for a caller that has already asked the allowance.
  ///
  /// Pushed rather than gone to where closing the surface has to return the
  /// learner to whichever screen opened it — the drills, which are reached
  /// from four places each.
  Future<void> pushAfterAllowance(RouteDestination destination) => pushNamed(
    destination.name,
    pathParameters: destination.pathParams,
    queryParameters: destination.queryParams,
  );
}
