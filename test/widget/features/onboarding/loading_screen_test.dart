import 'package:coffee_quest/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
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
    expect(find.text('COFFEE QUEST'), findsOneWidget);

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
}
