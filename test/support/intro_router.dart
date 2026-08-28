import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/onboarding/presentation/meet_roasty/meet_roasty_screen.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A router over the three intro screens, built from [AppRoutes].
///
/// One harness rather than a stub per test. Both `path:` and `name:` come from
/// the catalog, because the screens navigate by *name* — a stub registering
/// paths alone throws `unknown route name` on the very tap these tests exist
/// to make, and a hand-rolled one drifts from the real router silently.
///
/// The step *after* the intro is a stub: where the flow goes next is
/// [AppRoutes.onboardingGoal]'s today and #407's to change, and pinning it
/// here would make these tests fail on a change they do not cover.
GoRouter introRouter({String? initialLocation}) => GoRouter(
  initialLocation: initialLocation ?? AppRoutes.loading.path,
  routes: [
    GoRoute(
      path: AppRoutes.loading.path,
      name: AppRoutes.loading.name,
      builder: (_, _) => const LoadingScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome.path,
      name: AppRoutes.welcome.name,
      builder: (_, _) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.meetRoasty.path,
      name: AppRoutes.meetRoasty.name,
      builder: (_, _) => const MeetRoastyScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingGoal.path,
      name: AppRoutes.onboardingGoal.name,
      builder: (_, _) => const Scaffold(body: Text(nextStepStub)),
    ),
    GoRoute(
      path: AppRoutes.learn.path,
      name: AppRoutes.learn.name,
      builder: (_, _) => const Scaffold(body: Text(learnStub)),
    ),
  ],
);

/// Marker for the screen after the intro, whichever screen that is.
const String nextStepStub = 'next-step-stub';

/// Marker for Learn, which returning learners are bounced to.
const String learnStub = 'learn-stub';
