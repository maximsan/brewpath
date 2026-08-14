import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:flutter/foundation.dart';

/// The learner's whole progress state, as one versioned value.
///
/// **This is not a projection of the database — it *is* the database.** One
/// JSON blob in one row, one iCloud key, one pure merge that owns every
/// conflict decision. Normalised progress tables were dropped rather than kept
/// alongside, because a merged snapshot arrives from the outside as a *whole
/// object* and decomposing it back into rows would put merge semantics in a
/// second place no test of the merge can reach — where the obvious SQL is wrong
/// three times over.
///
/// ## Deliberately not stored
///
/// **The shuffle nonce, and any resulting card render order.** Graded cards
/// shuffle their choices per attempt, display-only, with the authored index
/// kept as the grading identity. Persisting the nonce or the order would
/// silently re-fix the answer position across replays *and* across devices,
/// reintroducing the exact bug the shuffle exists to kill. This is stated here
/// because a well-meaning "restore exactly where you were" feature is precisely
/// how it would creep back in.
///
/// **Anything derivable.** Points, the streak, freezes held and spent, frozen
/// days, the week strip, today's remaining allowance, mastery bands, and a
/// dictionary term's learned-or-reference state are all computed. A stored copy
/// would need a merge rule, and a max-merged counter launders an inflation bug
/// permanently — no later correction can lower it.
@immutable
class ProgressSnapshot {
  /// Creates a [ProgressSnapshot].
  const ProgressSnapshot({
    this.version = currentVersion,
    this.updatedAt = 0,
    this.deviceId = '',
    this.resetGeneration = 0,
    this.clearedByReset = ClearedByReset.empty,
    this.clearedByDeleteOnly = ClearedByDeleteOnly.empty,
    this.unknown = const {},
  });

  /// Decodes a snapshot, **keeping every key this build does not recognise**.
  ///
  /// That passthrough is the rule with a real cost, and it exists for a failure
  /// that destroys data silently:
  ///
  /// ```text
  /// tablet (old build) receives the phone's snapshot
  ///   → decodes what it knows, drops what it doesn't
  ///   → merges, re-publishes
  ///   → the new field is GONE from iCloud
  ///   → the phone syncs and loses it, with no error anywhere
  /// ```
  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) {
    final unknown = <String, dynamic>{
      for (final entry in json.entries)
        if (!_knownKeys.contains(entry.key)) entry.key: entry.value,
    };
    return ProgressSnapshot(
      version: json['version'] as int? ?? currentVersion,
      updatedAt: json['updatedAt'] as int? ?? 0,
      deviceId: json['deviceId'] as String? ?? '',
      resetGeneration: json['resetGeneration'] as int? ?? 0,
      clearedByReset: ClearedByReset.fromJson(
        _object(json['clearedByReset']),
      ),
      clearedByDeleteOnly: ClearedByDeleteOnly.fromJson(
        _object(json['clearedByDeleteOnly']),
      ),
      unknown: unknown,
    );
  }

  /// The snapshot schema version this build writes.
  static const currentVersion = 1;

  /// A snapshot holding nothing — a fresh install, and the shape Reset and
  /// Delete publish as a tombstone.
  static const empty = ProgressSnapshot();

  static const _knownKeys = {
    'version',
    'updatedAt',
    'deviceId',
    'resetGeneration',
    'clearedByReset',
    'clearedByDeleteOnly',
  };

  /// Schema version. **Never written lower than the highest ever read**, so an
  /// older build cannot walk the envelope backwards.
  final int version;

  /// Snapshot-level write time, in milliseconds since the Unix epoch.
  final int updatedAt;

  /// Identifies the writing device, purely as a **deterministic tie-break**.
  ///
  /// Without it, two last-writer-wins edits in the same millisecond leave each
  /// device keeping its own answer, and that field never converges.
  final String deviceId;

  /// Bumped by Reset and Delete. Max-merged, and **dominates progress fields**
  /// — scoped to them, so a reset on one device cannot stomp a newer grove on
  /// another.
  final int resetGeneration;

  /// Everything Reset Progress clears.
  final ClearedByReset clearedByReset;

  /// Everything only Delete Account clears.
  final ClearedByDeleteOnly clearedByDeleteOnly;

  /// Keys written by a build newer than this one, carried through untouched.
  final Map<String, dynamic> unknown;

  /// Returns a copy with the given fields replaced.
  ProgressSnapshot copyWith({
    int? version,
    int? updatedAt,
    String? deviceId,
    int? resetGeneration,
    ClearedByReset? clearedByReset,
    ClearedByDeleteOnly? clearedByDeleteOnly,
    Map<String, dynamic>? unknown,
  }) => ProgressSnapshot(
    version: version ?? this.version,
    updatedAt: updatedAt ?? this.updatedAt,
    deviceId: deviceId ?? this.deviceId,
    resetGeneration: resetGeneration ?? this.resetGeneration,
    clearedByReset: clearedByReset ?? this.clearedByReset,
    clearedByDeleteOnly: clearedByDeleteOnly ?? this.clearedByDeleteOnly,
    unknown: unknown ?? this.unknown,
  );

  /// This snapshot's JSON form, with unrecognised keys written back verbatim.
  Map<String, dynamic> toJson() => {
    ...unknown,
    'version': version,
    'updatedAt': updatedAt,
    'deviceId': deviceId,
    'resetGeneration': resetGeneration,
    'clearedByReset': clearedByReset.toJson(),
    'clearedByDeleteOnly': clearedByDeleteOnly.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressSnapshot &&
          other.version == version &&
          other.updatedAt == updatedAt &&
          other.deviceId == deviceId &&
          other.resetGeneration == resetGeneration &&
          other.clearedByReset == clearedByReset &&
          other.clearedByDeleteOnly == clearedByDeleteOnly &&
          mapEquals(other.unknown, unknown);

  @override
  int get hashCode => Object.hash(
    version,
    updatedAt,
    deviceId,
    resetGeneration,
    clearedByReset,
    clearedByDeleteOnly,
    Object.hashAllUnordered(unknown.keys),
  );

  @override
  String toString() =>
      'ProgressSnapshot(v$version, gen$resetGeneration, $deviceId)';
}

Map<String, dynamic> _object(Object? raw) =>
    raw is Map ? Map<String, dynamic>.from(raw) : const {};
