/// The paywall's model-independent words, and the list of what Plus contains.
///
/// Anything that changes with the pricing model lives in `paywall_config.dart`
/// instead. What is unlocked never does, so it is written once here — with
/// every quantity the design writes counted from the banks, never typed in.
library;

import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paywall_copy.g.dart';

/// The buy action for [term], still carrying its price placeholder.
String paywallPlanCta(PlusTerm term) => paywallPlans[term]!.cta;

/// The words that do not move when the model does.
abstract final class PaywallCopy {
  /// What is sold, leading the eyebrow before the model's own name.
  static const course = 'Foundations';

  /// The top bar's only control.
  static const close = 'Close';

  /// The way out, under the buy action.
  static const maybeLater = 'Maybe later';

  /// While the store call is in flight.
  static const working = 'Working…';

  /// Recovering a purchase made elsewhere.
  static const restore = 'Restore purchases';

  /// The same link while the store is looking.
  static const restoring = 'Restoring…';

  /// Shown in place of the reassurance when no price could be read. A paywall
  /// that cannot name a price must not imply one.
  static const storeUnreachable =
      'We couldn’t reach the App Store. Check your connection and try again.';

  /// The two links the App Store requires of a purchase screen.
  static const terms = 'Terms';

  /// The privacy link.
  static const privacy = 'Privacy';
}

/// One line of what the purchase contains.
class PaywallBenefit {
  /// Creates a [PaywallBenefit].
  const PaywallBenefit({required this.title, required this.detail});

  /// What it is.
  final String title;

  /// The line under it.
  final String detail;
}

/// What Plus contains — the design's five rows, with every number it writes
/// counted from [pitch].
List<PaywallBenefit> paywallBenefitsFor(PlusPitch pitch) => [
  PaywallBenefit(
    title: 'The rest of the course',
    detail: paidModulesLine(pitch),
  ),
  PaywallBenefit(
    title: 'The ${spelledCount(pitch.premiumFormats)} premium formats',
    detail: 'Taste-fix, dial-in and more',
  ),
  const PaywallBenefit(
    title: 'The complete Dictionary',
    detail: 'Every term, full entries included',
  ),
  PaywallBenefit(
    title: 'Unlimited Saved',
    detail: 'Past the free shelf of ${pitch.savedFreeCap}',
  ),
  const PaywallBenefit(
    title: 'The Studio',
    detail: 'Dress up Roasty, choose your plant',
  ),
];

/// `Modules 2–5, every lesson`, from the modules with no free lesson.
String paidModulesLine(PlusPitch pitch) {
  if (pitch.firstPaidModule == 0) return 'Every lesson';
  if (pitch.firstPaidModule == pitch.lastPaidModule) {
    return 'Module ${pitch.firstPaidModule}, every lesson';
  }
  return 'Modules ${pitch.firstPaidModule}–${pitch.lastPaidModule}, '
      'every lesson';
}

const List<String> _countWords = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
];

/// [count] as the design writes a small one — `five`, not `5` — and as digits
/// past ten.
String spelledCount(int count) =>
    count >= 0 && count < _countWords.length ? _countWords[count] : '$count';

/// The benefit list, counted from the shipped banks.
@riverpod
Future<List<PaywallBenefit>> paywallBenefits(Ref ref) async =>
    paywallBenefitsFor(await ref.watch(plusPitchProvider.future));
