/// Every word the Plus offer says — the gate, the offer screen, and the three
/// bullets both rank.
///
/// The bullets are **ranked, not listed**: course first, practice depth
/// second, cosmetics last, so the course reads as most of what is sold. Every
/// quantity arrives counted from the banks; nothing here writes a number down.
library;

import 'package:brew_path/features/monetization/domain/plus_pitch.dart';

/// One ranked line of the pitch.
class PlusPitchBullet {
  /// Creates a [PlusPitchBullet].
  const PlusPitchBullet({required this.title, required this.body});

  /// The lead — what this part of Plus is.
  final String title;

  /// The line under it, carrying the counted detail.
  final String body;
}

/// The sheet's strings.
abstract final class PlusCopy {
  /// The sheet's heading, and its accessible name.
  ///
  /// Reads as *buy the course*, not *subscribe for perks* — v1 sells a
  /// one-time purchase (ADR-0003), and the tone has to match what is sold.
  static const title = 'Get the full course';

  /// The one action.
  static const buy = 'Unlock BrewPath Plus';

  /// While the store call is in flight.
  static const working = 'Working…';

  /// The way out. The design puts a ghost under the buy button on every gate,
  /// so declining is something the learner does rather than something they
  /// have to guess at by swiping the sheet away.
  static const notNow = 'Not now';

  /// Recovering a purchase made elsewhere.
  static const restore = 'Restore purchase';

  /// The two links the App Store requires of a non-consumable.
  static const terms = 'Terms of use';

  /// The privacy link.
  static const privacy = 'Privacy policy';

  /// Said once the purchase lands.
  static const owned = 'Plus is yours. Everything is unlocked.';

  /// Said while the store waits on someone else — deliberately not success.
  static const pending = 'Waiting for approval. Nothing has been charged yet.';

  /// Said when the store refuses. Plain, and it leaves the learner where they
  /// were.
  static const failed = "That didn't go through. Nothing was charged.";

  /// The offer screen's eyebrow: what is sold, and on what terms.
  ///
  /// Two facts and no more, because the slots under it carry the rest — the
  /// title promises permanence, the note reassures. ADR-0003 fixes the second
  /// half: v1 sells one non-consumable, so the model is never in question.
  static const screenEyebrow = 'BrewPath Plus · One-time purchase';

  /// The offer screen's heading.
  static const screenTitle = 'Own the whole course.';

  /// The reassurance under the offer screen's actions.
  static const screenNote = 'No subscription · fixes and improvements included';

  /// The offer screen's way out, under the buy action.
  ///
  /// Spelled apart from [notNow]: the sheet interrupts something and this
  /// screen is a step the learner is walking through, so declining it is
  /// *later*, not *not now*.
  static const maybeLater = 'Maybe later';

  /// Screen-reader name for the offer screen as a whole.
  static const screenSemanticLabel = 'The BrewPath Plus offer';

  /// The way off the offer screen, in its top bar.
  static const close = 'Close';

  /// The purchase-welcome screen's heading.
  static const welcomeTitle = 'Plus is yours.';

  /// What the purchase bought, said once, on the screen that celebrates it.
  static const welcomeBody =
      'The whole course is unlocked — permanently. Time to make Roasty and '
      'your grove your own.';

  /// The purchase-welcome screen's one action — the design sends a new owner
  /// to the thing they could not open a minute ago.
  static const welcomeOpenStudio = 'Open the Studio';

  /// The way past the celebration, into the app.
  static const welcomeBackToLearning = 'Back to learning';

  /// The fact under the celebration's actions: what was bought, restated.
  static const welcomeNote = 'One-time purchase · yours to keep';

  /// Screen-reader name for the purchase-welcome screen.
  static const welcomeSemanticLabel = 'BrewPath Plus is yours';

  /// The pitch, ranked, with every quantity counted from [pitch].
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
          '${pitch.lockedGames} more mini-games, deep explanations, and the '
          '${pitch.referenceTerms} reference terms no lesson teaches.',
    ),
    PlusPitchBullet(
      title: 'Make it yours',
      body:
          'Dress Roasty, choose your tree, and keep more than '
          '${pitch.savedFreeCap} things on your shelf.',
    ),
  ];
}
