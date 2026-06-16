import 'package:coffee_quest/app/analytics_navigator_observer.dart';
import 'package:coffee_quest/app/app_shell.dart';
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
        path: '/loading',
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/goal',
        name: 'onboardingGoal',
        builder: (context, state) => const GoalScreen(),
      ),
      GoRoute(
        path: '/onboarding/brewer',
        name: 'onboardingBrewer',
        builder: (context, state) => const BrewerScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                name: 'learn',
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: 'module/:moduleId',
                    name: 'moduleDetail',
                    builder: (context, state) => ModuleDetailScreen(
                      moduleId: state.pathParameters['moduleId']!,
                    ),
                  ),
                  // Immersive lesson flow: pushed on the root navigator so it
                  // covers the bottom-nav shell.
                  GoRoute(
                    path: 'lesson/:lessonId',
                    name: 'lesson',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => LessonScreen(
                      lessonId: state.pathParameters['lessonId']!,
                      review: state.uri.queryParameters['review'] == 'true',
                      practice: state.uri.queryParameters['practice'] == 'true',
                    ),
                    routes: [
                      GoRoute(
                        path: 'complete',
                        name: 'lessonComplete',
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
                    path: 'practice/lesson/:lessonId',
                    name: 'practiceLesson',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => LessonScreen(
                      lessonId: state.pathParameters['lessonId']!,
                      practice: true,
                    ),
                  ),
                  GoRoute(
                    path: 'practice/game-type/:gameType',
                    name: 'practiceGameType',
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
                path: '/path',
                name: 'path',
                builder: (context, state) => const PathScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cards',
                name: 'cards',
                builder: (context, state) => const CardsScreen(),
                routes: [
                  GoRoute(
                    path: 'favorites',
                    name: 'favorites',
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                  GoRoute(
                    path: ':cardId',
                    name: 'cardDetail',
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
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: 'profileSettings',
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
