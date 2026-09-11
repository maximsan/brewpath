import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/purchase_welcome_return.dart';
import 'package:brew_path/features/monetization/domain/purchased_term.dart';
import 'package:brew_path/features/monetization/presentation/purchase_welcome_route.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// The celebration says what was bought, and both its doors lead somewhere: the
// route reads the term the paywall recorded and the location the sale
// happened on.
void main() {
  late GoRouter router;

  GoRoute stub(AppRoute route, {List<GoRoute> routes = const []}) => GoRoute(
    path: route.path,
    name: route.name,
    routes: routes,
    builder: (_, _) => Scaffold(body: Text(route.name)),
  );

  Future<void> pump(
    WidgetTester tester, {
    PlusTerm? recorded,
    String? returnTo,
  }) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    if (recorded != null) {
      container.read(purchasedTermProvider.notifier).term = recorded;
    }

    final welcome = Uri.parse(AppRoutes.purchaseWelcome.path).replace(
      queryParameters: returnTo == null ? null : welcomeReturnTo(returnTo),
    );

    router = GoRouter(
      initialLocation: welcome.toString(),
      routes: [
        GoRoute(
          path: AppRoutes.purchaseWelcome.path,
          name: AppRoutes.purchaseWelcome.name,
          builder: (_, state) =>
              PurchaseWelcomeRoute(returnTo: welcomeReturnIn(state.uri)),
        ),
        stub(AppRoutes.learn),
        // The Studio sits under Profile in the real router, and the stub keeps
        // that nesting so the name resolves to the address the app uses.
        stub(AppRoutes.profile, routes: [stub(AppRoutes.studio)]),
        stub(AppRoutes.path),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.cupping,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
  }

  /// Advances past the route change without settling: the celebration draws
  /// the mascot, whose idle loop never ends.
  Future<void> leaveBy(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('celebrates the plan the paywall recorded', (tester) async {
    await pump(tester, recorded: PlusTerm.monthly);

    final monthly = paywallPlans[PlusTerm.monthly]!;
    expect(find.text(monthly.welcome), findsOneWidget);
    expect(find.text(monthly.welcomeNote.toUpperCase()), findsOneWidget);
  });

  testWidgets('with nothing recorded, it reads as the one-time purchase', (
    tester,
  ) async {
    await pump(tester);

    final lifetime = paywallPlans[PlusTerm.lifetime]!;
    expect(find.text(lifetime.welcome), findsOneWidget);
    expect(find.text(lifetime.welcomeNote.toUpperCase()), findsOneWidget);
  });

  testWidgets('Open the Studio opens the Studio', (tester) async {
    await pump(tester);
    await leaveBy(tester, PaywallCopy.welcomeOpenStudio);

    expect(
      router.state.uri.path,
      '${AppRoutes.profile.path}/${AppRoutes.studio.path}',
    );
  });

  testWidgets('Back to learning returns where the sale happened', (
    tester,
  ) async {
    await pump(tester, returnTo: AppRoutes.path.path);
    await leaveBy(tester, PaywallCopy.welcomeBackToLearning);

    expect(router.state.uri.toString(), AppRoutes.path.path);
  });

  testWidgets('a sale with nowhere to go back to goes to Learn', (
    tester,
  ) async {
    await pump(tester);
    await leaveBy(tester, PaywallCopy.welcomeBackToLearning);

    expect(router.state.uri.path, AppRoutes.learn.path);
  });
}
