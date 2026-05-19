// Future implementation stub. Intentionally does NOT import `in_app_purchase`
// yet — wired up only when payments go live (see docs/10-payments.md).
//
// Implementation steps (future):
// 1. InAppPurchase.instance.isAvailable() on init
// 2. Listen to InAppPurchase.instance.purchaseStream
// 3. queryProductDetails(productIds)
// 4. buyNonConsumable() / buyConsumable()
// 5. Deliver entitlement after PurchaseStatus.purchased + verifyPurchase()
// 6. Subscriptions: server-side receipt validation (not in MVP)

import 'package:coffee_quest/services/payments/payments_service.dart';
import 'package:coffee_quest/services/payments/store_product.dart';

class InAppPurchaseService implements PaymentsService {
  @override
  Future<bool> hasActiveEntitlement() =>
      throw UnimplementedError('Implement when payments go live');

  @override
  Future<List<StoreProduct>> getProducts(List<String> productIds) =>
      throw UnimplementedError();

  @override
  Future<PurchaseStatus> purchase(StoreProduct product) =>
      throw UnimplementedError();

  @override
  Future<void> restorePurchases() => throw UnimplementedError();

  @override
  Stream<PurchaseStatus> get purchaseUpdates => throw UnimplementedError();

  @override
  void dispose() {}
}
