/// Every word the selling surfaces say that does **not** change with the
/// pricing model: the paywall, the gate sheet, the outcome line and the
/// purchase welcome. What changes with the model is `paywall_config.dart`,
/// next to this; what is counted arrives from the banks, never typed in.
library;

import 'package:brew_path/features/monetization/config/paywall_config.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/shared/models/monetization/plus_offering.dart';

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

  /// Recovering a purchase made elsewhere — the paywall's link and the gate's.
  static const restore = 'Restore purchases';

  /// Purchases' row into the offer.
  static const unlock = 'Unlock Foundations';

  /// Purchases' row out to Apple, where a plan is changed or stopped.
  static const manageSubscription = 'Manage subscription';

  /// The same link while the store is looking.
  static const restoring = 'Restoring…';

  /// Shown in place of the reassurance when no price could be read. A paywall
  /// that cannot name a price must not imply one.
  static const storeUnreachable =
      'We couldn’t reach the App Store. Check your connection and try again.';

  /// The two links the App Store requires of a purchase surface.
  static const terms = 'Terms';

  /// The privacy link.
  static const privacy = 'Privacy';

  /// The gate sheet's heading, and its accessible name.
  static const gateTitle = 'Get the full course';

  /// The gate sheet's way out — a ghost under the buy button, as the design
  /// puts on every gate.
  static const notNow = 'Not now';

  /// Said once the purchase lands.
  static const owned = 'Foundations is yours. Everything is unlocked.';

  /// Said while the store waits on someone else — deliberately not success.
  static const pending = 'Waiting for approval. Nothing has been charged yet.';

  /// Said when the store refuses; it leaves the learner where they were.
  static const failed = "That didn't go through. Nothing was charged.";

  /// Said when Restore finds nothing, naming the likely cause.
  static const nothingToRestore =
      'No purchase found on this account. If you bought Foundations with '
      'another Apple Account, sign in with that one and try again.';

  /// The purchase welcome's heading, whichever plan was bought.
  static const welcomeTitle = 'Foundations is yours.';

  /// The welcome's one action — the design sends a new owner to the thing
  /// they could not open a minute ago.
  static const welcomeOpenStudio = 'Open the Studio';

  /// The way past the celebration, into the app.
  static const welcomeBackToLearning = 'Back to learning';

  /// Screen-reader name for the purchase welcome.
  static const welcomeSemanticLabel = 'Foundations is yours';

  /// The gate sheet's pitch, ranked — course first, practice depth second,
  /// cosmetics last — with every quantity counted from [pitch].
  static List<PlusPitchBullet> bulletsFor(PlusPitch pitch) => [
    PlusPitchBullet(
      title: 'The rest of the course',
      body:
          '${pitch.remainingLessons} more lessons across the whole of '
          'Beginner Foundations, yours for good.',
    ),
    PlusPitchBullet(
      title: 'Practice without limits',
      body:
          '${pitch.lockedGames} more mini-games, and the '
          '${pitch.referenceTerms} terms no lesson teaches.',
    ),
    PlusPitchBullet(
      title: 'Make it yours',
      body:
          'Dress Roasty, choose your tree, and keep more than '
          '${pitch.savedFreeCap} things on your shelf.',
    ),
  ];
}

/// One ranked line of the gate sheet's pitch.
class PlusPitchBullet {
  /// Creates a [PlusPitchBullet].
  const PlusPitchBullet({required this.title, required this.body});

  /// The lead — what this part of Plus is.
  final String title;

  /// The line under it, carrying the counted detail.
  final String body;
}

/// One line of what the purchase contains, on the paywall.
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
