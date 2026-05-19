import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/services/payments/noop_payments_service.dart';
import 'package:coffee_quest/services/payments/payments_service.dart';
// Activation: import + return InAppPurchaseService() when payments go live
// (see docs/10-payments.md future-implementation checklist).
// import 'package:coffee_quest/services/payments/in_app_purchase_service.dart';

part 'payments_provider.g.dart';

@riverpod
PaymentsService paymentsService(Ref ref) => const NoOpPaymentsService();
// To go live: => InAppPurchaseService();
