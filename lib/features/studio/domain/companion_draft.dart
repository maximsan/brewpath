import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/foundation.dart';

/// What the Roasty section is previewing, before the learner commits to it.
///
/// The grove's `GroveDraft` twin, and for the same reason: the screen edits
/// this, only [outfit] ever reaches the snapshot, and "is confirm live" can be
/// answered without pumping a widget.
@immutable
class CompanionDraft {
  /// Creates a [CompanionDraft].
  const CompanionDraft({
    required this.roast,
    required this.hat,
    required this.gear,
    required this.sprout,
  });

  /// Opens a draft on what Roasty is wearing.
  factory CompanionDraft.of(CompanionConfig worn) => CompanionDraft(
    roast: worn.roast,
    hat: worn.hat,
    gear: worn.gear,
    sprout: worn.sprout,
  );

  /// The roast level being previewed.
  final String roast;

  /// The headwear being previewed.
  final String hat;

  /// The gear being previewed.
  final String gear;

  /// The sprout being previewed.
  final String sprout;

  /// This draft as an outfit, ready to be written.
  CompanionConfig get outfit =>
      CompanionConfig(roast: roast, hat: hat, gear: gear, sprout: sprout);

  /// The same draft at a different roast.
  CompanionDraft withRoast(String id) =>
      CompanionDraft(roast: id, hat: hat, gear: gear, sprout: sprout);

  /// The same draft under a different hat.
  CompanionDraft withHat(String id) =>
      CompanionDraft(roast: roast, hat: id, gear: gear, sprout: sprout);

  /// The same draft wearing different gear.
  CompanionDraft withGear(String id) =>
      CompanionDraft(roast: roast, hat: hat, gear: id, sprout: sprout);

  /// The same draft with a different sprout.
  CompanionDraft withSprout(String id) =>
      CompanionDraft(roast: roast, hat: hat, gear: gear, sprout: id);

  /// Whether this differs from what is [worn] — which is what makes the
  /// confirm live.
  ///
  /// Compared by value: a learner who tries a hat and takes it off again has
  /// nothing to apply, and writing anyway would move the last-writer-wins
  /// stamp for no change and beat a real edit from another device.
  bool isDirtyAgainst(CompanionConfig worn) => outfit != worn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanionDraft &&
          other.roast == roast &&
          other.hat == hat &&
          other.gear == gear &&
          other.sprout == sprout;

  @override
  int get hashCode => Object.hash(roast, hat, gear, sprout);
}
