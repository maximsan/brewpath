/// Every way a lesson can be opened, named once.
///
/// Four call sites used to assemble these URLs by hand — path segments spelled
/// out, mode flags appended as query strings. A route rename compiles perfectly
/// against a string literal and fails at the tap, which is exactly the failure
/// `AppRoutes` exists to make impossible.
///
/// Each destination below is a **mode**, not a path: the flags that decide what
/// a finished run records travel with the route rather than beside it, so a
/// caller cannot pick a destination and forget the flag that gives it meaning.
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
  });

  /// The route's name, never its path.
  final String name;

  /// Path parameters, keyed as the route declares them.
  final Map<String, String> pathParams;

  /// Query parameters. The lesson flow carries its mode and its graded result
  /// this way because the completion screen is a separate route from the run.
  final Map<String, String> queryParams;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteDestination &&
          other.name == name &&
          mapEquals(other.pathParams, pathParams) &&
          mapEquals(other.queryParams, queryParams);

  @override
  int get hashCode => Object.hash(
    name,
    Object.hashAllUnordered(_pairs(pathParams)),
    Object.hashAllUnordered(_pairs(queryParams)),
  );

  /// Order-independent, so two equal maps cannot hash apart.
  static Iterable<String> _pairs(Map<String, String> map) =>
      map.entries.map((entry) => '${entry.key}=${entry.value}');

  @override
  String toString() => 'RouteDestination($name, $pathParams, $queryParams)';
}

/// The query key carrying whether a run is a replay of a finished lesson.
const String _reviewFlag = 'review';

/// Playing a lesson for the first time. A finished run banks everything.
RouteDestination lessonStart(String lessonId) => RouteDestination(
  name: AppRoutes.lesson.name,
  pathParams: {'lessonId': lessonId},
);

/// Replaying a lesson already finished. A finished run updates mastery upward,
/// pays practice points once a day, and marks the day active (§3).
RouteDestination lessonReplay(String lessonId) => RouteDestination(
  name: AppRoutes.lesson.name,
  pathParams: {'lessonId': lessonId},
  queryParams: const {_reviewFlag: 'true'},
);

/// The completion screen for a finished run.
///
/// The graded pair travels **whole**. Rounding it to a percentage here would
/// destroy the wrong-answer count the mastery band derives from — `{4,5}` and
/// `{18,20}` both read 80%, and only the pair tells them apart.
RouteDestination lessonCompletion(
  String lessonId, {
  required bool review,
  required int correct,
  required int total,
}) => RouteDestination(
  name: AppRoutes.lessonComplete.name,
  pathParams: {'lessonId': lessonId},
  queryParams: {
    _reviewFlag: '$review',
    'correct': '$correct',
    'total': '$total',
  },
);

/// The module recap shown after the last lesson of a module.
RouteDestination moduleSummary(String moduleId) => RouteDestination(
  name: AppRoutes.moduleSummary.name,
  pathParams: {'moduleId': moduleId},
);

/// The Learn tab, where every lesson flow returns to.
///
/// Not `const`: Dart cannot evaluate a field access on a const object inside a
/// const expression, and naming the route rather than repeating its string is
/// worth more here than the constant.
final RouteDestination learnTab = RouteDestination(name: AppRoutes.learn.name);

/// Navigating by [RouteDestination], so no caller spells a path out.
extension GoToDestination on BuildContext {
  /// Goes to [destination], replacing the current location.
  void goTo(RouteDestination destination) => goNamed(
    destination.name,
    pathParameters: destination.pathParams,
    queryParameters: destination.queryParams,
  );
}
