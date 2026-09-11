/// The one sentence in Help that moves with the pricing model.
library;

import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/domain/plus_offering_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'foundations_faq_tail.g.dart';

/// How the Foundations answer closes, in the arm's own words.
///
/// Resolved here rather than in Help so the FAQ is handed a sentence and never
/// learns which arm sold the purchase — the seam #176 exists to hold.
@riverpod
Future<String> foundationsFaqTail(Ref ref) async {
  final offering = await ref.watch(plusOfferingProvider.future);

  return paywallModels[offering.model]!.faq;
}
