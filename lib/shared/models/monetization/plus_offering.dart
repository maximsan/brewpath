/// What the store puts in front of one learner: which model, and which SKUs.
library;

/// One arm of the post-launch pricing experiment (ADR-0003, #176).
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
  const PlusOffering({required this.model, required this.offers});

  /// The arm this offering belongs to.
  final MonetizationModel model;

  /// What the learner may buy, first one preselected.
  final List<PlusOffer> offers;

  /// The offer a paywall acts on when the learner has chosen nothing.
  PlusOffer get defaultOffer => offers.first;
}

/// The one-time SKU v1 sells (ADR-0003).
const String plusLifetimeProductId = 'dev.maximsan.brewPath.plus';

/// Which SKUs an arm offers — the configuration that switching models is.
///
/// Only the baseline is built. The other two arms have no SKUs registered in
/// App Store Connect, and naming some here would be inventing a product
/// decision, so asking for one fails rather than returning a guess.
PlusOffering offeringFor(MonetizationModel model) => switch (model) {
  MonetizationModel.oneTime => const PlusOffering(
    model: MonetizationModel.oneTime,
    offers: [
      PlusOffer(productId: plusLifetimeProductId, term: PlusTerm.lifetime),
    ],
  ),
  MonetizationModel.subscription ||
  MonetizationModel.hybrid => throw UnimplementedError(
    '${model.name} sells no registered SKU yet — docs/10-payments.md',
  ),
};
