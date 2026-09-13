/// Which plan the learner holds, as the store reports it.
library;

import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'owned_term.g.dart';

/// The term the learner currently holds, or null when they hold none.
///
/// Asked of the store, not of `PurchasedTerm`, which records only what *this
/// session* bought — so it survives a restart and a plan changed elsewhere.
@riverpod
Future<PlusTerm?> ownedTerm(Ref ref) {
  ref.watch(entitlementChangesProvider);
  return ref.watch(paymentsServiceProvider).activeTerm();
}
