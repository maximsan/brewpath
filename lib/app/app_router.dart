import 'dart:async';

import 'package:brew_path/app/analytics_navigator_observer.dart';
import 'package:brew_path/app/app_redirect.dart';
import 'package:brew_path/app/app_shell.dart';
import 'package:brew_path/app/pending_link.dart';
import 'package:brew_path/app/refused_lesson.dart';
import 'package:brew_path/core/constants/app_links.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/cards/presentation/card_deep_link.dart';
import 'package:brew_path/features/cards/presentation/cards_screen.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_screen.dart';
import 'package:brew_path/features/dictionary/presentation/term_detail_screen.dart';
import 'package:brew_path/features/dictionary/presentation/term_of_day_screen.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_game_screen.dart';
import 'package:brew_path/features/learn/domain/course_completion_providers.dart';
import 'package:brew_path/features/learn/presentation/course_completion_screen.dart';
import 'package:brew_path/features/learn/presentation/learn_screen.dart';
import 'package:brew_path/features/learn/presentation/module_complete_screen.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_screen.dart';
import 'package:brew_path/features/lessons/presentation/lesson_screen.dart';
import 'package:brew_path/features/mini_games/presentation/mini_game_intro_screen.dart';
import 'package:brew_path/features/mini_games/presentation/mini_game_player_screen.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/monetization/presentation/plus_gate_sheet.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/onboarding/presentation/meet_roasty/meet_roasty_screen.dart';
import 'package:brew_path/features/onboarding/presentation/name/name_screen.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:brew_path/features/path/presentation/path_screen.dart';
import 'package:brew_path/features/profile/presentation/profile_screen.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_destinations.dart';
import 'package:brew_path/features/profile/presentation/settings_screen.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/streak_screen.dart';
import 'package:brew_path/features/progress/presentation/tree_screen.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/features/studio/presentation/studio_screen.dart';
import 'package:brew_path/features/tour/presentation/app_guide_screen.dart';
import 'package:brew_path/services/analytics/analytics_provider.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
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
  // And for the course wall: a purchase changes what the learner may open, and
  // the redirect has to be asked again rather than leaving them standing in
  // front of a wall they have just paid to remove.
  ref.listen<AsyncValue<bool>>(courseEntitlementProvider, (prev, next) {
    refresh.value++;
  });
  final refused = ref.watch(refusedLessonProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.loading.path,
    refreshListenable: refresh,
    // Every gate lives in `redirectFor`, as one pure function — see there
    // for the rules. This end reads the state they are decided from.
    //
    // Unresolved gates read as false, which sends a paying learner to Profile
    // for one tick rather than showing a free one the chooser.
    redirect: (context, state) {
      final destination = redirectFor(
        location: state.uri,
        gates: GateState(
          onboardingCompleted:
              ref.read(onboardingCompletedProvider).value ?? false,
          courseEntitled: ref.read(courseEntitlementProvider).value ?? false,
          courseCompletionDue:
              ref.read(courseCompletionDueProvider).value ?? false,
          completedLessonIds: _finishedLessons(ref),
        ),
        pending: ref.read(pendingLinkProvider),
        refused: refused,
      );
      _raiseOfferForRefusedLesson(ref, refused);
      return destination;
    },
    observers: [
      AnalyticsNavigatorObserver(ref.watch(analyticsServiceProvider)),
    ],
    // A universal link makes any URL reachable from outside the app, so an
    // address the router cannot match is now something a stranger can hand
    // the learner. #34 rules it degrades silently rather than onto a page
    // that says the app is broken.
    onException: (context, state, router) => router.go(AppRoutes.learn.path),
    routes: [
      // The published card address. Registered so it *matches* — go_router
      // runs no redirect for a location nothing matches, it goes straight to
      // the error page. The rule itself lives in `forwardPublicCardAddress`,
      // beside the other routing rules and testable without a router.
      GoRoute(
        path: AppLinks.cardPrefix,
        redirect: (context, state) => forwardPublicCardAddress(state.uri),
        routes: [
          GoRoute(
            path: ':cardId',
            redirect: (context, state) => forwardPublicCardAddress(state.uri),
          ),
        ],
      ),
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
                    path: AppRoutes.vocabGame.path,
                    name: AppRoutes.vocabGame.name,
                    builder: (context, state) => const VocabGameScreen(),
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
                  // The flashcards drill, reached from the dictionary, the
                  // shelf, the practice list and Keep Sharp. On the root
                  // navigator like every other run, so a drill covers the
                  // bottom nav rather than sitting inside it — and pushed, so
                  // closing it returns the learner to whichever of the four
                  // they came from.
                  GoRoute(
                    path: AppRoutes.flashcards.path,
                    name: AppRoutes.flashcards.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const FlashcardsScreen(),
                  ),
                  // Today's term, opened from the dictionary's banner. On
                  // the root navigator for the same reason the drills are: it
                  // is a page the learner steps into and closes, not a place
                  // in the shell.
                  GoRoute(
                    path: AppRoutes.termOfDay.path,
                    name: AppRoutes.termOfDay.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const TermOfDayScreen(),
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
                  // The module ending. A lesson that closes its module comes
                  // straight here and plays no lesson ending, so the run's own
                  // facts ride the query string — see `moduleSummary`.
                  GoRoute(
                    path: AppRoutes.moduleSummary.path,
                    name: AppRoutes.moduleSummary.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) {
                      final query = state.uri.queryParameters;
                      return ModuleCompleteScreen(
                        moduleId: state.pathParameters['moduleId']!,
                        runLessonId: query['lesson'],
                        freezeEarned: query['freeze'] == 'true',
                        fromStage: int.tryParse(query['from'] ?? ''),
                        toStage: int.tryParse(query['to'] ?? ''),
                      );
                    },
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
                    // No screen of its own: the design reads a card as a
                    // sheet over the collection (#385). The page is
                    // transparent, so what the learner sees under the sheet is
                    // the tab's own grid rather than a second copy of it
                    // pushed on top.
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      // go_router reconciles a removed page against its match
                      // list by key; without one an imperative pop here has
                      // nothing to match, and a second link arriving over the
                      // first updates the page in place instead of replacing.
                      key: state.pageKey,
                      opaque: false,
                      transitionsBuilder: (_, _, _, child) => child,
                      child: CardDeepLink(
                        cardId: state.pathParameters['cardId']!,
                      ),
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
                  // Pushed on the root navigator like Settings: the grove is
                  // a full-screen surface, not a page inside the Profile tab.
                  GoRoute(
                    path: AppRoutes.studio.path,
                    name: AppRoutes.studio.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const StudioScreen(),
                  ),
                  GoRoute(
                    path: AppRoutes.profileSettings.path,
                    name: AppRoutes.profileSettings.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const SettingsScreen(),
                    routes: [
                      // The design files the App Guide inside Help and
                      // support (`prototype/settings.jsx:589`), not on the
                      // Settings root. It sat on the root only because this
                      // screen did not exist, which #414's own comment said.
                      GoRoute(
                        path: AppRoutes.settingsHelp.path,
                        name: AppRoutes.settingsHelp.name,
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => const HelpSupportScreen(),
                        routes: [
                          GoRoute(
                            path: AppRoutes.appGuide.path,
                            name: AppRoutes.appGuide.name,
                            parentNavigatorKey: _rootKey,
                            builder: (context, state) => const AppGuideScreen(),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: AppRoutes.settingsAccount.path,
                        name: AppRoutes.settingsAccount.name,
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => const AccountSyncScreen(),
                      ),
                      GoRoute(
                        path: AppRoutes.settingsPurchases.path,
                        name: AppRoutes.settingsPurchases.name,
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => const PurchasesScreen(),
                      ),
                      GoRoute(
                        path: AppRoutes.settingsAbout.path,
                        name: AppRoutes.settingsAbout.name,
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => const AboutScreen(),
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
                  // Same shape as the streak view: pushed on the root
                  // navigator so the tree covers the bottom-nav shell.
                  GoRoute(
                    path: AppRoutes.profileTree.path,
                    name: AppRoutes.profileTree.name,
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const TreeScreen(),
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

/// The lessons the learner has finished, as the gate reads them.
///
/// Unresolved reads as none, which locks more rather than less — the direction
/// `courseEntitlement` asks every caller to fail in.
Set<String> _finishedLessons(Ref ref) =>
    ref
        .read(completedLessonsProvider)
        .value
        ?.map((record) => record.lessonId)
        .toSet() ??
    const <String>{};

/// Raises the offer for a lesson the redirect just turned away.
///
/// **After the frame, not during.** The bounce is still being resolved when
/// the redirect returns, and a sheet pushed inside a redirect has no route to
/// sit on. The offer is opened from the root navigator's overlay, which is the
/// context under it rather than its own.
void _raiseOfferForRefusedLesson(Ref ref, RefusedLesson refused) {
  final lessonId = refused.take();
  if (lessonId == null) return;
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(_showLessonOffer(ref, lessonId)),
  );
}

Future<void> _showLessonOffer(Ref ref, String lessonId) async {
  final lesson = await ref
      .read(contentRepositoryProvider)
      .getLessonById(lessonId);
  final context = _rootKey.currentState?.overlay?.context;
  // An id no bank carries keeps the silent bounce it already got: a stranger's
  // mistyped link is not a moment to sell into.
  if (lesson == null || context == null || !context.mounted) return;
  await showPlusGate(context, LockedLesson(title: lesson.title));
}
