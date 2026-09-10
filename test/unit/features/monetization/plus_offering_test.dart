import 'package:brew_path/services/payments/noop_payments_service.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the shipping build is on the one-time arm', () async {
    // ADR-0003: v1 sells a single non-consumable. The no-op is what ships, so
    // this is the arm a learner is actually on today.
    final offering = await const NoOpPaymentsService().currentOffering();

    expect(offering.model, MonetizationModel.oneTime);
    expect(offering.defaultOffer.productId, plusLifetimeProductId);
    expect(offering.defaultOffer.term, PlusTerm.lifetime);
  });

  test('the arm a learner is on does not change under them', () async {
    const store = NoOpPaymentsService();

    final first = await store.currentOffering();
    final second = await store.currentOffering();

    expect(first.model, second.model);
    expect(
      first.offers.map((offer) => offer.productId),
      second.offers.map((offer) => offer.productId),
    );
  });

  test('the one-time arm offers exactly one thing', () {
    // The gate sheet draws one action and calls `buy()` with no offer, which
    // takes the default. That is honest only while there is nothing to choose
    // between — an arm with plans needs a paywall that lets one be picked.
    expect(offeringFor(MonetizationModel.oneTime).offers, hasLength(1));
  });

  test('an arm with no registered SKU refuses rather than guessing', () {
    // The alternative is inventing product ids App Store Connect has never
    // seen, then shipping a paywall that offers them.
    for (final model in [
      MonetizationModel.subscription,
      MonetizationModel.hybrid,
    ]) {
      expect(
        () => offeringFor(model),
        throwsUnimplementedError,
        reason: '${model.name} has no SKUs, so it cannot be offered',
      );
    }
  });
}
