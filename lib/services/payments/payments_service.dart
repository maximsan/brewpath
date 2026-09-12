import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';

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

/// Abstract store layer. No feature code calls a store SDK directly — only
/// this interface. NoOp is active until a build carries a RevenueCat key.
abstract class PaymentsService {
  /// True if the user currently has an active entitlement.
  ///
  /// One answer for every arm, whatever bought it (#176).
  Future<bool> hasActiveEntitlement();

  /// Which arm this learner is on, and what it sells them.
  ///
  /// The store assigns it, and must return the same arm to a returning
  /// learner (#176).
  Future<PlusOffering> currentOffering();

  /// Available products from the store.
  Future<List<StoreProduct>> getProducts(List<String> productIds);

  /// Initiates a purchase for the given product.
  Future<PurchaseStatus> purchase(StoreProduct product);

  /// Restores previous purchases.
  Future<void> restorePurchases();

  /// Emits the new answer whenever [hasActiveEntitlement] changes underneath
  /// the app — a renewal, a lapse, a refund, a purchase on another device.
  ///
  /// A subscription stops being owned while the app is open, and nothing else
  /// would notice (ADR-0024).
  Stream<bool> get entitlementChanges;

  /// Dispose listeners when done.
  void dispose();
}
