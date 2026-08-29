import 'package:brew_path/app/analytics_navigator_observer.dart';
import 'package:brew_path/app/app_shell.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/cards/presentation/card_detail_screen.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/dictionary/presentation/term_detail_screen.dart';
import 'package:brew_path/features/learn/domain/course_completion_providers.dart';
import 'package:brew_path/features/learn/presentation/course_completion_screen.dart';
import 'package:brew_path/features/learn/presentation/learn_screen.dart';
import 'package:brew_path/features/learn/presentation/module_detail_screen.dart';
import 'package:brew_path/features/learn/presentation/module_summary_screen.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_screen.dart';
import 'package:brew_path/features/lessons/presentation/lesson_screen.dart';
import 'package:brew_path/features/mini_games/presentation/mini_game_intro_screen.dart';
import 'package:brew_path/features/mini_games/presentation/mini_game_player_screen.dart';
import 'package:brew_path/features/onboarding/presentation/brewer/brewer_screen.dart';
import 'package:brew_path/features/onboarding/presentation/goal/goal_screen.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/onboarding/presentation/meet_roasty/meet_roasty_screen.dart';
import 'package:brew_path/features/onboarding/presentation/name/name_screen.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:brew_path/features/path/presentation/path_screen.dart';
import 'package:brew_path/features/profile/presentation/profile_screen.dart';
import 'package:brew_path/features/profile/presentation/settings_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/presentation/streak_screen.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/features/tour/presentation/app_guide_screen.dart';
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
  // Same shape for the course-completion gate: the redirect reads the last
  // resolved value; this tick re-runs it when the derivation lands.
  ref.listen<AsyncValue<bool>>(courseCompletionDueProvider, (prev, next) {
    refresh.value++;
  });
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.loading.path,
    refreshListenable: refresh,
    // Funnels the root (platform initial route, error-page "Home") to Loading
    // and gates the rest of the app behind the onboarding flow.
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/') {
        return AppRoutes.loading.path;
      }
      final completed = ref.read(onboardingCompletedProvider).value ?? false;
      // The intro proper — the two screens a first run is walked through.
      // Named once because the gate asks about them twice, in opposite
      // directions: an unfinished learner must be let in, a finished one
      // bounced out.
      final isIntroRoute =
          path == AppRoutes.welcome.path || path == AppRoutes.meetRoasty.path;
      final isOnboardingRoute =
          path == AppRoutes.loading.path ||
          isIntroRoute ||
          path.startsWith(AppRoutes.onboardingPrefix);
      if (!completed && !isOnboardingRoute) {
        return AppRoutes.welcome.path;
      }
      if (completed &&
          (isIntroRoute || path.startsWith(AppRoutes.onboardingPrefix))) {
        return AppRoutes.learn.path;
      }
      // The one-off completion moment intercepts arrival at Today only — the
      // ending presents where the course lived, and never hijacks another
      // tab. Presenting the screen writes the ack, which flips the gate off.
      final completionDue =
          ref.read(courseCompletionDueProvider).value ?? false;
      if (completed && completionDue && path == AppRoutes.learn.path) {
        return AppRoutes.courseComplete.path;
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
        path: AppRoutes.meetRoasty.path,
        name: AppRoutes.meetRoasty.name,
        builder: (context, state) => const MeetRoastyScreen(),
      ),
      // Root-level so the ending covers the whole screen — no shell, no tabs.
      GoRoute(
        path: AppRoutes.courseComplete.path,
        name: AppRoutes.courseComplete.name,
        builder: (context, state) => const CourseCompletionScreen(),
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
      GoRoute(
        path: AppRoutes.onboardingName.path,
        name: AppRoutes.onboardingName.name,
        builder: (context, state) => const NameScreen(),
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
                  // Both sit inside the shell on purpose: neither looking a
                  // word up nor checking what you kept should cost the learner
                  // their tab.
                  GoRoute(
                    path: AppRoutes.saved.path,
                    name: AppRoutes.saved.name,
                    builder: (context, state) => const SavedScreen(),
                  ),
                  GoRoute(
                    path: AppRoutes.dictionary.path,
                    name: AppRoutes.dictionary.name,
                    builder: (context, state) => const DictionaryHomeScreen(),
                    routes: [
                      GoRoute(
                        path: AppRoutes.dictionaryTerm.path,
                        name: AppRoutes.dictionaryTerm.name,
                        builder: (context, state) => TermDetailScreen(
                          termId: state.pathParameters['termId']!,
                        ),
                      ),
                    ],
                  ),
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
                    ),
                    routes: [
                      GoRoute(
                        path: AppRoutes.lessonComplete.path,
                        name: AppRoutes.lessonComplete.name,
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => LessonCompletionScreen(
                          lessonId: state.pathParameters['lessonId']!,
                          mastery: MasteryResult(
                            correct:
                                int.tryParse(
                                  state.uri.queryParameters['correct'] ?? '',
                                ) ??
                                0,
                            total:
                                int.tryParse(
                                  state.uri.queryParameters['total'] ?? '',
                                ) ??
                                0,
                          ),
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
                    path: AppRoutes.miniGameIntro.path,
                    name: AppRoutes.miniGameIntro.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => MiniGameIntroScreen(
                      formatId: state.pathParameters['gameId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: AppRoutes.miniGamePlay.path,
                        name: AppRoutes.miniGamePlay.name,
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => MiniGamePlayerScreen(
                          formatId: state.pathParameters['gameId']!,
                        ),
                      ),
                    ],
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
                    routes: [
                      // Under Settings because that is the only way in:
                      // Help & Support is a section of Settings, not of
                      // Profile.
                      GoRoute(
                        path: AppRoutes.appGuide.path,
                        name: AppRoutes.appGuide.name,
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => const AppGuideScreen(),
                      ),
                    ],
                  ),
                  // Pushed on the root navigator so the streak view covers
                  // the bottom-nav shell, exactly as Settings does.
                  GoRoute(
                    path: AppRoutes.profileStreak.path,
                    name: AppRoutes.profileStreak.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const StreakScreen(),
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
