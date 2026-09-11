/// Every word that changes when the pricing model does — and nothing else.
///
/// Owns how Foundations is sold, never what is unlocked (#176). Prices stay
/// out: the store formats them for the learner's own storefront, so copy
/// carries [pricePlaceholder] and [perMonthPlaceholder] and the screen
/// substitutes.
library;

import 'package:brew_path/shared/models/monetization/plus_offering.dart';

/// Where a plan's own price is substituted into a line of copy.
const String pricePlaceholder = '{price}';

/// Where a per-month figure — a yearly price over twelve — is substituted.
const String perMonthPlaceholder = '{perMonth}';

/// How one plan is described, once the store has said what it costs.
///
/// Joined to what the store sells by [PlusTerm] — the offering names terms,
/// this names what each is called and how it is sold.
class PaywallPlan {
  /// Creates a [PaywallPlan].
  const PaywallPlan({
    required this.term,
    required this.name,
    required this.per,
    required this.line,
    required this.cta,
    required this.welcome,
    required this.welcomeNote,
    required this.ownedChip,
    required this.ownedFooter,
    this.perMonthLine,
  });

  /// Which term this describes.
  final PlusTerm term;

  /// The plan row's name — `Lifetime`, `Monthly`, `Yearly`.
  final String name;

  /// What follows the price on the row, or null when nothing renews.
  final String? per;

  /// The row's one fact line, under the name.
  final String line;

  /// The fact line once a per-month figure is known, carrying
  /// [perMonthPlaceholder]; null for a plan that has no such figure.
  final String? perMonthLine;

  /// The buy button, carrying [pricePlaceholder].
  final String cta;

  /// The post-purchase screen's headline.
  final String welcome;

  /// The line under it, naming what was bought.
  final String welcomeNote;

  /// What the Purchases screen's status chip reads once this is owned.
  final String ownedChip;

  /// The two-line footer under an owned purchase.
  final List<String> ownedFooter;
}

/// How one arm sells Foundations: which plans, and every line that frames them.
class PaywallModel {
  /// Creates a [PaywallModel].
  const PaywallModel({
    required this.model,
    required this.label,
    required this.eyebrow,
    required this.heroTitle,
    required this.paywallNote,
    required this.gateCta,
    required this.gateFooter,
    required this.purchasesFooter,
    required this.faq,
  });

  /// The arm this describes.
  final MonetizationModel model;

  /// What this arm is called in a settings list.
  final String label;

  /// The kicker over the hero — the model, named.
  final String eyebrow;

  /// The hero's promise about permanence.
  final String heroTitle;

  /// The one fact under the buy button that nothing else on the screen states.
  final String paywallNote;

  /// The gate sheet's action, carrying a placeholder.
  final String gateCta;

  /// The mono line under the gate sheet's action.
  final String gateFooter;

  /// The Purchases screen's two-line free-state caption.
  final List<String> purchasesFooter;

  /// The model-specific tail of the Foundations FAQ answer.
  final String faq;
}

/// What each plan is called and how it is sold.
const Map<PlusTerm, PaywallPlan> paywallPlans = {
  PlusTerm.lifetime: PaywallPlan(
    term: PlusTerm.lifetime,
    name: 'Lifetime',
    per: null,
    line: 'One payment · yours to keep',
    cta: 'Unlock Foundations — $pricePlaceholder',
    welcome:
        'The whole course is unlocked — permanently. Time to make Roasty and '
        'your grove your own.',
    welcomeNote: 'One-time purchase',
    ownedChip: 'Owned',
    ownedFooter: ['Purchased through the App Store.', 'Nothing renews.'],
  ),
  PlusTerm.monthly: PaywallPlan(
    term: PlusTerm.monthly,
    name: 'Monthly',
    per: '/month',
    line: 'Billed monthly',
    cta: 'Subscribe — $pricePlaceholder/month',
    welcome:
        'The whole course is unlocked for as long as you’re subscribed. Time '
        'to make Roasty and your grove your own.',
    welcomeNote: 'Cancel anytime',
    ownedChip: 'Active',
    ownedFooter: [
      'Billed through the App Store. Cancel anytime —',
      'access runs to the end of the paid period.',
    ],
  ),
  PlusTerm.yearly: PaywallPlan(
    term: PlusTerm.yearly,
    name: 'Yearly',
    per: '/year',
    line: 'Billed yearly',
    perMonthLine: '$perMonthPlaceholder/month, billed yearly',
    cta: 'Subscribe — $pricePlaceholder/year',
    welcome:
        'The whole course is unlocked for as long as you’re subscribed. Time '
        'to make Roasty and your grove your own.',
    welcomeNote: 'Cancel anytime',
    ownedChip: 'Active',
    ownedFooter: [
      'Billed through the App Store. Cancel anytime —',
      'access runs to the end of the paid period.',
    ],
  ),
};

/// How each arm frames the plans it sells.
const Map<MonetizationModel, PaywallModel> paywallModels = {
  MonetizationModel.oneTime: PaywallModel(
    model: MonetizationModel.oneTime,
    label: 'One-time purchase',
    eyebrow: 'ONE-TIME PURCHASE',
    heroTitle: 'Own the whole course.',
    paywallNote: 'Fixes and improvements included',
    gateCta: 'Unlock Foundations — $pricePlaceholder',
    gateFooter: 'One-time purchase · yours to keep',
    purchasesFooter: [
      'Foundations is a one-time purchase',
      'through the App Store.',
    ],
    faq:
        'Buy it once and it’s yours for good; there’s no subscription and '
        'nothing renews.',
  ),
  MonetizationModel.subscription: PaywallModel(
    model: MonetizationModel.subscription,
    label: 'Subscription',
    eyebrow: 'SUBSCRIPTION',
    heroTitle: 'The whole course, for as long as you’re brewing.',
    // Owner ruling, 11 Sep 2026 (#581): the note is the second half only.
    paywallNote: 'You keep the time you paid for',
    gateCta: 'Unlock Foundations — from $perMonthPlaceholder/mo',
    gateFooter: 'Subscription · cancel anytime',
    purchasesFooter: [
      'Foundations is a subscription',
      'through the App Store. Cancel anytime.',
    ],
    faq:
        'It’s a subscription — monthly or yearly, your pick — and stays open '
        'while you’re subscribed. Cancel anytime; access runs to the end of '
        'the paid period.',
  ),
  MonetizationModel.hybrid: PaywallModel(
    model: MonetizationModel.hybrid,
    label: 'Hybrid',
    eyebrow: 'SUBSCRIBE OR OWN IT',
    heroTitle: 'The whole course, your terms.',
    paywallNote: 'Fixes and improvements included, whichever you pick',
    gateCta: 'Unlock Foundations — from $perMonthPlaceholder/mo',
    gateFooter: 'Or one payment, yours to keep',
    purchasesFooter: [
      'Subscribe monthly or yearly — or buy once',
      'through the App Store and keep it.',
    ],
    faq:
        'Your choice — subscribe monthly or yearly, or make a single '
        'one-time purchase and keep it forever.',
  ),
};
