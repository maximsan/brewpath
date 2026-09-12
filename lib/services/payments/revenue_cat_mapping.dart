/// What RevenueCat's answers mean in this app's terms.
///
/// Pure, so every mapping is testable without a store behind it.
library;

import 'package:brew_path/services/payments/store_product.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

/// The one RevenueCat entitlement every arm grants.
///
/// One name whatever bought it, which is what lets the experiment pick a
/// winner without anybody losing what they own (#176).
const String foundationsEntitlementId = 'foundations';

/// What each arm's RevenueCat offering is called.
///
/// The dashboard moves a learner between arms by changing which offering is
/// current for them.
const Map<String, MonetizationModel> offeringArms = {
  'one_time': MonetizationModel.oneTime,
  'subscription': MonetizationModel.subscription,
  'hybrid': MonetizationModel.hybrid,
};

/// The arm [offeringId] names, or the baseline when it names none.
MonetizationModel armFor(String? offeringId) =>
    offeringArms[offeringId] ?? MonetizationModel.oneTime;

/// Whether [info] carries the course.
bool isEntitled(rc.CustomerInfo info) =>
    info.entitlements.active.containsKey(foundationsEntitlementId);

/// RevenueCat's product as the paywall's own.
StoreProduct asStoreProduct(rc.StoreProduct product) => StoreProduct(
  id: product.identifier,
  title: product.title,
  description: product.description,
  price: product.priceString,
  amount: product.price,
  currencyCode: product.currencyCode,
);
