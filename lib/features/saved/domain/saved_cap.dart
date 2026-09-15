/// The free shelf's soft cap, and what a save attempt does about it.
library;

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
/// The cap is checked on the add path only, so no branch can refuse to give
/// something back and a capped learner can always curate. [visible] is how
/// many rows the shelf draws, not how many keys are stored: counting the keys
/// would refuse a save while the shelf still said `3 of 5`.
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

/// The line under the shelf's title, or null where the page already says it.
///
/// Only the free cap earns a line. An owner's total restated the per-group
/// counts beside each group header; the free limit is stated nowhere else,
/// and the upgrade prompt below it depends on that context. [count] is what
/// [attemptSave] judges, so a learner is held to the number they are shown.
String? savedCountLine({required int count, required bool isPlus}) {
  if (isPlus) return null;
  // A shelf filled on Plus and now read without it: the cap refuses new
  // saves, it never takes anything away.
  if (count > savedFreeMax) return '$count saved · free limit $savedFreeMax';
  return '$count of $savedFreeMax saved';
}

/// Whether a free learner's shelf is full, and the offer is worth showing.
bool savedShelfIsFull({required int count, required bool isPlus}) =>
    !isPlus && count >= savedFreeMax;
