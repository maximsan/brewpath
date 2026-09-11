import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';

/// A store that says the course is already owned — **development only**.
///
/// The only way to stand where a paying learner stands until the real store
/// lands (#421). Compiled in rather than switched on at run time:
/// `--dart-define=GRANT_COURSE=true` selects it, so a release build without
/// that flag cannot reach this class at all.
class GrantedPaymentsService implements PaymentsService {
  /// Creates a [GrantedPaymentsService] whose store reports [model].
  const GrantedPaymentsService({this.model = MonetizationModel.oneTime});

  /// The arm this store puts every learner on.
  final MonetizationModel model;

  @override
  Future<bool> hasActiveEntitlement() async => true;

  @override
  Future<PlusOffering> currentOffering() async => offeringFor(model);

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
