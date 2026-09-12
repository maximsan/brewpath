import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:brew_path/features/monetization/domain/purchase_exit.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/selling_payments_service.dart';

// Which door an arriving entitlement leaves by, driven through the real
// controller rather than by handing the exit its own answer.
void main() {
  late List<String> taken;

  setUp(() => taken = []);

  PurchaseExit exitRecording() => PurchaseExit(
    onPurchased: () => taken.add('purchased'),
    onRestored: () => taken.add('restored'),
  );

  PlusPurchase controllerOn(ProviderContainer container) =>
      container.read(plusPurchaseProvider.notifier);

  ProviderContainer storeThat({required bool restorable}) {
    final container = ProviderContainer(
      overrides: [
        paymentsServiceProvider.overrideWith(
          (ref) => SellingPaymentsService(restorable: restorable),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('a buy leaves by the sale door', () async {
    final container = storeThat(restorable: false);
    final exit = exitRecording();
    container.listen(plusPurchaseProvider, (_, next) => exit.settle(next));

    await controllerOn(container).buy();

    expect(taken, ['purchased']);
  });

  test(
    'a restore that recovers a purchase leaves by the recovery door',
    () async {
      final container = storeThat(restorable: true);
      final exit = exitRecording();
      container.listen(plusPurchaseProvider, (_, next) => exit.settle(next));

      await exit.restore(controllerOn(container));

      expect(taken, ['restored']);
    },
  );

  test('a restore that recovers nothing takes no exit', () async {
    final container = storeThat(restorable: false);
    final exit = exitRecording();
    container.listen(plusPurchaseProvider, (_, next) => exit.settle(next));

    await exit.restore(controllerOn(container));

    expect(
      container.read(plusPurchaseProvider),
      PlusPurchaseState.nothingToRestore,
    );
    expect(taken, isEmpty);
  });

  test(
    'a sale after a restore that recovered nothing is still a sale',
    () async {
      final container = storeThat(restorable: false);
      final exit = exitRecording();
      container.listen(plusPurchaseProvider, (_, next) => exit.settle(next));

      await exit.restore(controllerOn(container));
      await controllerOn(container).buy();

      expect(taken, ['purchased']);
    },
  );

  test('the exit is taken once, however often owned is reported', () async {
    final container = storeThat(restorable: true);
    final exit = exitRecording();

    exit.settle(PlusPurchaseState.owned);
    exit.settle(PlusPurchaseState.owned);
    await exit.restore(controllerOn(container));

    expect(taken, ['purchased']);
  });
}
