import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';

/// A store that says the course is already owned — **development only**.
///
/// Nothing in the app can take money yet: `NoOpPaymentsService` reports no
/// entitlement and cancels every purchase. With the course wall enforced at
/// the router, that leaves every lesson past the free three unreachable, and
/// no way through — so there would be no way to open, review or test the paid
/// course until the real store lands (#421).
///
/// This is that way through, and it is compiled in rather than switched on at
/// run time: `--dart-define=GRANT_COURSE=true` selects it, and a release build
/// that does not pass it cannot reach this class at all.
///
/// It grants the entitlement and nothing else. Purchase and restore report
/// success without touching a store, because the point is to stand where a
/// paying learner stands, not to simulate paying.
class GrantedPaymentsService implements PaymentsService {
  /// Creates a [GrantedPaymentsService].
  const GrantedPaymentsService();

  @override
  Future<bool> hasActiveEntitlement() async => true;

  @override
  Future<List<StoreProduct>> getProducts(List<String> productIds) async => [];

  @override
  Future<PurchaseStatus> purchase(StoreProduct product) async =>
      PurchaseStatus.purchased;

  @override
  Future<void> restorePurchases() async {}

  @override
  Stream<PurchaseStatus> get purchaseUpdates => const Stream.empty();

  @override
  void dispose() {}
}
