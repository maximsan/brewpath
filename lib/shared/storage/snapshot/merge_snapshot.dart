import 'dart:math';

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';

/// Joins two snapshots into one.
///
/// **Pure by design** — two snapshots in, one out, with no database, no I/O and
/// no clock. That is not tidiness: a key-value write is *not durable*, so the
/// platform may discard a local write in favour of server values and hand back
/// a change notification instead. The only correct response is to merge on
/// arrival and re-publish, which means this function runs on every sync and
/// every conflict case must be testable without a device.
///
/// It is a **lattice join**: idempotent, commutative and associative. Those
/// three laws *are* convergence — they are why two devices reach the same
/// state regardless of which synced first or how often a payload arrived — and
/// they are asserted directly over generated snapshots rather than assumed.
///
/// A consequence worth knowing at the call site: because the join is
/// idempotent, a **dropped** change notification is a deferred read, not a lost
/// write. Re-reading later reaches the same state, which is why the platform
/// layer needs no queue.
ProgressSnapshot mergeSnapshot(
  ProgressSnapshot local,
  ProgressSnapshot remote,
) {
  final generation = max(local.resetGeneration, remote.resetGeneration);

  return ProgressSnapshot(
    // Never written lower than the highest ever read.
    version: max(local.version, remote.version),
    updatedAt: max(local.updatedAt, remote.updatedAt),
    deviceId: _laterDevice(local, remote),
    resetGeneration: generation,
    clearedByReset: _mergeProgress(local, remote, generation),
    // Account fields keep their own rule even when a reset dominates progress:
    // otherwise resetting on the phone would stomp a newer grove on the tablet.
    clearedByDeleteOnly: _mergeAccount(local, remote),
    unknown: _mergeUnknown(local.unknown, remote.unknown),
  );
}

/// Progress fields, with reset-generation dominance applied first.
///
/// **Dominance is scoped to this half of the snapshot.** A higher generation
/// means a Reset or Delete happened, and its whole progress state wins outright
/// rather than merging — otherwise the union rules would resurrect exactly the
/// data the reset existed to destroy.
ClearedByReset _mergeProgress(
  ProgressSnapshot local,
  ProgressSnapshot remote,
  int generation,
) {
  if (local.resetGeneration != remote.resetGeneration) {
    return local.resetGeneration == generation
        ? local.clearedByReset
        : remote.clearedByReset;
  }
  return _joinProgress(local, remote);
}

ClearedByReset _joinProgress(ProgressSnapshot local, ProgressSnapshot remote) {
  final a = local.clearedByReset;
  final b = remote.clearedByReset;
  return ClearedByReset(
    // First completion is the true one, so collisions keep the earlier day.
    // `min` is still a lattice operation, so this converges either way round.
    completedLessons: _mergeMap(a.completedLessons, b.completedLessons, min),
    bestResults: _mergeMap(a.bestResults, b.bestResults, MasteryResult.best),
    activeDays: {...a.activeDays, ...b.activeDays},
    acks: _mergeMap(a.acks, b.acks, max),
    ownedCollectibles: {...a.ownedCollectibles, ...b.ownedCollectibles},
    completedModules: {...a.completedModules, ...b.completedModules},
    treeStage: max(a.treeStage, b.treeStage),
    challengesCompleted: {...a.challengesCompleted, ...b.challengesCompleted},
    learnedTerms: {...a.learnedTerms, ...b.learnedTerms},
    challengeReactions: _mergeMap(
      a.challengeReactions,
      b.challengeReactions,
      _laterReaction,
    ),
    miniGamePlays: _mergeMap(
      a.miniGamePlays,
      b.miniGamePlays,
      (mine, theirs) => {...mine, ...theirs},
    ),
    challengesSaved: _lastWriterWins(a.challengesSaved, b.challengesSaved),
    activeChallenge: _lastWriterWins(a.activeChallenge, b.activeChallenge),
    favourites: _lastWriterWins(a.favourites, b.favourites),
    unknown: _mergeUnknown(a.unknown, b.unknown),
  );
}

ClearedByDeleteOnly _mergeAccount(
  ProgressSnapshot local,
  ProgressSnapshot remote,
) => ClearedByDeleteOnly(
  grove: _lastWriterWins(
    local.clearedByDeleteOnly.grove,
    remote.clearedByDeleteOnly.grove,
  ),
  companion: _lastWriterWins(
    local.clearedByDeleteOnly.companion,
    remote.clearedByDeleteOnly.companion,
  ),
  unknown: _mergeUnknown(
    local.clearedByDeleteOnly.unknown,
    remote.clearedByDeleteOnly.unknown,
  ),
);

