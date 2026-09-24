import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/features/monetization/domain/paywall_view_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/domain/purchase_welcome_return.dart';
import 'package:brew_path/features/monetization/presentation/paywall_route.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/widget_harness.dart';

// The offer a lock hands off to: a sale goes on to the celebration carrying
// the lock's screen, and the other two doors go straight back to it.
void main() {
  setUp(useInMemoryDatabase);

  const pitch = PlusPitch(
    premiumFormats: 4,
    firstPaidModule: 2,
    lastPaidModule: 5,
    remainingLessons: 29,
    lockedGames: 4,
    referenceTerms: 8,
    savedFreeCap: 5,
  );

  const oneTime = PlusOffering(
    model: MonetizationModel.oneTime,
    offers: [PlusOffer(productId: 'lifetime.sku', term: PlusTerm.lifetime)],
  );

  const lifetime = StoreProduct(
    id: 'lifetime.sku',
    title: 'Foundations',
    description: 'The full course',
    price: r'$49.99',
    amount: 49.99,
    currencyCode: 'USD',
  );

  late GoRouter router;
  late ProviderContainer container;

  GoRoute stub(AppRoute route) => GoRoute(
    path: route.path,
    name: route.name,
    builder: (_, _) => Scaffold(body: Text(route.name)),
  );

  Future<void> pump(
    WidgetTester tester, {
    String? returnTo,
    bool owned = false,
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        plusPitchProvider.overrideWith((ref) async => pitch),
        courseEntitlementProvider.overrideWith((ref) async => owned),
        paywallViewProvider.overrideWith(
          (ref) async =>
              buildPaywallView(offering: oneTime, products: const [lifetime]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final paywall = Uri.parse(AppRoutes.paywall.path).replace(
      queryParameters: returnTo == null ? null : welcomeReturnTo(returnTo),
    );

    router = GoRouter(
      initialLocation: paywall.toString(),
      routes: [
        GoRoute(
          path: AppRoutes.paywall.path,
          name: AppRoutes.paywall.name,
          builder: (_, state) =>
              PaywallRoute(returnTo: welcomeReturnIn(state.uri)),
        ),
        stub(AppRoutes.purchaseWelcome),
        stub(AppRoutes.learn),
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
    await tester.pumpAndSettle();
  }

  Future<void> leaveBy(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('a sale goes on to the celebration, still carrying the lock', (
    tester,
  ) async {
    await pump(tester, returnTo: AppRoutes.path.path);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.owned;
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.purchaseWelcome.path);
    expect(welcomeReturnIn(router.state.uri), AppRoutes.path.path);
  });

  testWidgets('Maybe later goes back to the lock, with nothing bought', (
    tester,
  ) async {
    await pump(tester, returnTo: AppRoutes.path.path);

    await leaveBy(tester, PaywallCopy.maybeLater);

    expect(router.state.uri.toString(), AppRoutes.path.path);
  });

  testWidgets('a restore goes back to the lock, not to the celebration', (
    tester,
  ) async {
    await pump(tester, returnTo: AppRoutes.path.path, owned: true);

    await leaveBy(tester, PaywallCopy.restore.toUpperCase());

    expect(router.state.uri.toString(), AppRoutes.path.path);
  });

  testWidgets('with nowhere to go back to, declining goes to Learn', (
    tester,
  ) async {
    await pump(tester);

    await leaveBy(tester, PaywallCopy.maybeLater);

    expect(router.state.uri.path, AppRoutes.learn.path);
  });
}
