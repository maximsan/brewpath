# BrewPath — Payments

## Policy

There is **no real purchase flow in MVP** — the payments layer is a placeholder so monetization can be added later without architectural changes. (The *product* model is decided — a content-gated **BrewPath Plus** tier sold as a single one-time purchase, `docs/decisions.md` §7/§11, [ADR-0003](adr/0003-one-time-purchase-no-trial.md) — this doc covers only the deferred StoreKit implementation.)

The abstraction is established now so that:

- The codebase has a clear home for payment logic
- No feature code ever calls StoreKit directly
- The paywall UI can be dropped into the existing slot when ready

---

## PaymentsService Interface

```dart
// lib/services/payments/payments_service.dart

enum PurchaseStatus { purchased, pending, restored, cancelled, error }

abstract class PaymentsService {
  /// Returns true if the user currently has an active entitlement.
  Future<bool> hasActiveEntitlement();

  /// Returns available products from the store.
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
```

---

## StoreProduct Model

```dart
// lib/services/payments/store_product.dart
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
  });

  final String id;
  final String title;
  final String description;
  final String price;           // formatted string, e.g., "$2.99"
  final String currencyCode;    // e.g., "USD"
}
```

---

## No-Op Implementation (MVP Active)

```dart
// lib/services/payments/noop_payments_service.dart

import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';

class NoOpPaymentsService implements PaymentsService {
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
```

---

## in_app_purchase Implementation Stub

```dart
// lib/services/payments/in_app_purchase_service.dart
// TODO: Implement using the in_app_purchase package when payments go live.
//
// Key implementation steps (for future reference):
// 1. Call InAppPurchase.instance.isAvailable() on init
// 2. Listen to InAppPurchase.instance.purchaseStream
// 3. Call InAppPurchase.instance.queryProductDetails(productIds)
// 4. Call InAppPurchase.instance.buyNonConsumable()
// 5. Deliver entitlement after PurchaseStatus.purchased + verifyPurchase()
//
// See: https://pub.dev/packages/in_app_purchase

import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';

class InAppPurchaseService implements PaymentsService {
  @override
  Future<bool> hasActiveEntitlement() {
    throw UnimplementedError('Implement when payments go live');
  }

  @override
  Future<List<StoreProduct>> getProducts(List<String> productIds) {
    throw UnimplementedError();
  }

  @override
  Future<PurchaseStatus> purchase(StoreProduct product) {
    throw UnimplementedError();
  }

  @override
  Future<void> restorePurchases() {
    throw UnimplementedError();
  }

  @override
  Stream<PurchaseStatus> get purchaseUpdates => throw UnimplementedError();

  @override
  void dispose() {}
}
```

---

## Riverpod Provider

```dart
// lib/services/payments/payments_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/noop_payments_service.dart';

part 'payments_provider.g.dart';

@riverpod
PaymentsService paymentsService(Ref ref) => NoOpPaymentsService();
// Swap to InAppPurchaseService() when payments go live
```

---

## Product IDs Convention

| Product Type                | ID Convention                |
| --------------------------- | ---------------------------- |
| One-time purchase (Plus)    | `dev.maximsan.brewPath.plus` |

v1 sells a **single non-consumable** unlocking Plus — no trial, no
subscription SKUs
([ADR-0003](adr/0003-one-time-purchase-no-trial.md)). This is the *baseline*
of a planned post-launch experiment (one-time vs subscription vs hybrid), so
entitlement, acquisition and paywall UI stay separated
([#176](https://github.com/maximsan/brewpath/issues/176)) and the SKU list is
config, not code.

Define the ID in `lib/core/constants/product_ids.dart` when implementing.

---

## Future Implementation Checklist

When payments are ready to go live:

- [ ] Register products in App Store Connect → In-App Purchases
- [ ] Enable In-App Purchase capability in Xcode → Runner target → Signing & Capabilities
- [ ] Replace `NoOpPaymentsService` with `InAppPurchaseService` in `payments_provider.dart`
- [ ] Implement `InAppPurchaseService` with StoreKit 2 integration via `in_app_purchase` package — `buyNonConsumable` only
- [ ] Implement client-side receipt validation (server-side only if the monetization experiment brings subscriptions back)
- [ ] Add entitlement check at app startup — gate Plus content if `hasActiveEntitlement()` returns false
- [ ] Build paywall screen at `lib/features/paywall/presentation/paywall_screen.dart`
- [ ] Add a Restore Purchases button to Profile tab
- [ ] Test in sandbox environment with a sandbox Apple ID
- [ ] Handle edge cases: purchase interrupted, StoreKit unavailable, already purchased

**RevenueCat** (`purchases_flutter`) is the likely vehicle for the post-launch
monetization experiment ([#176](https://github.com/maximsan/brewpath/issues/176)
— model switching, paywall metrics). Don't introduce it for v1's single
non-consumable; the decision belongs to the experiment.

---

## Folder Structure

```
lib/services/payments/
├── payments_service.dart           # Abstract interface
├── store_product.dart              # Product model
├── noop_payments_service.dart      # MVP active implementation (no-op)
├── in_app_purchase_service.dart    # Future implementation stub
└── payments_provider.dart          # Riverpod provider
```

---

## Status

All scaffolding above exists in `lib/services/payments/` with
`NoOpPaymentsService` active. Remaining work is the Future Implementation
Checklist, done when real StoreKit integration lands.
