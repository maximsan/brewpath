import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/selling_payments_service.dart';

void main() {
  late SellingPaymentsService store;
  late ProviderContainer container;

  setUp(() {
    store = SellingPaymentsService();
    container = ProviderContainer(
      overrides: [paymentsServiceProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
  });

  Future<void> buy() async {
    await store.purchase((await store.getProducts(const ['any'])).first);
    container.invalidate(courseEntitlementProvider);
  }

  test('a lapse locks the course without a restart', () async {
    // The one thing a subscription arm needs that a one-time purchase never
    // did: the answer going false while the app is open (ADR-0024).
    container.listen(courseEntitlementProvider, (_, _) {});
    await buy();
    expect(await container.read(courseEntitlementProvider.future), isTrue);

    store.lapse();
    await Future<void>.delayed(Duration.zero);

    expect(await container.read(courseEntitlementProvider.future), isFalse);
  });

  test('a store that reports nothing leaves the answer standing', () async {
    container.listen(courseEntitlementProvider, (_, _) {});
    await buy();
    expect(await container.read(courseEntitlementProvider.future), isTrue);

    await Future<void>.delayed(Duration.zero);

    expect(await container.read(courseEntitlementProvider.future), isTrue);
  });
}
