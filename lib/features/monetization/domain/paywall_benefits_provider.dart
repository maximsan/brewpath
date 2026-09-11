import 'package:brew_path/features/monetization/config/paywall_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paywall_benefits_provider.g.dart';

/// The paywall's benefit rows, counted from the shipped banks.
@riverpod
Future<List<PaywallBenefit>> paywallBenefits(Ref ref) async =>
    paywallBenefitsFor(await ref.watch(plusPitchProvider.future));