/// Union of two maps, resolving a shared key with [resolve].
///
/// [resolve] must itself be idempotent, commutative and associative — every
/// caller passes `min`, `max`, a never-downgrade comparator or a set union, all
/// of which are.
Map<K, V> _mergeMap<K, V>(Map<K, V> a, Map<K, V> b, V Function(V, V) resolve) {
  final merged = Map<K, V>.of(a);
  for (final entry in b.entries) {
    final mine = merged[entry.key];
    merged[entry.key] = mine == null ? entry.value : resolve(mine, entry.value);
  }
  return merged;
}

/// A replay replaces an older answer **through the merge rule** rather than at
/// the call site, so two devices logging the same challenge converge on the
/// later reaction without either needing to know the other exists.
ChallengeReaction _laterReaction(ChallengeReaction a, ChallengeReaction b) {
  if (a.at != b.at) return a.at > b.at ? a : b;
  // Same day: order the text so the result cannot depend on argument order.
  return a.reaction.compareTo(b.reaction) >= 0 ? a : b;
}

/// The only merge class that **discards**, so it is used only where a value can
/// legitimately go backwards — removal is a first-class action for saved
/// challenges and favourites, and only one challenge can be active.
///
/// Ties break on device id. Without that, two writes in the same millisecond
/// leave each device keeping its own answer and the field never converges —
/// which is a silent, permanent divergence rather than a visible error.
Timestamped<T> _lastWriterWins<T>(Timestamped<T> a, Timestamped<T> b) {
  if (a.updatedAt != b.updatedAt) return a.updatedAt > b.updatedAt ? a : b;
  if (a.writerId != b.writerId) {
    return a.writerId.compareTo(b.writerId) > 0 ? a : b;
  }
  // Same instant, same writer, different content. Vanishingly rare in the
  // field, but a comparator that stops here is a *partial* order — and a
  // partial order is exactly how a field never converges. The content itself
  // is the last key available, so it is the one used.
  return _canonical(a.value).compareTo(_canonical(b.value)) >= 0 ? a : b;
}

/// A stable string for any last-writer-wins payload, used only as the final
/// tie-break. Collections are sorted, so it never depends on iteration order.
String _canonical(Object? value) => switch (value) {
  null => '',
  final Set<Object?> ids => _sortedJoin(ids.map(_canonical)),
  final List<Object?> items => items.map(_canonical).join(','),
  // Sorted by key: a Dart map stringifies in insertion order, so two devices
  // holding the *same* unknown object written in a different key order would
  // otherwise canonicalise differently and pick different winners.
  final Map<Object?, Object?> fields => _sortedJoin(
    fields.entries.map((field) => '${field.key}=${_canonical(field.value)}'),
  ),
  final ActiveChallenge challenge => '${challenge.id}@${challenge.startedAt}',
  final Grove grove => '${grove.variety}/${grove.light}',
  final CompanionConfig dressed =>
    '${dressed.roast}/${dressed.hat}/${dressed.gear}/${dressed.sprout}',
  _ => '$value',
};

String _sortedJoin(Iterable<String> parts) =>
    (parts.toList()..sort()).join(',');

/// The envelope's device id follows the newer write, with the same tie-break,
/// so a merged snapshot names a single writer rather than an arbitrary one.
String _laterDevice(ProgressSnapshot local, ProgressSnapshot remote) {
  if (local.updatedAt != remote.updatedAt) {
    return local.updatedAt > remote.updatedAt
        ? local.deviceId
        : remote.deviceId;
  }
  return local.deviceId.compareTo(remote.deviceId) >= 0
      ? local.deviceId
      : remote.deviceId;
}

/// Keys this build does not recognise, carried through untouched.
///
/// A collision is resolved by comparing the values themselves rather than by
/// asking which snapshot is newer. Envelope-level resolution is not associative
/// here — a merged snapshot's timestamp says nothing about which of its
/// unknown keys came from where — and these are by definition values this build
/// cannot interpret, so any *deterministic* rule converges equally well.
Map<String, dynamic> _mergeUnknown(
  Map<String, dynamic> a,
  Map<String, dynamic> b,
) => _mergeMap(
  a,
  b,
  (mine, theirs) =>
      _canonical(mine).compareTo(_canonical(theirs)) >= 0 ? mine : theirs,
);
