import 'package:coffee_quest/services/payments/store_product.dart';

/// Outcome of a purchase or restore flow.
enum PurchaseStatus {
  /// The purchase completed and the entitlement is active.
  purchased,

  /// The purchase is awaiting external action (e.g. parental approval).
  pending,

  /// A prior purchase was restored.
  restored,

  /// The user cancelled the flow.
  cancelled,

  /// The purchase failed.
  error,
}

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
