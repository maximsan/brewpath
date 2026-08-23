import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/onboarding/presentation/name/name_screen.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/fake_onboarding_repository.dart';

/// The last onboarding step, and the only optional one. Exercised against a
/// fake repository like the two pick screens — the draft is all it needs.
void main() {
  late FakeOnboardingRepository fake;

  setUp(() => fake = FakeOnboardingRepository());

  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.onboardingName.path,
      routes: [
        GoRoute(
          path: AppRoutes.onboardingName.path,
          name: AppRoutes.onboardingName.name,
          builder: (_, _) => const NameScreen(),
        ),
        GoRoute(
          path: AppRoutes.learn.path,
          name: AppRoutes.learn.name,
          builder: (_, _) => const Scaffold(body: Text('stub-learn')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        // ignore: scoped_providers_should_specify_dependencies — test-only root override
        overrides: [onboardingRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    // The two earlier steps ran before this screen in the real flow.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(NameScreen)),
    );
    container.read(onboardingDraftProvider.notifier)
      ..setGoal('brew_better')
      ..setBrewer('v60');
  }

  testWidgets('offers to skip until something is typed', (tester) async {
    await pump(tester);

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('a typed name finishes onboarding carrying it', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(fake.completeCalls, [
      (goal: 'brew_better', brewer: 'v60', name: 'Maya'),
    ]);
    expect(find.text('stub-learn'), findsOneWidget);
  });

  testWidgets('skipping finishes onboarding with no name', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(fake.completeCalls.single.name, isNull);
    expect(find.text('stub-learn'), findsOneWidget);
  });

  testWidgets('the step says it is optional', (tester) async {
    await pump(tester);

    expect(find.text('What should we call you?'), findsOneWidget);
    expect(find.textContaining('You can skip this'), findsOneWidget);
  });
}
