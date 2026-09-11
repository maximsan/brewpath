import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/features/monetization/domain/paywall_view_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/presentation/paywall_screen.dart';
import 'package:brew_path/features/monetization/presentation/plan_picker.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

// The offer as a screen: what it says, the two ways out, and the store chrome
// a non-consumable may not ship without.
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

  final oneTimeCopy = paywallModels[MonetizationModel.oneTime]!;

  late List<String> exits;

  setUp(() => exits = []);

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    PlusOffering offering = oneTime,
    List<StoreProduct> products = const [lifetime],
    bool owned = false,
  }) async {
    // Tall enough to hold the whole offer: the body is a lazy list, so a
    // default-sized surface never builds the note or the store links, and an
    // assertion about them would be about the viewport rather than the screen.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        plusPitchProvider.overrideWith((ref) async => pitch),
        // What the store answers when a restore asks whether Plus is owned.
        courseEntitlementProvider.overrideWith((ref) async => owned),
        paywallViewProvider.overrideWith(
          (ref) async =>
              buildPaywallView(offering: offering, products: products),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: PaywallScreen(
            onPurchased: () => exits.add('purchased'),
            onRestored: () => exits.add('restored'),
            onDeclined: () => exits.add('declined'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  /// The legal row's links are drawn uppercased, as the design sets them.
  Finder legalLink(String label) => find.text(label.toUpperCase());

  Future<void> tapAction(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets("offers the course on the design's own terms", (tester) async {
    await pump(tester);

    expect(find.text(oneTimeCopy.heroTitle), findsOneWidget);
    expect(find.text(oneTimeCopy.paywallNote.toUpperCase()), findsOneWidget);
    // Smallcaps is the eyebrow's type rule, so it renders the copy uppercased.
    expect(
      find.textContaining(
        '${PaywallCopy.course} · ${oneTimeCopy.eyebrow}'.toUpperCase(),
      ),
      findsOneWidget,
    );
  });

  testWidgets('lists what the purchase contains, counted from the banks', (
    tester,
  ) async {
    await pump(tester);

    for (final benefit in paywallBenefitsFor(pitch)) {
      expect(find.textContaining(benefit.title, findRichText: true), findsOne);
      expect(find.textContaining(benefit.detail, findRichText: true), findsOne);
    }
  });

  testWidgets('names the price the store gave, never one of its own', (
    tester,
  ) async {
    await pump(tester);

    expect(find.textContaining(lifetime.price), findsWidgets);
    expect(find.textContaining(pricePlaceholder), findsNothing);
  });

  testWidgets('sells one thing — no plan chooser, no trial', (tester) async {
    await pump(tester);

    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.byType(PlanPicker), findsNothing);
    expect(find.textContaining('trial', findRichText: true), findsNothing);
    expect(find.textContaining('/month'), findsNothing);
  });

  testWidgets('carries Restore, Terms and Privacy', (tester) async {
    await pump(tester);

    expect(legalLink(PaywallCopy.restore), findsOneWidget);
    expect(legalLink(PaywallCopy.terms), findsOneWidget);
    expect(legalLink(PaywallCopy.privacy), findsOneWidget);
  });

  testWidgets('Terms and Privacy are drawn but inert until #448', (
    tester,
  ) async {
    await pump(tester);

    for (final label in [PaywallCopy.terms, PaywallCopy.privacy]) {
      final link = tester.widget<TextButton>(
        find.ancestor(
          of: legalLink(label),
          matching: find.byType(TextButton),
        ),
      );
      expect(link.onPressed, isNull, reason: '$label has no URL yet');
    }
  });

  testWidgets('Maybe later leaves without buying', (tester) async {
    await pump(tester);

    await tapAction(tester, PaywallCopy.maybeLater);

    expect(exits, ['declined']);
  });

  testWidgets('buying leaves by the bought door', (tester) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.owned;
    await tester.pump();

    expect(exits, ['purchased']);
  });

  testWidgets('restoring leaves by its own door, not the sale', (tester) async {
    await pump(tester, owned: true);

    await tapAction(tester, PaywallCopy.restore.toUpperCase());

    expect(
      exits,
      ['restored'],
      reason: 'recovering a purchase is not a sale to celebrate',
    );
  });

  testWidgets('a sale after a restore that found nothing is still a sale', (
    tester,
  ) async {
    final container = await pump(tester);

    await tapAction(tester, PaywallCopy.restore.toUpperCase());
    expect(find.text(PlusCopy.nothingToRestore), findsOneWidget);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.owned;
    await tester.pump();

    expect(
      exits,
      ['purchased'],
      reason: 'the restore is over; the door is chosen per press',
    );
  });

  testWidgets('a restore that finds nothing says so', (tester) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.nothingToRestore;
    await tester.pump();

    expect(find.text(PlusCopy.nothingToRestore), findsOneWidget);
    expect(exits, isEmpty);
  });

  testWidgets('a refusal leaves the learner on the offer, and says so', (
    tester,
  ) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.failed;
    await tester.pump();

    expect(find.text(PlusCopy.failed), findsOneWidget);
    expect(exits, isEmpty);
  });

  testWidgets('the store cannot be asked twice while it is deciding', (
    tester,
  ) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.working;
    await tester.pump();

    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<GhostButton>(find.byType(GhostButton)).onPressed,
      isNull,
    );
  });

  testWidgets('the close stays live, so it is never a dead control', (
    tester,
  ) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.working;
    await tester.pump();

    await tester.tap(find.byTooltip(PaywallCopy.close));
    await tester.pump();

    expect(exits, ['declined']);
  });

  testWidgets('Restore says it is looking while the store is', (tester) async {
    final container = await pump(tester);

    container.read(plusPurchaseProvider.notifier).state =
        PlusPurchaseState.working;
    await tester.pump();

    expect(legalLink(PaywallCopy.restoring), findsOneWidget);
    expect(legalLink(PaywallCopy.restore), findsNothing);
  });

  testWidgets('a hybrid arm draws its rows, preselects yearly and buys it', (
    tester,
  ) async {
    const yearly = StoreProduct(
      id: 'yearly.sku',
      title: 'Foundations',
      description: 'A year of the course',
      price: r'$23.99',
      amount: 23.99,
      currencyCode: 'USD',
    );
    const monthly = StoreProduct(
      id: 'monthly.sku',
      title: 'Foundations',
      description: 'A month of the course',
      price: r'$3.99',
      amount: 3.99,
      currencyCode: 'USD',
    );
    const hybrid = PlusOffering(
      model: MonetizationModel.hybrid,
      offers: [
        PlusOffer(productId: 'monthly.sku', term: PlusTerm.monthly),
        PlusOffer(productId: 'yearly.sku', term: PlusTerm.yearly),
        PlusOffer(productId: 'lifetime.sku', term: PlusTerm.lifetime),
      ],
      preselected: PlusTerm.yearly,
    );

    await pump(
      tester,
      offering: hybrid,
      products: const [monthly, yearly, lifetime],
    );

    expect(find.byType(PlanPicker), findsOneWidget);
    expect(find.text('Lifetime'), findsOneWidget);
    expect(find.text(r'$2/month, billed yearly'), findsOneWidget);
    expect(find.text('SAVE 50%'), findsOneWidget);
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).label,
      r'Subscribe — $23.99/year',
    );
  });

  testWidgets('a store that named no price sells nothing', (tester) async {
    await pump(tester, products: const []);

    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
      reason: 'a paywall that cannot name a price must not take money',
    );
    expect(find.text(PaywallCopy.storeUnreachable), findsOneWidget);
  });
}
