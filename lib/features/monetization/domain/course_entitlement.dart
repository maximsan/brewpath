/// Whether the learner owns Foundations.
library;

import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_entitlement.g.dart';

/// Emits the store's new answer whenever what the learner owns changes.
///
/// Watched rather than read, so a subscription that lapses or is refunded
/// locks the app without a restart (ADR-0024).
@riverpod
Stream<bool> entitlementChanges(Ref ref) =>
    ref.watch(paymentsServiceProvider).entitlementChanges;

/// Whether the learner currently holds the course entitlement.
///
/// **The one monetization concept feature code may read** (#176) — gates and
/// locked rows ask this and nothing else. Unresolved reads as locked: draw
/// a pending answer as `false`, or await it and show nothing until it lands.
@riverpod
Future<bool> courseEntitlement(Ref ref) {
  ref.watch(entitlementChangesProvider);
  return ref.watch(paymentsServiceProvider).hasActiveEntitlement();
}
