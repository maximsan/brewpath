import 'package:brew_path/app/analytics_navigator_observer.dart';
import 'package:brew_path/app/app_shell.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/cards/presentation/card_detail_screen.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:brew_path/features/cards/presentation/favorites_screen.dart';
import 'package:brew_path/features/learn/presentation/game_type_practice_screen.dart';
import 'package:brew_path/features/learn/presentation/learn_screen.dart';
import 'package:brew_path/features/learn/presentation/module_detail_screen.dart';
import 'package:brew_path/features/learn/presentation/module_summary_screen.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_screen.dart';
import 'package:brew_path/features/lessons/presentation/lesson_screen.dart';
import 'package:brew_path/features/onboarding/presentation/brewer/brewer_screen.dart';
import 'package:brew_path/features/onboarding/presentation/goal/goal_screen.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:brew_path/features/path/presentation/path_screen.dart';
import 'package:brew_path/features/profile/presentation/profile_screen.dart';
import 'package:brew_path/features/profile/presentation/settings_screen.dart';
import 'package:brew_path/services/analytics/analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Provides the app's [GoRouter] (rebuilds on onboarding-gate changes).
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
    initialLocation: '/loading',
    refreshListenable: refresh,
    // Funnels the root (platform initial route, error-page "Home") to Loading
    // and gates the rest of the app behind the onboarding flow.
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/') {
        return '/loading';
      }
      final completed = ref.read(onboardingCompletedProvider).value ?? false;
      final isOnboardingRoute =
          path == '/loading' ||
          path == '/welcome' ||
          path.startsWith('/onboarding');
      if (!completed && !isOnboardingRoute) {
        return '/welcome';
      }
      if (completed && (path == '/welcome' || path.startsWith('/onboarding'))) {
        return '/learn';
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
                  // Module-completion recap, pushed over the shell after the
                  // last lesson's completion screen.
                  GoRoute(
                    path: AppRoutes.moduleSummary.path,
                    name: AppRoutes.moduleSummary.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => ModuleSummaryScreen(
                      moduleId: state.pathParameters['moduleId']!,
                    ),
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
                  // Declared before `cardDetail`: that route's path is the
                  // bare `:cardId` parameter, which would otherwise match
                  // `favorites` and open a card detail for a card that does
                  // not exist. go_router matches in declaration order, so the
                  // literal has to come first.
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
