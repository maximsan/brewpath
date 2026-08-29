/// Whether the learner owns Foundations.
library;

import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_entitlement.g.dart';

/// Whether the learner currently holds the course entitlement.
///
/// **The one monetization concept feature code may read.** Gates, locked rows
/// and lock marks ask this and nothing else; nothing outside this folder
/// imports the payments service. That is what makes swapping the model — a
/// subscription arm, a hybrid — a change to how a purchase maps to
/// entitlement, never a change to an access check.
///
/// Read through the payments abstraction and never from a store SDK, so
/// flipping to a real store touches no feature code. The active no-op reports
/// none, which is what ships today: the app is in the free state by
/// construction, and the entitled path is exercised by overriding this.
///
/// **Unresolved reads as locked.** Every caller resolves the pending state to
/// `false`, because showing a lock briefly to a paying learner is recoverable
/// and showing paid content briefly to a free one is not.
@riverpod
Future<bool> courseEntitlement(Ref ref) =>
    ref.watch(paymentsServiceProvider).hasActiveEntitlement();
