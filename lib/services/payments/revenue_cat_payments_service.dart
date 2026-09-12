/// The real store: RevenueCat in front of StoreKit (ADR-0024).
library;

import 'dart:async';

import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/revenue_cat_mapping.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

/// Buys through RevenueCat, and asks it what the learner owns.
///
/// RevenueCat says *which arm* a learner is on; [offeringFor] stays the one
/// home for which SKUs that arm sells.
class RevenueCatPaymentsService implements PaymentsService {
  /// Creates the service and starts listening for entitlement changes.
  ///
  /// `Purchases.configure` has already run — see `AppBootstrap.initialize`.
  RevenueCatPaymentsService() {
    rc.Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
  }

  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  /// Products from the last [getProducts], so a purchase does not re-fetch
  /// what the paywall already priced.
  final Map<String, rc.StoreProduct> _fetched = {};

  /// The last answer the store gave, returned when it cannot be reached.
  bool _lastKnown = false;

  @override
  Stream<bool> get entitlementChanges => _changes.stream;

  @override
  Future<bool> hasActiveEntitlement() async {
    try {
      return _remember(await rc.Purchases.getCustomerInfo());
    } on PlatformException {
      // RevenueCat answers from its own cache offline, so reaching here means
      // it has never answered. The last known value beats guessing.
      return _lastKnown;
    }
  }

  @override
  Future<PlusOffering> currentOffering() async {
    try {
      final offerings = await rc.Purchases.getOfferings();
      return offeringFor(armFor(offerings.current?.identifier));
    } on PlatformException {
      return offeringFor(MonetizationModel.oneTime);
    }
  }

  @override
  Future<List<StoreProduct>> getProducts(List<String> productIds) async {
    // Asked per category because RevenueCat returns subscriptions only unless
    // told otherwise, and the arms sell both kinds.
    for (final category in rc.ProductCategory.values) {
      try {
        final products = await rc.Purchases.getProducts(
          productIds,
          productCategory: category,
        );
        for (final product in products) {
          _fetched[product.identifier] = product;
        }
      } on PlatformException {
        continue;
      }
    }
    return [
      for (final id in productIds)
        if (_fetched[id] case final product?) asStoreProduct(product),
    ];
  }

  @override
  Future<PurchaseStatus> purchase(StoreProduct product) async {
    if (!_fetched.containsKey(product.id)) await getProducts([product.id]);
    final target = _fetched[product.id];
    if (target == null) return PurchaseStatus.error;

    try {
      final result = await rc.Purchases.purchase(
        rc.PurchaseParams.storeProduct(target),
      );
      // A purchase awaiting someone else's approval completes without granting
      // anything, so the entitlement decides — not the call returning.
      return _remember(result.customerInfo)
          ? PurchaseStatus.purchased
          : PurchaseStatus.pending;
    } on PlatformException catch (error) {
      return rc.PurchasesErrorHelper.getErrorCode(error) ==
              rc.PurchasesErrorCode.purchaseCancelledError
          ? PurchaseStatus.cancelled
          : PurchaseStatus.error;
    }
  }

  @override
  Future<void> restorePurchases() async {
    _remember(await rc.Purchases.restorePurchases());
  }

  @override
  void dispose() {
    rc.Purchases.removeCustomerInfoUpdateListener(_onCustomerInfo);
    unawaited(_changes.close());
  }

  void _onCustomerInfo(rc.CustomerInfo info) {
    _remember(info);
    if (!_changes.isClosed) _changes.add(_lastKnown);
  }

  /// Records what the store said and hands it back, so every path that reads
  /// customer info keeps the offline fallback current.
  bool _remember(rc.CustomerInfo info) => _lastKnown = isEntitled(info);
}
