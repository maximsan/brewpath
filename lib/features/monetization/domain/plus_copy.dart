/// Every word the Plus gate says, and the three bullets it ranks.
///
/// The bullets are **ranked, not listed**: an even list makes the course read
/// as one item among several rather than as most of what is being sold. Course
/// first, practice depth second, cosmetics last — the ordering is the product's
/// statement about what it thinks is worth most.
///
/// Every quantity arrives as an argument counted from the banks. Nothing here
/// writes a number down.
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
