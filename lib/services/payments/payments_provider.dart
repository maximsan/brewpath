import 'package:brew_path/services/payments/granted_payments_service.dart';
import 'package:brew_path/services/payments/noop_payments_service.dart';
import 'package:brew_path/services/payments/payments_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Activation: import + return InAppPurchaseService() when payments go live
// (see docs/10-payments.md future-implementation checklist).
// import 'package:brew_path/services/payments/in_app_purchase_service.dart';

part 'payments_provider.g.dart';

/// Whether this build hands the learner the course without a store.
///
/// The development way past the course wall, catalogued in the README's
/// run-time flags table. Compiled in, so a release build that does not pass
/// `--dart-define=GRANT_COURSE=true` is free by construction.
const bool kGrantCourse = bool.fromEnvironment('GRANT_COURSE');

/// Provides the active [PaymentsService] — No-Op until payments go live.
@riverpod
PaymentsService paymentsService(Ref ref) =>
    kGrantCourse ? const GrantedPaymentsService() : const NoOpPaymentsService();
// To go live: => InAppPurchaseService();
