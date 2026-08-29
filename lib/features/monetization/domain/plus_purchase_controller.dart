import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_purchase_controller.g.dart';

/// The store id for Plus — the one non-consumable v1 sells.
///
/// A single id rather than a plan list: ADR-0003 rules v1 a one-time purchase,
/// with no subscription and no trial, so there is nothing to choose between.
const String plusProductId = 'dev.maximsan.brewPath.plus';

/// Where the sheet's one action currently stands.
enum PlusPurchaseState {
  /// Nothing attempted yet.
  idle,

  /// The store call is in flight — the action shows it is working, so a slow
  /// call does not read as a dead button.
  working,

  /// Bought, or recovered by Restore. Entitlement has been re-read.
  owned,

  /// Awaiting someone else's approval. **Not success**: the app must not show
  /// content the learner does not own yet.
  pending,

  /// The learner backed out. A normal thing to do, and not an error.
  cancelled,

  /// The store refused or failed.
  failed,
}

/// Drives the sheet's one action, and nothing else.
///
/// Holds no rule about what Plus contains and never reads a store SDK — it
/// calls [PaymentsService] and re-reads [courseEntitlementProvider] when the
/// answer may have changed, which is what makes the surfaces behind the sheet
/// update without knowing a purchase happened.
@riverpod
class PlusPurchase extends _$PlusPurchase {
  @override
  PlusPurchaseState build() => PlusPurchaseState.idle;

  /// Buys Plus, and reports what the store said.
  Future<void> buy() async {
    if (state == PlusPurchaseState.working) return;
    state = PlusPurchaseState.working;

    final payments = ref.read(paymentsServiceProvider);
    try {
      // The product is fetched rather than fabricated: a store that does not
      // offer it — the no-op, or a misconfigured build — must fail here rather
      // than send a made-up product into a purchase call.
      final products = await payments.getProducts([plusProductId]);
      final product = _plusAmong(products);
      if (product == null) {
        state = PlusPurchaseState.failed;
        return;
      }
      await _settle(await payments.purchase(product));
    } on Exception {
      state = PlusPurchaseState.failed;
    }
  }

  /// Recovers a purchase made on another device.
  ///
  /// The store reports nothing directly, so entitlement is re-read and it is
  /// the answer that decides: paying once means paying once, and a restore
  /// that recovers nothing is not a failure.
  Future<void> restore() async {
    if (state == PlusPurchaseState.working) return;
    state = PlusPurchaseState.working;

    try {
      await ref.read(paymentsServiceProvider).restorePurchases();
      state = await _reReadEntitlement()
          ? PlusPurchaseState.owned
          : PlusPurchaseState.idle;
    } on Exception {
      state = PlusPurchaseState.failed;
    }
  }

  StoreProduct? _plusAmong(List<StoreProduct> products) {
    for (final product in products) {
      if (product.id == plusProductId) return product;
    }
    return null;
  }

  /// Maps what the store said onto what the sheet shows.
  Future<void> _settle(PurchaseStatus status) async {
    switch (status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _reReadEntitlement();
        state = PlusPurchaseState.owned;
      case PurchaseStatus.pending:
        state = PlusPurchaseState.pending;
      case PurchaseStatus.cancelled:
        state = PlusPurchaseState.cancelled;
      case PurchaseStatus.error:
        state = PlusPurchaseState.failed;
    }
  }

  /// Invalidates the entitlement and waits for its new answer, so a caller
  /// that flips to `owned` is not racing the gates behind the sheet.
  Future<bool> _reReadEntitlement() {
    ref.invalidate(courseEntitlementProvider);
    return ref.read(courseEntitlementProvider.future);
  }
}
