/// The paywall as data: config words joined to the store's own prices.
///
/// Pure, so what a model renders is checked in a unit test rather than by
/// pumping a screen. Every string here came from the config or the store —
/// nothing is written down at a call site.
library;

import 'dart:math' as math;

import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';

/// Rounded percentages, so `Save 50%` never reads `Save 50.4%`.
const int _percent = 100;

/// A saving worth naming. Below this the badge is noise.
const int _worthNaming = 5;

/// Months in a year, for comparing a yearly plan against a monthly one.
const int _monthsPerYear = 12;

/// One plan row, ready to draw.
class PaywallPlanView {
  /// Creates a [PaywallPlanView].
  const PaywallPlanView({
    required this.term,
    required this.productId,
    required this.name,
    required this.line,
    required this.price,
    required this.per,
    required this.badge,
  });

  /// Which term this row sells.
  final PlusTerm term;

  /// The SKU tapping it buys.
  final String productId;

  /// The row's name.
  final String name;

  /// The row's fact line.
  final String line;

  /// The store's formatted price, or null when the store has not answered.
  final String? price;

  /// What follows the price, or null when nothing renews.
  final String? per;

  /// A worked-out saving against the monthly plan, or null when there is none.
  final String? badge;

  /// Whether this row can be bought — a row with no price cannot.
  bool get isBuyable => price != null;
}

/// A whole paywall, ready to draw.
class PaywallView {
  /// Creates a [PaywallView].
  const PaywallView({
    required this.model,
    required this.eyebrow,
    required this.heroTitle,
    required this.note,
    required this.plans,
    required this.defaultTerm,
    required this.fromPerMonth,
  });

  /// Which arm this is, for a surface that needs the config's other slots.
  final MonetizationModel model;

  /// The kicker over the hero.
  final String eyebrow;

  /// The hero's promise.
  final String heroTitle;

  /// The reassurance under the action.
  final String note;

  /// The rows, in the order the arm names them.
  final List<PaywallPlanView> plans;

  /// The row selected before the learner touches anything.
  final PlusTerm defaultTerm;

  /// The cheapest month this arm can be had for — `$2` off a `$23.99` year —
  /// or null when no renewing plan is priced.
  final String? fromPerMonth;

  /// Whether the learner is being asked to choose, rather than just to buy.
  bool get offersAChoice => plans.length > 1;

  /// Nothing can be bought until the store has priced at least one row.
  bool get canBuy => plans.any((plan) => plan.isBuyable);

  /// The row for [term], or the default when it names none.
  PaywallPlanView planFor(PlusTerm? term) => plans.firstWhere(
    (plan) => plan.term == (term ?? defaultTerm),
    orElse: () => plans.first,
  );
}

/// Substitutes the store's figures into a line of config copy.
///
/// A line whose figure is missing loses the whole clause rather than showing
/// a placeholder, because `Unlock Foundations — {price}` on a real screen is
/// worse than `Unlock Foundations`.
String withPrice(String template, String? price, {String? perMonth}) {
  var line = template;
  if (price != null) line = line.replaceAll(pricePlaceholder, price);
  if (perMonth != null) line = line.replaceAll(perMonthPlaceholder, perMonth);

  final unfilled = [
    pricePlaceholder,
    perMonthPlaceholder,
  ].map(line.indexOf).where((index) => index >= 0);
  if (unfilled.isEmpty) return line;

  return line
      .substring(0, unfilled.reduce(math.min))
      .trimRight()
      .replaceAll(RegExp(r'\s*[—·-](\s*from)?$'), '')
      .trimRight();
}

/// [amount] written the way the store wrote [price]: the currency mark kept
/// on the side the store put it, in whole units — `$23.99` and 1.999 give
/// `$2`.
String formatLikePrice(String price, double amount) {
  final figure = RegExp(r'[\d.,]+').firstMatch(price);
  if (figure == null) return '${amount.round()}';

  return '${price.substring(0, figure.start)}'
      '${amount.round()}'
      '${price.substring(figure.end)}';
}

/// Builds the paywall for [offering], priced by whatever [products] carries.
///
/// A product the store did not return leaves its row unpriced rather than
/// dropping it: the learner still sees what the arm sells.
PaywallView buildPaywallView({
  required PlusOffering offering,
  required List<StoreProduct> products,
}) {
  final config = paywallModels[offering.model]!;
  final priced = {for (final product in products) product.id: product};
  final monthly = _monthlyAmountIn(offering, priced);

  return PaywallView(
    model: offering.model,
    eyebrow: config.eyebrow,
    heroTitle: config.heroTitle,
    note: config.paywallNote,
    defaultTerm: offering.defaultOffer.term,
    fromPerMonth: _cheapestMonth(offering, priced),
    plans: [
      for (final offer in offering.offers)
        _planView(offer, priced[offer.productId], monthly),
    ],
  );
}

PaywallPlanView _planView(
  PlusOffer offer,
  StoreProduct? product,
  double? monthlyAmount,
) {
  final plan = paywallPlans[offer.term]!;
  final perMonth = _perMonthOf(offer.term, product);

  return PaywallPlanView(
    term: offer.term,
    productId: offer.productId,
    name: plan.name,
    line: plan.perMonthLine != null && perMonth != null
        ? withPrice(plan.perMonthLine!, null, perMonth: perMonth.formatted)
        : plan.line,
    price: product?.price,
    per: plan.per,
    badge: _savingsBadge(offer.term, product?.amount, monthlyAmount),
  );
}

/// What a month costs on a renewing plan, as a number and as the store would
/// write it.
typedef _PerMonth = ({double amount, String formatted});

_PerMonth? _perMonthOf(PlusTerm term, StoreProduct? product) {
  if (product == null) return null;
  final amount = switch (term) {
    PlusTerm.monthly => product.amount,
    PlusTerm.yearly => product.amount / _monthsPerYear,
    PlusTerm.lifetime => null,
  };
  if (amount == null) return null;

  return (amount: amount, formatted: formatLikePrice(product.price, amount));
}

String? _cheapestMonth(
  PlusOffering offering,
  Map<String, StoreProduct> priced,
) {
  _PerMonth? cheapest;
  for (final offer in offering.offers) {
    final perMonth = _perMonthOf(offer.term, priced[offer.productId]);
    if (perMonth == null) continue;
    if (cheapest == null || perMonth.amount < cheapest.amount) {
      cheapest = perMonth;
    }
  }

  return cheapest?.formatted;
}

/// What a yearly plan saves against paying monthly for a year.
String? _savingsBadge(PlusTerm term, double? amount, double? monthlyAmount) {
  if (term != PlusTerm.yearly || amount == null || monthlyAmount == null) {
    return null;
  }
  final fullYear = monthlyAmount * _monthsPerYear;
  if (fullYear <= 0) return null;

  final saved = ((1 - amount / fullYear) * _percent).round();

  return saved >= _worthNaming ? 'Save $saved%' : null;
}

double? _monthlyAmountIn(
  PlusOffering offering,
  Map<String, StoreProduct> priced,
) {
  for (final offer in offering.offers) {
    if (offer.term == PlusTerm.monthly) return priced[offer.productId]?.amount;
  }

  return null;
}
