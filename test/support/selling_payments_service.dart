import 'dart:async';

import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';

/// A store that starts a learner outside the course and lets them in.
///
/// The shipped stub cancels every purchase and the granted one owns the course
/// before the app boots, so neither can reach what happens after a sale.
class SellingPaymentsService implements PaymentsService {
  /// Creates a store on [model] whose Restore recovers a purchase only when
  /// [restorable].
  SellingPaymentsService({
    this.model = MonetizationModel.oneTime,
    this.restorable = false,
  });

  /// The arm this store puts every learner on.
  final MonetizationModel model;

  /// Whether Restore finds a purchase made earlier on another device.
  final bool restorable;

  bool _owned = false;

  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  @override
  Future<bool> hasActiveEntitlement() async => _owned;

  @override
  Future<PlusOffering> currentOffering() async => offeringFor(model);

  @override
  Future<List<StoreProduct>> getProducts(List<String> productIds) async => [
    for (final id in productIds)
      StoreProduct(
        id: id,
        title: 'Foundations',
        description: 'The full course',
        price: r'$49.99',
        amount: 49.99,
        currencyCode: 'USD',
      ),
  ];

  @override
  Future<PurchaseStatus> purchase(StoreProduct product) async {
    _owned = true;
    return PurchaseStatus.purchased;
  }

  @override
  Future<void> restorePurchases() async {
    if (restorable) _owned = true;
  }

  @override
  Stream<bool> get entitlementChanges => _changes.stream;

  /// Ends the subscription the way a lapse or a refund does — from the store,
  /// with the app already open.
  void lapse() {
    _owned = false;
    _changes.add(false);
  }

  @override
  void dispose() => _changes.close();
}
