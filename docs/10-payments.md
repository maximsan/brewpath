# Coffee Quest — Payments

## Policy

There is **no real paywall or purchase flow in MVP**. The payments layer exists only as a placeholder so monetization can be added later without architectural changes.

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
import 'dart:async';
import 'payments_service.dart';
import 'store_product.dart';

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
// 4. Call InAppPurchase.instance.buyNonConsumable() or buyConsumable()
// 5. Deliver entitlement after PurchaseStatus.purchased + verifyPurchase()
// 6. For subscriptions: verify receipt server-side (not in MVP)
//
// See: https://pub.dev/packages/in_app_purchase

import 'payments_service.dart';
import 'store_product.dart';

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
import 'payments_service.dart';
import 'noop_payments_service.dart';

part 'payments_provider.g.dart';

@riverpod
PaymentsService paymentsService(Ref ref) => NoOpPaymentsService();
// Swap to InAppPurchaseService() when payments go live
```

---

## Product IDs Convention

| Product Type | ID Convention | Example |
|---|---|---|
| Lifetime unlock | `com.yourcompany.coffeequest.lifetime` | One-time purchase, no subscription |
| Monthly subscription | `com.yourcompany.coffeequest.monthly` | Future option |
| Annual subscription | `com.yourcompany.coffeequest.annual` | Future option |

Define these IDs in `lib/core/constants/product_ids.dart` when implementing.

---

## Future Implementation Checklist

When payments are ready to go live:

- [ ] Register products in App Store Connect → In-App Purchases
- [ ] Enable In-App Purchase capability in Xcode → Runner target → Signing & Capabilities
- [ ] Replace `NoOpPaymentsService` with `InAppPurchaseService` in `payments_provider.dart`
- [ ] Implement `InAppPurchaseService` with StoreKit 2 integration via `in_app_purchase` package
- [ ] Implement receipt validation (at minimum client-side; server-side for subscriptions)
- [ ] Add entitlement check at app startup — gate premium content if `hasActiveEntitlement()` returns false
- [ ] Build paywall screen at `lib/features/paywall/presentation/paywall_screen.dart`
- [ ] Add a Restore Purchases button to Profile tab
- [ ] Test in sandbox environment with a sandbox Apple ID
- [ ] Handle edge cases: purchase interrupted, StoreKit unavailable, already purchased

**If subscription receipt validation becomes complex:** Consider `purchases_flutter` (RevenueCat SDK) as an alternative to manual receipt validation. Only introduce it if `in_app_purchase` proves insufficient.

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

## Steps

- [ ] Create `lib/services/payments/payments_service.dart`
- [ ] Create `lib/services/payments/store_product.dart`
- [ ] Create `lib/services/payments/noop_payments_service.dart`
- [ ] Create `lib/services/payments/in_app_purchase_service.dart`
- [ ] Create `lib/services/payments/payments_provider.dart`
- [ ] Run `build_runner` to generate provider file
- [ ] Verify `NoOpPaymentsService` is active in `payments_provider.dart`
- [ ] Confirm no feature code calls `in_app_purchase` directly

---

## Definition of Done

- [ ] `PaymentsService` abstract interface exists
- [ ] `NoOpPaymentsService` is the active provider in MVP
- [ ] `InAppPurchaseService` stub exists with `UnimplementedError` guards
- [ ] `payments_provider.dart` compiles and resolves to `NoOpPaymentsService`
- [ ] No feature screen shows a real purchase button or price in MVP
- [ ] Future implementation checklist is complete and stored in this doc
