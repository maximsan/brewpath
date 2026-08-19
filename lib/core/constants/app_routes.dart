// Self-descriptive route catalog — no per-member docs needed.
// ignore_for_file: public_member_api_docs

/// A single app route: its go_router [name] (the stable navigation handle) and
/// its [path] (the value the router registers — absolute for top-level routes,
/// relative for nested ones). Declaring both on one entry keeps a route's name
/// and path together so they can never silently drift apart.
class AppRoute {
  const AppRoute(this.name, this.path);

  final String name;
  final String path;
}

/// Canonical catalog of every route in the app. The router builds each
/// `GoRoute` from these entries (`path:` ← [AppRoute.path], `name:` ←
/// [AppRoute.name]); navigation refers to a route by `AppRoutes.x.name` via
/// `context.goNamed`, so go_router builds the URL from the route's own path.
abstract class AppRoutes {
  static const loading = AppRoute('loading', '/loading');
  static const welcome = AppRoute('welcome', '/welcome');
  static const onboardingGoal = AppRoute('onboardingGoal', '/onboarding/goal');
  static const onboardingBrewer = AppRoute(
    'onboardingBrewer',
    '/onboarding/brewer',
  );
  static const learn = AppRoute('learn', '/learn');
  static const courseComplete = AppRoute('courseComplete', '/course-complete');
  static const moduleDetail = AppRoute('moduleDetail', 'module/:moduleId');
  static const lesson = AppRoute('lesson', 'lesson/:lessonId');
  static const lessonComplete = AppRoute('lessonComplete', 'complete');
  static const moduleSummary = AppRoute(
    'moduleSummary',
    'module-summary/:moduleId',
  );
  static const practiceLesson = AppRoute(
    'practiceLesson',
    'practice/lesson/:lessonId',
  );
  static const miniGameIntro = AppRoute('miniGameIntro', 'mini-game/:gameId');
  static const miniGamePlay = AppRoute('miniGamePlay', 'play');
  static const path = AppRoute('path', '/path');
  static const cards = AppRoute('cards', '/cards');
  static const cardDetail = AppRoute('cardDetail', ':cardId');
  static const profile = AppRoute('profile', '/profile');
  static const profileSettings = AppRoute('profileSettings', 'settings');
}
