// Future implementation stub. Intentionally does NOT import `in_app_purchase`
// yet — the steps and their order live in docs/10-payments.md, Future
// Implementation Checklist.

import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';

/// Real [PaymentsService] backed by `in_app_purchase` (stubbed for now).
class InAppPurchaseService implements PaymentsService {
  @override
  Future<bool> hasActiveEntitlement() =>
      throw UnimplementedError('Implement when payments go live');

  @override
  Future<PlusOffering> currentOffering() => throw UnimplementedError();

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
