import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every outcome the store can report, and what each one leaves behind.
///
/// Driven through the payments seam with a recording fake, so the assertions
/// are what the controller *called* and what entitlement then says — never how
/// it caches.
class _RecordingPayments implements PaymentsService {
  _RecordingPayments({
    this.outcome = PurchaseStatus.purchased,
    this.sells = true,
    this.entitledAfter = true,
    this.throws = false,
    this.offering,
    this.offeringThrows = false,
  });

  final PurchaseStatus outcome;

  /// What this fake store puts in front of the learner, baseline if unset.
  final PlusOffering? offering;

  /// Whether asking for the arm blows up — an unbuilt arm throws an Error.
  final bool offeringThrows;

  /// Whether the store offers the Plus product at all.
  final bool sells;

  /// What entitlement reports once the flow has run.
  final bool entitledAfter;

  /// Whether the store call blows up.
  final bool throws;

  /// Set only by a flow that actually grants the entitlement — a cancelled or
  /// failed purchase leaves it alone, which is the whole thing these tests are
  /// checking.
  bool granted = false;

  /// The SKU the last purchase call was handed.
  String? bought;
  int purchases = 0;
  int restores = 0;

  @override
  Future<bool> hasActiveEntitlement() async => granted;

  @override
  Future<PlusOffering> currentOffering() async {
    if (offeringThrows) throw UnimplementedError('no SKUs registered');
    return offering ?? offeringFor(MonetizationModel.oneTime);
  }

  /// Sells whatever it is asked for, so a test can drive any arm's SKU.
  @override
  Future<List<StoreProduct>> getProducts(List<String> productIds) async {
    if (throws) throw Exception('store unreachable');
    if (!sells) return const [];
    return [
      for (final id in productIds)
        StoreProduct(
          id: id,
          title: 'BrewPath Plus',
          description: 'The full course',
          price: r'$14.99',
          amount: 14.99,
          currencyCode: 'USD',
        ),
    ];
  }

  @override
  Future<PurchaseStatus> purchase(StoreProduct product) async {
    purchases++;
    bought = product.id;
    if (outcome == PurchaseStatus.purchased ||
        outcome == PurchaseStatus.restored) {
      granted = entitledAfter;
    }
    return outcome;
  }

  @override
  Future<void> restorePurchases() async {
    restores++;
    if (throws) throw Exception('store unreachable');
    granted = entitledAfter;
  }

  @override
  Stream<PurchaseStatus> get purchaseUpdates => const Stream.empty();

  @override
  void dispose() {}
}

