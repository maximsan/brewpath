import 'package:brew_path/services/payments/granted_payments_service.dart';
import 'package:brew_path/services/payments/noop_payments_service.dart';
import 'package:brew_path/services/payments/payments_service.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
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

/// Which experiment arm a development build's store puts the learner on —
/// `--dart-define=MONETIZATION_MODEL=subscription`, catalogued in the README.
/// Unset, or a name no arm has, is the baseline.
const String kMonetizationModel = String.fromEnvironment('MONETIZATION_MODEL');

/// The arm [name] names, or the baseline when it names none.
MonetizationModel monetizationModelNamed(String name) =>
    MonetizationModel.values.firstWhere(
      (model) => model.name == name,
      orElse: () => MonetizationModel.oneTime,
    );

/// Provides the active [PaymentsService] — No-Op until payments go live.
@riverpod
PaymentsService paymentsService(Ref ref) {
  final model = monetizationModelNamed(kMonetizationModel);

  return kGrantCourse
      ? GrantedPaymentsService(model: model)
      : NoOpPaymentsService(model: model);
}

// To go live: => InAppPurchaseService();
