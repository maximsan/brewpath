/// The free shelf's soft cap, and what a save attempt does about it.
library;

import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:flutter/foundation.dart';

/// How many things a free learner may keep.
///
/// The design's number, and the paywall's one concrete hook. Plus lifts it.
const int savedFreeMax = 5;

/// What an attempted save did.
///
/// An outcome rather than a boolean, so the caller **cannot forget the
/// refusal**: the three cases are exhaustive, and the gate is one of them.
@immutable
sealed class SaveOutcome {
  const SaveOutcome();

  /// The key went on the shelf.
  const factory SaveOutcome.saved(Set<String> keys) = SaveSaved;

  /// The key came off it.
  const factory SaveOutcome.removed(Set<String> keys) = SaveRemoved;

  /// A free shelf was full, so nothing moved and the Plus gate is owed.
  const factory SaveOutcome.gateRaised() = SaveGateRaised;
}

/// The shelf after a key was added.
@immutable
class SaveSaved extends SaveOutcome {
  /// Creates a [SaveSaved].
  const SaveSaved(this.keys);

  /// The shelf to store.
  final Set<String> keys;

  @override
  bool operator ==(Object other) =>
      other is SaveSaved && setEquals(keys, other.keys);

  @override
  int get hashCode => Object.hashAllUnordered(keys);
}

/// The shelf after a key was taken off.
@immutable
class SaveRemoved extends SaveOutcome {
  /// Creates a [SaveRemoved].
  const SaveRemoved(this.keys);

  /// The shelf to store.
  final Set<String> keys;

  @override
  bool operator ==(Object other) =>
      other is SaveRemoved && setEquals(keys, other.keys);

  @override
  int get hashCode => Object.hashAllUnordered(keys);
}

/// Nothing moved: a free learner is at the cap and the gate is owed.
@immutable
class SaveGateRaised extends SaveOutcome {
  /// Creates a [SaveGateRaised].
  const SaveGateRaised();

  @override
  bool operator ==(Object other) => other is SaveGateRaised;

  @override
  int get hashCode => (SaveGateRaised).hashCode;
}

/// What toggling [key] should do, given the shelf and the learner's tier.
///
/// **The cap is checked on the add path only.** That is what makes "removal is
/// always allowed" true by construction rather than by review: there is no
/// branch where a full shelf can refuse to give something back, so a capped
/// learner can always curate.
///
/// [visible] is how many rows the shelf would actually draw — **not** how many
/// keys are stored. The two differ when a saved key does not resolve here: a
/// guide earned on another device and synced to this one, or content an update
/// removed. Counting the stored keys instead would refuse a save while the
/// shelf said `3 of 5`, which is the contradiction this parameter exists to
/// prevent. A learner is held to the number they are shown.
///
/// The cost is that the cap is per-device in that rare case, which the design
/// already accepts by calling this a **soft** cap.
SaveOutcome attemptSave({
  required String key,
  required Set<String> keys,
  required int visible,
  required bool isPlus,
}) {
  if (keys.contains(key)) {
    return SaveOutcome.removed({...keys}..remove(key));
  }
  if (!isPlus && visible >= savedFreeMax) return const SaveOutcome.gateRaised();
  return SaveOutcome.saved({...keys, key});
}

/// The line under the shelf's title.
///
/// A free learner sees their shelf **against the cap**, because the number
/// that matters to them is how much room is left. A Plus learner sees a plain
/// count, because a limit that does not apply to them is noise.
///
/// [count] is the number of rows the shelf draws — the same number
/// [attemptSave] judges, so what a learner is shown is what they are held to.
///
/// The over-cap wording exists for a shelf that was filled on Plus and is now
/// being read without it: the cap refuses new saves, it never takes anything
/// away.
String savedCountLine({required int count, required bool isPlus}) {
  if (isPlus) return '${savedItemCount(count)} to revisit';
  if (count > savedFreeMax) return '$count saved · free limit $savedFreeMax';
  return '$count of $savedFreeMax saved';
}

/// Whether a free learner's shelf is full, and the offer is worth showing.
bool savedShelfIsFull({required int count, required bool isPlus}) =>
    !isPlus && count >= savedFreeMax;
