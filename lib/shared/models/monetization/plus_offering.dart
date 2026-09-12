/// What the store puts in front of one learner: which model, and which SKUs.
library;

/// One arm of the pricing experiment (ADR-0024, #176).
enum MonetizationModel {
  /// Buy Foundations once, keep it. The baseline v1 ships.
  oneTime,

  /// Access while subscribed, monthly or yearly.
  subscription,

  /// Subscribe or buy outright, the learner's choice.
  hybrid,
}

/// How long a purchase lasts, which is what separates the arms.
enum PlusTerm {
  /// Bought once, owned forever — a non-consumable.
  lifetime,

  /// Renews monthly.
  monthly,

  /// Renews yearly.
  yearly,
}

/// One purchasable route to Plus.
class PlusOffer {
  /// Creates a [PlusOffer].
  const PlusOffer({required this.productId, required this.term});

  /// The store's identifier for this SKU.
  final String productId;

  /// What buying it grants, and for how long.
  final PlusTerm term;
}

/// The offers one arm presents, in the order the paywall draws them.
class PlusOffering {
  /// Creates a [PlusOffering].
  const PlusOffering({
    required this.model,
    required this.offers,
    this.preselected,
  });

  /// The arm this offering belongs to.
  final MonetizationModel model;

  /// What the learner may buy, in the order the paywall lists them.
  final List<PlusOffer> offers;

  /// The term the paywall picks before the learner touches anything, when it
  /// is not simply the first row.
  final PlusTerm? preselected;

  /// The offer a paywall acts on when the learner has chosen nothing.
  PlusOffer get defaultOffer => offers.firstWhere(
    (offer) => offer.term == preselected,
    orElse: () => offers.first,
  );
}

/// The non-consumable, bought once (ADR-0024).
const String plusLifetimeProductId = 'dev.maximsan.brewPath.plus';

/// The monthly subscription of the two renewing arms.
const String plusMonthlyProductId = 'dev.maximsan.brewPath.plus.monthly';

/// The yearly subscription of the two renewing arms.
const String plusYearlyProductId = 'dev.maximsan.brewPath.plus.yearly';

/// Which SKUs an arm offers — the configuration that switching models is.
///
/// RevenueCat says which arm a learner is on; this stays the one home for
/// what that arm sells (ADR-0024).
PlusOffering offeringFor(MonetizationModel model) => switch (model) {
  MonetizationModel.oneTime => const PlusOffering(
    model: MonetizationModel.oneTime,
    offers: [
      PlusOffer(productId: plusLifetimeProductId, term: PlusTerm.lifetime),
    ],
  ),
  MonetizationModel.subscription => const PlusOffering(
    model: MonetizationModel.subscription,
    offers: [
      PlusOffer(productId: plusMonthlyProductId, term: PlusTerm.monthly),
      PlusOffer(productId: plusYearlyProductId, term: PlusTerm.yearly),
    ],
    preselected: PlusTerm.yearly,
  ),
  MonetizationModel.hybrid => const PlusOffering(
    model: MonetizationModel.hybrid,
    offers: [
      PlusOffer(productId: plusMonthlyProductId, term: PlusTerm.monthly),
      PlusOffer(productId: plusYearlyProductId, term: PlusTerm.yearly),
      PlusOffer(productId: plusLifetimeProductId, term: PlusTerm.lifetime),
    ],
    preselected: PlusTerm.yearly,
  ),
};
