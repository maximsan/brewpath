import 'package:brew_path/services/payments/noop_payments_service.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the shipping build is on the one-time arm', () async {
    // The baseline arm (ADR-0024), and what a build with no RevenueCat key
    // falls back to — so this is the arm a learner is on today.
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

  test('the two experiment arms sell renewing plans and preselect yearly', () {
    final subscription = offeringFor(MonetizationModel.subscription);
    final hybrid = offeringFor(MonetizationModel.hybrid);

    expect(
      subscription.offers.map((offer) => offer.term),
      [PlusTerm.monthly, PlusTerm.yearly],
    );
    expect(
      hybrid.offers.map((offer) => offer.term),
      [PlusTerm.monthly, PlusTerm.yearly, PlusTerm.lifetime],
    );
    expect(subscription.defaultOffer.term, PlusTerm.yearly);
    expect(hybrid.defaultOffer.term, PlusTerm.yearly);
  });

  test('a development build can ask its store for another arm', () async {
    // Only a `--dart-define` reaches this; a store built without one is on
    // the baseline, which is what the test above proves.
    expect(monetizationModelNamed('hybrid'), MonetizationModel.hybrid);
    expect(monetizationModelNamed(''), MonetizationModel.oneTime);
    expect(monetizationModelNamed('nonsense'), MonetizationModel.oneTime);

    const store = NoOpPaymentsService(model: MonetizationModel.subscription);
    expect(
      (await store.currentOffering()).model,
      MonetizationModel.subscription,
    );
  });
}
