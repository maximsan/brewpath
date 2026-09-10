import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:flutter_test/flutter_test.dart';

StoreProduct _product(String id, String price, double amount) => StoreProduct(
  id: id,
  title: 'BrewPath Plus',
  description: 'The full course',
  price: price,
  amount: amount,
  currencyCode: 'USD',
);

const _oneTime = PlusOffering(
  model: MonetizationModel.oneTime,
  offers: [PlusOffer(productId: 'lifetime.sku', term: PlusTerm.lifetime)],
);

const _hybrid = PlusOffering(
  model: MonetizationModel.hybrid,
  offers: [
    PlusOffer(productId: 'yearly.sku', term: PlusTerm.yearly),
    PlusOffer(productId: 'monthly.sku', term: PlusTerm.monthly),
    PlusOffer(productId: 'lifetime.sku', term: PlusTerm.lifetime),
  ],
);

void main() {
  group('what an arm renders', () {
    test('the one-time arm asks for nothing to be chosen', () {
      final view = buildPaywallView(
        offering: _oneTime,
        products: [_product('lifetime.sku', r'$49.99', 49.99)],
      );

      expect(view.offersAChoice, isFalse);
      expect(view.plans.single.name, 'Lifetime');
      expect(
        view.heroTitle,
        paywallModels[MonetizationModel.oneTime]!.heroTitle,
      );
    });

    test('the hybrid arm draws every plan it sells, in order', () {
      final view = buildPaywallView(
        offering: _hybrid,
        products: [
          _product('yearly.sku', r'$23.99', 23.99),
          _product('monthly.sku', r'$3.99', 3.99),
          _product('lifetime.sku', r'$49.99', 49.99),
        ],
      );

      expect(view.offersAChoice, isTrue);
      expect(
        view.plans.map((plan) => plan.term),
        [PlusTerm.yearly, PlusTerm.monthly, PlusTerm.lifetime],
      );
      expect(view.defaultTerm, PlusTerm.yearly);
    });

    test('switching the arm changes every word on the screen', () {
      // The whole point of the config: one table drives the copy, so two arms
      // cannot accidentally share a hero.
      final one = buildPaywallView(offering: _oneTime, products: const []);
      final many = buildPaywallView(offering: _hybrid, products: const []);

      expect(one.heroTitle, isNot(many.heroTitle));
      expect(one.eyebrow, isNot(many.eyebrow));
      expect(one.note, isNot(many.note));
    });
  });

  group('the price comes from the store', () {
    test('a priced row shows what the store said, not a written price', () {
      final view = buildPaywallView(
        offering: _oneTime,
        products: [_product('lifetime.sku', '£44.99', 44.99)],
      );

      expect(view.plans.single.price, '£44.99');
    });

    test('a row the store did not price cannot be bought', () {
      final view = buildPaywallView(offering: _oneTime, products: const []);

      expect(view.plans.single.price, isNull);
      expect(view.plans.single.isBuyable, isFalse);
      expect(view.canBuy, isFalse);
    });

    test('an unpriced action drops the clause rather than showing a token', () {
      final cta = paywallPlans[PlusTerm.lifetime]!.cta;

      expect(withPrice(cta, r'$49.99'), r'Unlock Foundations — $49.99');
      expect(withPrice(cta, null), 'Unlock Foundations');
      expect(withPrice(cta, null), isNot(contains(pricePlaceholder)));
    });
  });

  group('the savings badge is worked out, never written', () {
    test('yearly is badged against twelve months of monthly', () {
      final view = buildPaywallView(
        offering: _hybrid,
        products: [
          _product('yearly.sku', r'$23.99', 23.99),
          _product('monthly.sku', r'$3.99', 3.99),
          _product('lifetime.sku', r'$49.99', 49.99),
        ],
      );
      final yearly = view.planFor(PlusTerm.yearly);

      // 23.99 against 47.88 — a real half off, and the design's own claim.
      expect(yearly.badge, 'Save 50%');
    });

    test('a storefront where yearly saves nothing shows no badge', () {
      // Regional pricing is not a fixed ratio, so a badge copied from the
      // design would lie wherever the two prices land differently.
      final view = buildPaywallView(
        offering: _hybrid,
        products: [
          _product('yearly.sku', r'$47.99', 47.99),
          _product('monthly.sku', r'$3.99', 3.99),
          _product('lifetime.sku', r'$49.99', 49.99),
        ],
      );

      expect(view.planFor(PlusTerm.yearly).badge, isNull);
    });

    test('nothing but a yearly plan is ever badged', () {
      final view = buildPaywallView(
        offering: _hybrid,
        products: [
          _product('yearly.sku', r'$23.99', 23.99),
          _product('monthly.sku', r'$3.99', 3.99),
          _product('lifetime.sku', r'$49.99', 49.99),
        ],
      );

      expect(view.planFor(PlusTerm.monthly).badge, isNull);
      expect(view.planFor(PlusTerm.lifetime).badge, isNull);
    });

    test('an arm with no monthly plan cannot claim a saving', () {
      final view = buildPaywallView(
        offering: const PlusOffering(
          model: MonetizationModel.subscription,
          offers: [PlusOffer(productId: 'yearly.sku', term: PlusTerm.yearly)],
        ),
        products: [_product('yearly.sku', r'$23.99', 23.99)],
      );

      expect(view.plans.single.badge, isNull);
    });
  });

  test('every plan the config knows has a term of its own', () {
    // A copy-pasted entry that kept the wrong term would draw one plan's
    // words on another plan's row.
    for (final entry in paywallPlans.entries) {
      expect(entry.value.term, entry.key);
    }
  });

  test('every arm the store can name has copy to render', () {
    for (final model in MonetizationModel.values) {
      expect(paywallModels[model], isNotNull, reason: model.name);
    }
  });
}
