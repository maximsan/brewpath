/// Which paywall this learner gets, and what it may sell them.
library;

import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_offering_provider.g.dart';

/// The arm this learner is on, read through the payments seam.
///
/// Kept alive so the arm is asked for once and cannot change under a learner
/// mid-session; only the paywall may read it (#176).
@Riverpod(keepAlive: true)
Future<PlusOffering> plusOffering(Ref ref) =>
    ref.watch(paymentsServiceProvider).currentOffering();
