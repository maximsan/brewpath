import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_offering_provider.dart';
import 'package:brew_path/features/monetization/domain/purchased_term.dart';
import 'package:brew_path/features/monetization/presentation/purchases_panel.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

// Settings' Purchases: what an owner is told, and the way in for everyone
// else.
void main() {
  setUp(useInMemoryDatabase);

  Future<void> pump(
    WidgetTester tester, {
    required bool owned,
    MonetizationModel model = MonetizationModel.oneTime,
    PlusTerm? term,
  }) async {
    final container = ProviderContainer(
      overrides: [
        courseEntitlementProvider.overrideWith((ref) async => owned),
        plusOfferingProvider.overrideWith((ref) async => offeringFor(model)),
      ],
    );
    addTearDown(container.dispose);
    if (term != null) {
      container.read(purchasedTermProvider.notifier).term = term;
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: const Scaffold(body: PurchasesPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a free learner is offered the course and Restore', (
    tester,
  ) async {
    await pump(tester, owned: false);

    expect(find.text(PaywallCopy.unlock), findsOneWidget);
    expect(find.text(PaywallCopy.restore), findsOneWidget);
    for (final line
        in paywallModels[MonetizationModel.oneTime]!.purchasesFooter) {
      expect(find.text(line), findsOneWidget);
    }
  });

  testWidgets('the free state names the arm this learner is on', (
    tester,
  ) async {
    await pump(tester, owned: false, model: MonetizationModel.subscription);

    for (final line
        in paywallModels[MonetizationModel.subscription]!.purchasesFooter) {
      expect(find.text(line), findsOneWidget);
    }
  });

  testWidgets('an owner is told what they hold, and offered nothing', (
    tester,
  ) async {
    await pump(tester, owned: true);

    expect(
      // The chip is smallcaps, which the design draws uppercased.
      find.text(paywallPlans[PlusTerm.lifetime]!.ownedChip.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(PaywallCopy.unlock), findsNothing);
  });

  testWidgets('a renewing plan offers the way out to Apple', (tester) async {
    await pump(tester, owned: true, term: PlusTerm.yearly);

    expect(find.text(PaywallCopy.manageSubscription), findsOneWidget);
  });

  testWidgets('a one-time purchase offers nothing to manage', (tester) async {
    await pump(tester, owned: true, term: PlusTerm.lifetime);

    expect(find.text(PaywallCopy.manageSubscription), findsNothing);
  });
}
