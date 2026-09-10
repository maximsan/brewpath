/// The paywall, priced by the store this learner is actually buying from.
library;

import 'package:brew_path/features/monetization/domain/paywall_view.dart';
import 'package:brew_path/features/monetization/domain/plus_offering_provider.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paywall_view_provider.g.dart';

/// What the paywall draws: the arm's own words, with the store's prices in.
///
/// The store is asked only for the SKUs this arm sells, so an arm nobody is
/// on costs no round trip.
@riverpod
Future<PaywallView> paywallView(Ref ref) async {
  final offering = await ref.watch(plusOfferingProvider.future);
  final products = await ref.watch(paymentsServiceProvider).getProducts([
    for (final offer in offering.offers) offer.productId,
  ]);

  return buildPaywallView(offering: offering, products: products);
}
