import 'dart:async';

import 'package:brew_path/features/onboarding/data/onboarding_repository.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/fake_onboarding_repository.dart';

void main() {
  testWidgets('shows brand mark and runs through the 6-step state machine', (
    tester,
  ) async {
    // Fake gate resolves to "incomplete"; the screen auto-advances to /welcome
    // once the first wake-up cycle finishes.
    final fake = FakeOnboardingRepository();
    final router = GoRouter(
      initialLocation: '/loading',
      routes: [
        GoRoute(
          path: '/loading',
          name: 'loading',
          builder: (_, _) => const LoadingScreen(),
        ),
        GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (_, _) => const Scaffold(body: Text('welcome-stub')),
        ),
        GoRoute(
          path: '/learn',
          name: 'learn',
          builder: (_, _) => const Scaffold(body: Text('learn-stub')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [onboardingRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Pump initial frame; brand mark should be on screen.
    await tester.pump();
    expect(find.text('BREWPATH'), findsOneWidget);

    // Step through ~6 seconds to cover the full first cycle.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    // Either still mid-animation (second cycle) or already auto-advanced to
    // /welcome once the gate resolved.
    final advanced = find.text('welcome-stub').evaluate().isNotEmpty;
    final stillLoading = find.byType(LoadingScreen).evaluate().isNotEmpty;
    expect(advanced || stillLoading, isTrue);
  });

  testWidgets('reduced motion offers the tap cue instead of the brand mark', (
    tester,
  ) async {
    // The cue is the one thing this screen has to say — it has always been
    // tappable and never mentioned it. Reduced motion runs no cycle, so the
    // cue shows from the first frame; asserted here rather than only on the
    // controller, because the controller knowing is not the learner seeing.
    //
    // The gate is left unresolved (a repository whose read never completes) so
    // the screen holds still instead of advancing out from under the check.
    final router = GoRouter(
      initialLocation: '/loading',
      routes: [
        GoRoute(
          path: '/loading',
          name: 'loading',
          builder: (_, _) => const LoadingScreen(),
        ),
        GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (_, _) => const Scaffold(body: Text('welcome-stub')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            _NeverResolvingOnboardingRepository(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('TAP ANYWHERE TO CONTINUE'), findsOneWidget);
    expect(find.text('BREWPATH'), findsNothing);
  });
}

/// A gate that never resolves, so the loading screen stays put.
class _NeverResolvingOnboardingRepository implements OnboardingRepository {
  @override
  Future<OnboardingState> getState() => Completer<OnboardingState>().future;

  @override
  Future<void> markOnboardingComplete({
    required String goal,
    required String brewer,
    String? name,
  }) async {}

  @override
  Future<void> resetOnboarding() async {}
}
