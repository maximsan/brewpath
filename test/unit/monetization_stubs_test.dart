import 'package:brew_path/services/ads/ads_provider.dart';
import 'package:brew_path/services/ads/ads_service.dart';
import 'package:brew_path/services/ads/noop_ads_service.dart';
import 'package:brew_path/services/payments/noop_payments_service.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('payments & ads providers resolve to the No-Op implementations', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(paymentsServiceProvider), isA<NoOpPaymentsService>());
    expect(c.read(adsServiceProvider), isA<NoOpAdsService>());
  });

  test('NoOpPaymentsService grants nothing', () async {
    const p = NoOpPaymentsService();
    expect(await p.hasActiveEntitlement(), isFalse);
    expect(await p.getProducts(const ['x']), isEmpty);
    expect(
      await p.purchase(
        const StoreProduct(
          id: 'x',
          title: 't',
          description: 'd',
          price: r'$1',
          currencyCode: 'USD',
        ),
      ),
      PurchaseStatus.cancelled,
    );
    await p.restorePurchases();
    expect(p.purchaseUpdates, emitsDone);
  });

  test('NoOpAdsService never serves an ad', () async {
    const a = NoOpAdsService();
    await a.initialize();
    expect(await a.loadInterstitial('id'), AdLoadStatus.notAvailable);
    expect(await a.loadRewarded('id'), AdLoadStatus.notAvailable);
    expect(await a.showRewarded(), isFalse);
  });
}
