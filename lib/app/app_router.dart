import 'package:coffee_quest/app/analytics_navigator_observer.dart';
import 'package:coffee_quest/app/app_shell.dart';
import 'package:coffee_quest/core/constants/app_routes.dart';
import 'package:coffee_quest/features/cards/presentation/card_detail_screen.dart';
import 'package:coffee_quest/features/cards/presentation/cards_screen.dart';
import 'package:coffee_quest/features/cards/presentation/favorites_screen.dart';
import 'package:coffee_quest/features/learn/presentation/game_type_practice_screen.dart';
import 'package:coffee_quest/features/learn/presentation/learn_screen.dart';
import 'package:coffee_quest/features/learn/presentation/module_detail_screen.dart';
import 'package:coffee_quest/features/lessons/presentation/lesson_completion_screen.dart';
import 'package:coffee_quest/features/lessons/presentation/lesson_screen.dart';
import 'package:coffee_quest/features/onboarding/presentation/brewer/brewer_screen.dart';
import 'package:coffee_quest/features/onboarding/presentation/goal/goal_screen.dart';
import 'package:coffee_quest/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
import 'package:coffee_quest/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:coffee_quest/features/path/presentation/path_screen.dart';
import 'package:coffee_quest/features/profile/presentation/profile_screen.dart';
import 'package:coffee_quest/features/profile/presentation/settings_screen.dart';
import 'package:coffee_quest/services/analytics/analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Provides the app's [GoRouter] (rebuilds on onboarding-gate changes).
///
/// Adding a route:
/// 1. Add an [AppRoute] to [AppRoutes] — an absolute `path` for a top-level
///    route, or a relative segment for one nested under a parent.
/// 2. Add a [GoRoute] here from `AppRoutes.x.path` / `AppRoutes.x.name`; pass
///    `parentNavigatorKey: _rootKey` if it should cover the bottom-nav shell.
/// 3. Navigate via `context.goNamed(AppRoutes.x.name, …)` and assert its
///    location in `test/unit/app_routes_test.dart`.
/// 4. New tab? Also add a `NavigationDestination` to [AppShell] in the SAME
///    order as the branches below (they pair by index), with an `AppLabels`
///    label.
/// 5. Visibility for gated/onboarding routes is decided in `redirect`, not on
///    the [GoRoute].
@riverpod
GoRouter appRouter(Ref ref) {
  // Ticks whenever the async onboarding gate resolves; passed to the router
  // as `refreshListenable` so the redirect re-evaluates without recreating
  // the router instance.
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen<AsyncValue<bool>>(onboardingCompletedProvider, (prev, next) {
    refresh.value++;
  });
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.loading.path,
    refreshListenable: refresh,
    // Funnels the root (platform initial route, error-page "Home") to Loading
    // and gates the rest of the app behind the onboarding flow. Locations are
    // resolved from route names so this never hardcodes a URL.
    redirect: (context, state) {
      final loadingLocation = state.namedLocation(AppRoutes.loading.name);
      final welcomeLocation = state.namedLocation(AppRoutes.welcome.name);
      final goalLocation = state.namedLocation(AppRoutes.onboardingGoal.name);
      final brewerLocation = state.namedLocation(
        AppRoutes.onboardingBrewer.name,
      );
      final path = state.uri.path;

      if (path == '/') {
        return loadingLocation;
      }

      final completed = ref.read(onboardingCompletedProvider).value ?? false;
      final isOnboardingRoute =
          path == loadingLocation ||
          path == welcomeLocation ||
          path == goalLocation ||
          path == brewerLocation;

      if (!completed && !isOnboardingRoute) {
        return welcomeLocation;
      }

      if (completed &&
          (path == welcomeLocation ||
              path == goalLocation ||
              path == brewerLocation)) {
        return state.namedLocation(AppRoutes.learn.name);
      }

      return null;
    },
    observers: [
      AnalyticsNavigatorObserver(ref.watch(analyticsServiceProvider)),
    ],
    routes: [
      GoRoute(
        path: AppRoutes.loading.path,
        name: AppRoutes.loading.name,
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome.path,
        name: AppRoutes.welcome.name,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingGoal.path,
        name: AppRoutes.onboardingGoal.name,
        builder: (context, state) => const GoalScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingBrewer.path,
        name: AppRoutes.onboardingBrewer.name,
        builder: (context, state) => const BrewerScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn.path,
                name: AppRoutes.learn.name,
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.moduleDetail.path,
                    name: AppRoutes.moduleDetail.name,
                    builder: (context, state) => ModuleDetailScreen(
                      moduleId: state.pathParameters['moduleId']!,
                    ),
                  ),
                  // Immersive lesson flow: pushed on the root navigator so it
                  // covers the bottom-nav shell.
                  GoRoute(
                    path: AppRoutes.lesson.path,
                    name: AppRoutes.lesson.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => LessonScreen(
                      lessonId: state.pathParameters['lessonId']!,
                      review: state.uri.queryParameters['review'] == 'true',
                      practice: state.uri.queryParameters['practice'] == 'true',
                    ),
                    routes: [
                      GoRoute(
                        path: AppRoutes.lessonComplete.path,
                        name: AppRoutes.lessonComplete.name,
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => LessonCompletionScreen(
                          lessonId: state.pathParameters['lessonId']!,
                          review: state.uri.queryParameters['review'] == 'true',
                          practice:
                              state.uri.queryParameters['practice'] == 'true',
                          score:
                              int.tryParse(
                                state.uri.queryParameters['score'] ?? '',
                              ) ??
                              0,
                        ),
                      ),
                    ],
                  ),
                  // Practice flows live under /learn so the back button
                  // returns to the Learn tab. Both push on the root navigator
                  // to cover the bottom-nav shell (same as lessons).
                  GoRoute(
                    path: AppRoutes.practiceLesson.path,
                    name: AppRoutes.practiceLesson.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => LessonScreen(
                      lessonId: state.pathParameters['lessonId']!,
                      practice: true,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.practiceGameType.path,
                    name: AppRoutes.practiceGameType.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => GameTypePracticeScreen(
                      gameType: state.pathParameters['gameType']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.path.path,
                name: AppRoutes.path.name,
                builder: (context, state) => const PathScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cards.path,
                name: AppRoutes.cards.name,
                builder: (context, state) => const CardsScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.favorites.path,
                    name: AppRoutes.favorites.name,
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                  GoRoute(
                    path: AppRoutes.cardDetail.path,
                    name: AppRoutes.cardDetail.name,
                    builder: (context, state) => CardDetailScreen(
                      cardId: state.pathParameters['cardId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile.path,
                name: AppRoutes.profile.name,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.profileSettings.path,
                    name: AppRoutes.profileSettings.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
