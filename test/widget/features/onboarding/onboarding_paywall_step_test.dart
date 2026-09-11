import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/features/onboarding/presentation/paywall/onboarding_paywall_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/fake_onboarding_repository.dart';

// The intro's last step: both exits finish onboarding, and neither requires
// paying (ADR-0010).
void main() {
  late FakeOnboardingRepository fake;

  setUp(() => fake = FakeOnboardingRepository());

  const pitch = PlusPitch(
    premiumFormats: 4,
    firstPaidModule: 2,
    lastPaidModule: 5,
    remainingLessons: 29,
    lockedGames: 4,
    referenceTerms: 8,
    savedFreeCap: 5,
  );

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    bool owned = false,
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: AppRoutes.onboardingPaywall.path,
      routes: [
        GoRoute(
          path: AppRoutes.onboardingPaywall.path,
          name: AppRoutes.onboardingPaywall.name,
          builder: (_, _) => const OnboardingPaywallStep(),
        ),
        GoRoute(
          path: AppRoutes.learn.path,
          name: AppRoutes.learn.name,
          builder: (_, _) => const Scaffold(body: Text('stub-learn')),
        ),
        GoRoute(
          path: AppRoutes.purchaseWelcome.path,
          name: AppRoutes.purchaseWelcome.name,
          builder: (_, _) => const Scaffold(body: Text('stub-welcome')),
        ),
      ],
    );
    addTearDown(router.dispose);

    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(fake),
        plusPitchProvider.overrideWith((ref) async => pitch),
        courseEntitlementProvider.overrideWith((ref) async => owned),
      ],
    );
    addTearDown(container.dispose);

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
    return container;
  }

  testWidgets('declining finishes the intro and opens the app', (tester) async {
    await pump(tester);

    await tester.ensureVisible(find.text(PaywallCopy.maybeLater));
    await tester.pumpAndSettle();
    await tester.tap(find.text(PaywallCopy.maybeLater));
    await tester.pumpAndSettle();

    expect(fake.completeCalls, hasLength(1));
    expect(find.text('stub-learn'), findsOneWidget);
  });

  testWidgets('buying finishes the intro and celebrates', (tester) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.owned;
    await tester.pumpAndSettle();

    expect(fake.completeCalls, hasLength(1));
    expect(find.text('stub-welcome'), findsOneWidget);
  });

  testWidgets('restoring finishes the intro without the celebration', (
    tester,
  ) async {
    await pump(tester, owned: true);

    await tester.ensureVisible(find.text(PaywallCopy.restore.toUpperCase()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(PaywallCopy.restore.toUpperCase()));
    await tester.pumpAndSettle();

    expect(fake.completeCalls, hasLength(1));
    expect(find.text('stub-learn'), findsOneWidget);
  });

  testWidgets('the intro is finished once, however the exits race', (
    tester,
  ) async {
    final container = await pump(tester);

    // A real race: the store answers while a tap on Maybe later is on its way.
    await tester.ensureVisible(find.text(PaywallCopy.maybeLater));
    await tester.pumpAndSettle();
    await tester.tap(find.text(PaywallCopy.maybeLater));
    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.owned;
    await tester.pumpAndSettle();

    expect(fake.completeCalls, hasLength(1));
  });
}
