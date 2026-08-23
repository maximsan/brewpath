import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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
  static const onboardingName = AppRoute('onboardingName', '/onboarding/name');
  static const learn = AppRoute('learn', '/learn');
  static const courseComplete = AppRoute('courseComplete', '/course-complete');
  static const moduleDetail = AppRoute('moduleDetail', 'module/:moduleId');
  static const lesson = AppRoute('lesson', 'lesson/:lessonId');
  static const lessonComplete = AppRoute('lessonComplete', 'complete');
  static const moduleSummary = AppRoute(
    'moduleSummary',
    'module-summary/:moduleId',
  );
  static const miniGameIntro = AppRoute('miniGameIntro', 'mini-game/:gameId');
  static const miniGamePlay = AppRoute('miniGamePlay', 'play');
  static const saved = AppRoute('saved', 'saved');
  static const dictionary = AppRoute('dictionary', 'dictionary');
  static const dictionaryTerm = AppRoute('dictionaryTerm', 'term/:termId');
  static const path = AppRoute('path', '/path');
  static const cards = AppRoute('cards', '/cards');
  static const cardDetail = AppRoute('cardDetail', ':cardId');
  static const profile = AppRoute('profile', '/profile');
  static const profileSettings = AppRoute('profileSettings', 'settings');
  static const profileStreak = AppRoute('profileStreak', 'streak');
}

/// Opening a dictionary term, from wherever the learner found it.
///
/// The route's path parameter is named in exactly one place — three callers
/// spelling `'termId'` themselves is three chances to misspell it.
extension DictionaryNavigation on BuildContext {
  /// Pushes the full entry for [termId].
  Future<void> pushDictionaryTerm(String termId) => GoRouter.of(this).pushNamed(
    AppRoutes.dictionaryTerm.name,
    pathParameters: {'termId': termId},
  );
}
