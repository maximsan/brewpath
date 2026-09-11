import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/plus_offering_provider.dart';
import 'package:brew_path/features/monetization/domain/purchased_term.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_purchase_controller.g.dart';

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

  /// Restore ran and found nothing on this account. Not a failure — nobody
  /// was charged and nothing broke — but it must be said, or the link reads
  /// as dead.
  nothingToRestore,

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

  /// Buys [offer], or the arm's default when the paywall names none.
  Future<void> buy({PlusOffer? offer}) async {
    if (state == PlusPurchaseState.working) return;
    state = PlusPurchaseState.working;

    final payments = ref.read(paymentsServiceProvider);
    try {
      final wanted =
          offer ?? (await ref.read(plusOfferingProvider.future)).defaultOffer;
      // The product is fetched rather than fabricated: a store that does not
      // offer it — the no-op, or a misconfigured build — must fail here rather
      // than send a made-up product into a purchase call.
      final products = await payments.getProducts([wanted.productId]);
      final product = _productWithId(products, wanted.productId);
      if (product == null) {
        state = PlusPurchaseState.failed;
        return;
      }
      final status = await payments.purchase(product);
      // Recorded before the state flips, so the welcome that opens on
      // `owned` already knows which plan to celebrate.
      if (status == PurchaseStatus.purchased) {
        ref.read(purchasedTermProvider.notifier).term = wanted.term;
      }
      await _settle(status);
    } on Object {
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
          : PlusPurchaseState.nothingToRestore;
    } on Object {
      state = PlusPurchaseState.failed;
    }
  }

  StoreProduct? _productWithId(
    List<StoreProduct> products,
    String productId,
  ) {
    for (final product in products) {
      if (product.id == productId) return product;
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