ProviderContainer _containerWith(_RecordingPayments payments) {
  final container = ProviderContainer(
    overrides: [paymentsServiceProvider.overrideWithValue(payments)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('a purchase flips entitlement and reports it', () async {
    final payments = _RecordingPayments();
    final container = _containerWith(payments);

    expect(await container.read(courseEntitlementProvider.future), isFalse);
    await container.read(plusPurchaseProvider.notifier).buy();

    expect(payments.purchases, 1);
    expect(container.read(plusPurchaseProvider), PlusPurchaseState.owned);
    expect(await container.read(courseEntitlementProvider.future), isTrue);
  });

  test('a restore that recovers a purchase flips entitlement', () async {
    final payments = _RecordingPayments();
    final container = _containerWith(payments);

    await container.read(plusPurchaseProvider.notifier).restore();

    expect(payments.restores, 1);
    expect(payments.purchases, 0, reason: 'restore must not buy anything');
    expect(container.read(plusPurchaseProvider), PlusPurchaseState.owned);
  });

  test(
    'a restore that recovers nothing is not a failure, but is said',
    () async {
      final container = _containerWith(
        _RecordingPayments(entitledAfter: false),
      );

      await container.read(plusPurchaseProvider.notifier).restore();

      final state = container.read(plusPurchaseProvider);
      expect(state, PlusPurchaseState.nothingToRestore);
      expect(
        state,
        isNot(PlusPurchaseState.failed),
        reason: 'nobody was charged and nothing broke',
      );
    },
  );

  test('pending is not success', () async {
    final container = _containerWith(
      _RecordingPayments(outcome: PurchaseStatus.pending),
    );

    await container.read(plusPurchaseProvider.notifier).buy();

    expect(container.read(plusPurchaseProvider), PlusPurchaseState.pending);
    // The whole point: nothing is owned yet, so nothing may unlock.
    expect(await container.read(courseEntitlementProvider.future), isFalse);
  });

  test('cancelling changes nothing', () async {
    final container = _containerWith(
      _RecordingPayments(outcome: PurchaseStatus.cancelled),
    );

    await container.read(plusPurchaseProvider.notifier).buy();

    expect(container.read(plusPurchaseProvider), PlusPurchaseState.cancelled);
    expect(await container.read(courseEntitlementProvider.future), isFalse);
  });

  test('a store error fails without unlocking', () async {
    final container = _containerWith(
      _RecordingPayments(outcome: PurchaseStatus.error),
    );

    await container.read(plusPurchaseProvider.notifier).buy();

    expect(container.read(plusPurchaseProvider), PlusPurchaseState.failed);
    expect(await container.read(courseEntitlementProvider.future), isFalse);
  });

  test('a store that does not offer Plus never reaches purchase', () async {
    final payments = _RecordingPayments(sells: false);
    final container = _containerWith(payments);

    await container.read(plusPurchaseProvider.notifier).buy();

    expect(payments.purchases, 0, reason: 'no product, no purchase call');
    expect(container.read(plusPurchaseProvider), PlusPurchaseState.failed);
  });

  test('an unreachable store fails rather than throwing', () async {
    final container = _containerWith(_RecordingPayments(throws: true));

    await container.read(plusPurchaseProvider.notifier).buy();

    expect(container.read(plusPurchaseProvider), PlusPurchaseState.failed);
  });

  test('the SKU bought is the one the arm named, not a built-in', () async {
    // A store on some other arm, which is the whole point of the seam: the
    // controller must buy what it was handed rather than the baseline id.
    final payments = _RecordingPayments(
      offering: const PlusOffering(
        model: MonetizationModel.subscription,
        offers: [PlusOffer(productId: 'some.other.sku', term: PlusTerm.yearly)],
      ),
    );
    final container = _containerWith(payments);

    await container.read(plusPurchaseProvider.notifier).buy();

    expect(payments.bought, 'some.other.sku');
  });

  test('the paywall may buy an offer the learner picked', () async {
    // An arm offering more than one thing: the sheet passes the chosen offer
    // and the default must not win.
    final payments = _RecordingPayments(
      offering: const PlusOffering(
        model: MonetizationModel.hybrid,
        offers: [
          PlusOffer(productId: 'yearly.sku', term: PlusTerm.yearly),
          PlusOffer(productId: 'lifetime.sku', term: PlusTerm.lifetime),
        ],
      ),
    );
    final container = _containerWith(payments);

    await container
        .read(plusPurchaseProvider.notifier)
        .buy(
          offer: const PlusOffer(
            productId: 'lifetime.sku',
            term: PlusTerm.lifetime,
          ),
        );

    expect(payments.bought, 'lifetime.sku');
  });

  test('an arm the store cannot offer fails instead of hanging', () async {
    // `UnimplementedError` is an Error, not an Exception: caught wrongly it
    // strands the sheet on `working` and the button spins forever.
    final container = _containerWith(_RecordingPayments(offeringThrows: true));

    await container.read(plusPurchaseProvider.notifier).buy();

    expect(container.read(plusPurchaseProvider), PlusPurchaseState.failed);
  });

  test('the shipping no-op grants nothing', () async {
    // The build that ships today: no store, so no entitlement and no purchase.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(plusPurchaseProvider.notifier).buy();

    expect(container.read(plusPurchaseProvider), PlusPurchaseState.failed);
    expect(await container.read(courseEntitlementProvider.future), isFalse);
  });
}
