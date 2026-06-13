import 'package:coffee_quest/features/onboarding/presentation/brewer/brewer_screen.dart';
import 'package:coffee_quest/features/onboarding/presentation/goal/goal_screen.dart';
import 'package:coffee_quest/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/fake_onboarding_repository.dart';

/// Covers the shared PickCard + Continue contract used by both onboarding pick
/// screens. The view is exercised against a fake [onboardingRepositoryProvider]
/// — no Drift, no platform channels — since these screens only need the draft
/// state, not a real database.
void main() {
  late FakeOnboardingRepository fake;

  setUp(() => fake = FakeOnboardingRepository());

  Widget wrap(GoRouter router) => ProviderScope(
    // ignore: scoped_providers_should_specify_dependencies — test-only root override
    overrides: [onboardingRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp.router(routerConfig: router),
  );

  testWidgets('Goal: Continue is disabled until a card is picked', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/onboarding/goal',
      routes: [
        GoRoute(
          path: '/onboarding/goal',
          builder: (_, _) => const GoalScreen(),
        ),
        GoRoute(
          path: '/onboarding/brewer',
          builder: (_, _) => const _Stub('brewer'),
        ),
        GoRoute(path: '/learn', builder: (_, _) => const _Stub('learn')),
      ],
    );
    await tester.pumpWidget(wrap(router));
    await tester.pump();

    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(continueButton, findsOneWidget);
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    await tester.tap(find.text('Brew better at home'));
    await tester.pump();
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets('Brewer: tapping different cards swaps selection', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/onboarding/brewer',
      routes: [
        GoRoute(
          path: '/onboarding/brewer',
          builder: (_, _) => const BrewerScreen(),
        ),
        GoRoute(path: '/learn', builder: (_, _) => const _Stub('learn')),
      ],
    );
    await tester.pumpWidget(wrap(router));
    await tester.pump();

    await tester.tap(find.text('V60'));
    await tester.pump();
    await tester.tap(find.text('AeroPress'));
    await tester.pump();

    final btn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(btn.onPressed, isNotNull);
  });
}

class _Stub extends StatelessWidget {
  const _Stub(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('stub-$label')));
}
