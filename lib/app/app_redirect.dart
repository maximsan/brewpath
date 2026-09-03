import 'package:brew_path/app/pending_link.dart';
import 'package:brew_path/core/constants/app_links.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/domain/lesson_access.dart';
import 'package:flutter/foundation.dart';

/// What the gates decided: where to send the learner, and what a wall turned
/// them away from on the way.
///
/// The refusal rides back rather than being written to a holder, so
/// [redirectFor] stays a function of its arguments. The router is the only
/// thing that can act on it — a sheet cannot be opened while a location is
/// still being resolved — and it acts on it the moment it is handed over.
@immutable
class GateDecision {
  /// The location asked for is allowed.
  const GateDecision.allow() : location = null, refusedLesson = null;

  /// Go to [location] instead.
  const GateDecision.to(this.location) : refusedLesson = null;

  /// Go to [location] instead, because the course wall refused
  /// [refusedLesson].
  const GateDecision.refusedLesson(
    this.refusedLesson, {
    required this.location,
  });

  /// Where to go instead, or null when [location] is allowed as asked.
  final String? location;

  /// The lesson the course wall turned away, or null when none was.
  final String? refusedLesson;
}

/// The state every gate is decided from, read once at the router's end.
///
/// One value rather than five arguments: they are read together, in one place,
/// and they travel together into the one function that judges them. A gate
/// added later is a field here, not a sixth thing every caller has to pass.
///
/// **Every unresolved read is the locked answer.** Showing a lock briefly to a
/// paying learner is recoverable and showing paid content briefly to a free one
/// is not, so the router resolves each pending provider to `false` — and the
/// finished-lesson set to empty — before handing it over.
@immutable
class GateState {
  /// Creates a [GateState].
  const GateState({
    required this.onboardingCompleted,
    required this.courseEntitled,
    required this.courseCompletionDue,
    required this.completedLessonIds,
  });

  /// Whether the learner has been through the intro.
  final bool onboardingCompleted;

  /// Whether they own the course.
  final bool courseEntitled;

  /// Whether the one-off course ending is owed to them.
  final bool courseCompletionDue;

  /// The lessons they have finished, which the course wall never takes back.
  final Set<String> completedLessonIds;
}

/// Every gate→destination decision the app makes, as one pure function.
///
/// Readable and testable without a router: the widget-level version needs the
/// whole app pumped and onboarding driven for real, which is why the
/// pending-link rule below had no test until it had a defect.
///
/// Its one effect is on [pending], which by its nature outlives a single call
/// — everything else the gates conclude comes back in the [GateDecision].
GateDecision redirectFor({
  required Uri location,
  required GateState gates,
  required PendingLink pending,
}) {
  final path = location.path;
  // The platform's initial route, and the error page's "Home".
  if (path == '/') return GateDecision.to(AppRoutes.loading.path);

  // The intro proper — the two screens a first run is walked through. Named
  // once because the gate asks about them twice, in opposite directions: an
  // unfinished learner must be let in, a finished one bounced out.
  final isIntroRoute =
      path == AppRoutes.welcome.path || path == AppRoutes.meetRoasty.path;
  final isOnboardingRoute =
      path == AppRoutes.loading.path ||
      isIntroRoute ||
      path.startsWith(AppRoutes.onboardingPrefix);

  if (!gates.onboardingCompleted) {
    if (isOnboardingRoute) return const GateDecision.allow();
    // The arrival that is about to be bounced is the whole reason the learner
    // opened the app. Held here, resumed below — otherwise someone who
    // installs because a card was shared with them never sees that card.
    pending.hold(location.toString());
    return GateDecision.to(AppRoutes.welcome.path);
  }

  final resumed = pending.take();
  if (resumed != null) return GateDecision.to(resumed);

  if (isIntroRoute || path.startsWith(AppRoutes.onboardingPrefix)) {
    return GateDecision.to(AppRoutes.learn.path);
  }

  // The Studio is behind the entitlement, and the door is not the only way to
  // reach it — a deep link is. The gate belongs here for the same reason every
  // other gate→destination decision does: a screen that guards itself is a
  // guard one route can be added around.
  if (path.endsWith('/${AppRoutes.studio.path}') && !gates.courseEntitled) {
    return GateDecision.to(AppRoutes.profile.path);
  }

  // The course wall. Every surface that draws a locked lesson also raises the
  // offer from the row itself, so this is the backstop: a deep link, a
  // *Next lesson* button on a completion screen, any future caller that
  // navigates without asking. One of them getting it wrong must not be a way
  // into the course.
  if (lessonIdIn(location) case final lessonId?
      when isLessonPurchaseLocked(
        lessonId: lessonId,
        hasCourse: gates.courseEntitled,
        isCompleted: gates.completedLessonIds.contains(lessonId),
      )) {
    return GateDecision.refusedLesson(
      lessonId,
      location: AppRoutes.learn.path,
    );
  }

  // The one-off completion moment intercepts arrival at Today only — the
  // ending presents where the course lived, and never hijacks another tab.
  if (gates.courseCompletionDue && path == AppRoutes.learn.path) {
    return GateDecision.to(AppRoutes.courseComplete.path);
  }
  return const GateDecision.allow();
}

/// Translates the **published** card address into the route that reads a card.
///
/// A shared link says `/card/<id>`; the app reads a card as a sheet over its
/// collection, at `/cards/<id>`. Forwarding here rather than registering a
/// route keeps the published address stable without giving a card a second
/// home in the app — and catches what a route could not, because the AASA
/// file claims `/card/*` and `*` matches across slashes.
///
/// Anything that is not one clean segment lands on the collection: version
/// skew and mistyped links degrade silently, never onto an error screen.
/// Returns null when [location] is not a card address at all.
///
/// Lives beside the gates but is **not** called by [redirectFor]: go_router
/// runs no redirect for a location nothing matches, so this has to hang off a
/// route that matches. The route calls it.
String? forwardPublicCardAddress(Uri location) {
  const prefix = AppLinks.cardPrefix;
  final path = location.path;
  if (path != prefix && !path.startsWith('$prefix/')) return null;

  final id = path == prefix ? '' : path.substring(prefix.length + 1);
  if (id.isEmpty || id.contains('/')) return AppRoutes.cards.path;
  return location.replace(path: '${AppRoutes.cards.path}/$id').toString();
}

/// The lesson a location plays, or null when it is not a lesson route at all.
///
/// Reads the URL rather than go_router's path parameters because the gate is a
/// pure function: it is handed a `Uri` and has no match to ask. Both the run
/// and the ending it leads to are lesson routes — `/learn/lesson/<id>` and
/// `/learn/lesson/<id>/complete` — and the wall stands in front of both, so an
/// ending cannot be linked to as a way of claiming a lesson that was never
/// played.
String? lessonIdIn(Uri location) {
  // Assembled from the routes themselves — the tab's path plus the lesson
  // route's own first segment — so renaming either cannot leave a string
  // literal here pointing at an address that no longer exists.
  final prefix =
      '${AppRoutes.learn.path}/${AppRoutes.lesson.path.split('/').first}/';
  final path = location.path;
  if (!path.startsWith(prefix)) return null;

  final id = path.substring(prefix.length).split('/').first;
  return id.isEmpty ? null : id;
}
