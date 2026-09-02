import 'package:brew_path/app/pending_link.dart';
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
