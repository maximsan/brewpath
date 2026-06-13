import 'package:coffee_quest/services/payments/payments_service.dart';
import 'package:coffee_quest/services/payments/store_product.dart';

/// Active payments implementation for the MVP — no store, no entitlements.
class NoOpPaymentsService implements PaymentsService {
  /// Creates a [NoOpPaymentsService].
  const NoOpPaymentsService();

  @override
  Future<bool> hasActiveEntitlement() async => false;

  @override
  Future<List<StoreProduct>> getProducts(List<String> productIds) async => [];

  @override
  Future<PurchaseStatus> purchase(StoreProduct product) async =>
      PurchaseStatus.cancelled;

  @override
  Future<void> restorePurchases() async {}

  @override
  Stream<PurchaseStatus> get purchaseUpdates => const Stream.empty();

  @override
  void dispose() {}
}
