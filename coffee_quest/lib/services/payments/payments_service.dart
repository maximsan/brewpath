import 'package:coffee_quest/services/payments/store_product.dart';

enum PurchaseStatus { purchased, pending, restored, cancelled, error }

/// Abstract store layer. No feature code calls StoreKit / `in_app_purchase`
/// directly — only this interface. NoOp is active in the MVP.
abstract class PaymentsService {
  /// True if the user currently has an active entitlement.
  Future<bool> hasActiveEntitlement();

  /// Available products from the store.
  Future<List<StoreProduct>> getProducts(List<String> productIds);

  /// Initiates a purchase for the given product.
  Future<PurchaseStatus> purchase(StoreProduct product);

  /// Restores previous purchases.
  Future<void> restorePurchases();

  /// Stream of purchase status updates.
  Stream<PurchaseStatus> get purchaseUpdates;

  /// Dispose listeners when done.
  void dispose();
}
