/// Whether the learner owns Foundations.
library;

import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_entitlement.g.dart';

/// Whether the learner currently holds the course entitlement.
///
/// Read through the payments abstraction and never from a store SDK, so
/// flipping to a real store touches no feature code. The active no-op reports
/// none, which is what ships today: the app is in the free state by
/// construction, and the entitled path is exercised by overriding this.
@riverpod
Future<bool> courseEntitlement(Ref ref) =>
    ref.watch(paymentsServiceProvider).hasActiveEntitlement();
