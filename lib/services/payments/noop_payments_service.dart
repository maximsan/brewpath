import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';

/// Active payments implementation for the MVP — no store, no entitlements.
class NoOpPaymentsService implements PaymentsService {
  /// Creates a [NoOpPaymentsService] whose store reports [model].
  const NoOpPaymentsService({this.model = MonetizationModel.oneTime});

  /// The arm this store puts every learner on — the baseline unless a
  /// development build asked for another.
  final MonetizationModel model;

  @override
  Future<bool> hasActiveEntitlement() async => false;

  @override
  Future<PlusOffering> currentOffering() async => offeringFor(model);

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
