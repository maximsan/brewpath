/// The paywall's model-independent words, and the list of what Plus contains.
///
/// Anything that changes with the pricing model lives in `paywall_config.dart`
/// instead. What is unlocked never does, so it is written once here — with
/// every quantity counted from the banks, never typed in.
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
  /// The top bar's only control.
  static const close = 'Close';

  /// The way out, under the buy action.
  static const maybeLater = 'Maybe later';

  /// While the store call is in flight.
  static const working = 'Working…';

  /// Recovering a purchase made elsewhere.
  static const restore = 'Restore purchases';

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

  /// The counted detail beside it.
  final String detail;
}

/// What Plus contains, counted from the banks.
List<PaywallBenefit> paywallBenefitsFor(PlusPitch pitch) => [
  PaywallBenefit(
    title: 'The rest of the course',
    detail: '${pitch.remainingLessons} more lessons, every module',
  ),
  PaywallBenefit(
    title: 'Practice without limits',
    detail: '${pitch.lockedGames} more mini-games',
  ),
  PaywallBenefit(
    title: 'The complete Dictionary',
    detail: '${pitch.referenceTerms} terms no lesson teaches',
  ),
  PaywallBenefit(
    title: 'Unlimited Saved',
    detail: 'Past the free shelf of ${pitch.savedFreeCap}',
  ),
  const PaywallBenefit(
    title: 'The Studio',
    detail: 'Dress Roasty, choose your tree',
  ),
];

/// The benefit list, counted from the shipped banks.
@riverpod
Future<List<PaywallBenefit>> paywallBenefits(Ref ref) async =>
    paywallBenefitsFor(await ref.watch(plusPitchProvider.future));
