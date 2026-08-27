import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// WelcomeScreen reads no onboarding providers (it only navigates), so the view
/// renders against a plain ProviderScope — no repository or database needed.
void main() {
  testWidgets('renders headline + CTA and routes to /onboarding/goal', (
    tester,
  ) async {
    // Names as well as paths: the screen navigates by route *name*, as the
    // router owns the path. A stub that registered paths alone would throw
    // `unknown route name` on the tap this test exists to make.
    final router = GoRouter(
      initialLocation: AppRoutes.welcome.path,
      routes: [
        GoRoute(
          path: AppRoutes.welcome.path,
          name: AppRoutes.welcome.name,
          builder: (_, _) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboardingGoal.path,
          name: AppRoutes.onboardingGoal.name,
          builder: (_, _) => const Scaffold(body: Text('goal-stub')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    // The video_player platform channel is unavailable in unit tests, so the
    // hero falls back to a static Roasty. Roasty's idle animation runs forever;
    // bounded pumps instead of `pumpAndSettle`.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('BREWPATH'), findsOneWidget);
    expect(find.textContaining('Plant your tree.'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Plant your seed'),
      findsOneWidget,
    );

    final cta = find.widgetWithText(FilledButton, 'Plant your seed');
    await tester.ensureVisible(cta);
    await tester.pump();
    await tester.tap(cta);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('goal-stub'), findsOneWidget);
  });
}
