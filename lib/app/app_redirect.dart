import 'package:brew_path/app/pending_link.dart';
import 'package:brew_path/core/constants/app_links.dart';
import 'package:brew_path/core/constants/app_routes.dart';

/// Every gate→destination decision the app makes, as one pure function.
///
/// Pure so the rules can be read and tested without a router: the widget-level
/// version needs the whole app pumped and onboarding driven for real, which is
/// why the pending-link rule below had no test until it had a defect.
///
/// Returns the location to go to instead, or null to allow [location].
String? redirectFor({
  required Uri location,
  required bool onboardingCompleted,
  required bool courseEntitled,
  required bool courseCompletionDue,
  required PendingLink pending,
}) {
  final path = location.path;
  // The platform's initial route, and the error page's "Home".
  if (path == '/') return AppRoutes.loading.path;

  // The intro proper — the two screens a first run is walked through. Named
  // once because the gate asks about them twice, in opposite directions: an
  // unfinished learner must be let in, a finished one bounced out.
  final isIntroRoute =
      path == AppRoutes.welcome.path || path == AppRoutes.meetRoasty.path;
  final isOnboardingRoute =
      path == AppRoutes.loading.path ||
      isIntroRoute ||
      path.startsWith(AppRoutes.onboardingPrefix);

  if (!onboardingCompleted) {
    if (isOnboardingRoute) return null;
    // The arrival that is about to be bounced is the whole reason the learner
    // opened the app. Held here, resumed below — otherwise someone who
    // installs because a card was shared with them never sees that card.
    pending.hold(location.toString());
    return AppRoutes.welcome.path;
  }

  final resumed = pending.take();
  if (resumed != null) return resumed;

  if (isIntroRoute || path.startsWith(AppRoutes.onboardingPrefix)) {
    return AppRoutes.learn.path;
  }

  // The Studio is behind the entitlement, and the door is not the only way to
  // reach it — a deep link is. The gate belongs here for the same reason every
  // other gate→destination decision does: a screen that guards itself is a
  // guard one route can be added around.
  if (path.endsWith('/${AppRoutes.studio.path}') && !courseEntitled) {
    return AppRoutes.profile.path;
  }

  // The one-off completion moment intercepts arrival at Today only — the
  // ending presents where the course lived, and never hijacks another tab.
  if (courseCompletionDue && path == AppRoutes.learn.path) {
    return AppRoutes.courseComplete.path;
  }
  return null;
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
