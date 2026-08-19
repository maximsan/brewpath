import 'dart:math';

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_codec.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';
import 'package:flutter/foundation.dart';

/// Everything **Reset Progress** clears — and Delete Account clears too.
///
/// The two scopes are types rather than a convention because that makes two
/// closed decisions true by construction instead of by review:
///
/// - Reset is `clearedByReset: ClearedByReset.empty`, so it **cannot** forget a
///   field. The prototype's reset shipped a defect by omitting exactly one key.
/// - "Every snapshot field sits in exactly one scope" is enforced by the
///   compiler, not by a test that has to be updated whenever a field is added.
///
/// Every field here is **monotonic**. The only non-monotonic operation on the
/// whole snapshot is Reset, which is why the reset generation exists.
///
/// `dailyActivity` will eventually shrink too — pruning drops days nothing
/// reads — but that trim belongs to whichever code first *appends* an event,
/// not here and not to the repository: a store that silently returns
/// something other than what it was handed is a worse bargain than a record
/// that grows a little. See `daily_activity.dart`.
@immutable
class ClearedByReset {
  /// Creates a [ClearedByReset].
  const ClearedByReset({
    this.completedLessons = const {},
    this.bestResults = const {},
    this.activeDays = const {},
    this.acks = const {},
    this.ownedCollectibles = const {},
    this.completedModules = const {},
    this.treeStage = 0,
    this.challengesCompleted = const {},
    this.learnedTerms = const {},
    this.challengeReactions = const {},
    this.dailyActivity = const {},
    this.challengesSaved = _emptyIds,
    this.activeChallenge = _noActiveChallenge,
    this.favourites = _emptyIds,
    this.unknown = const {},
  });

  /// Builds one from its JSON form. Absent fields read as empty, so an older
  /// snapshot decodes without special-casing.
  factory ClearedByReset.fromJson(Map<String, dynamic> json) => ClearedByReset(
    completedLessons: dayMapFromJson(json['completedLessons']),
    bestResults: masteryMapFromJson(json['bestResults']),
    activeDays: intSetFromJson(json['activeDays']),
    acks: dayMapFromJson(json['acks']),
    ownedCollectibles: stringSetFromJson(json['ownedCollectibles']),
    completedModules: stringSetFromJson(json['completedModules']),
    treeStage: json['treeStage'] as int? ?? 0,
    challengesCompleted: stringSetFromJson(json['challengesCompleted']),
    learnedTerms: stringSetFromJson(json['learnedTerms']),
    challengeReactions: reactionMapFromJson(json['challengeReactions']),
    dailyActivity: dayEntriesFromJson(json['dailyActivity']),
    challengesSaved: stampedSetFromJson(json['challengesSaved']),
    activeChallenge: stampedChallengeFromJson(json['activeChallenge']),
    favourites: stampedSetFromJson(json['favourites']),
    unknown: unknownKeys(json, _knownKeys),
  );

  static const _emptyIds = Timestamped<Set<String>>(
    value: {},
    updatedAt: epochMillis,
  );
  static const _noActiveChallenge = Timestamped<ActiveChallenge?>(
    value: null,
    updatedAt: epochMillis,
  );

  /// The zero state, and what Reset writes.
  static const empty = ClearedByReset();

  static const _knownKeys = {
    'completedLessons',
    'bestResults',
    'activeDays',
    'acks',
    'ownedCollectibles',
    'completedModules',
    'treeStage',
    'challengesCompleted',
    'learnedTerms',
    'challengeReactions',
    'dailyActivity',
    'challengesSaved',
    'activeChallenge',
    'favourites',
  };

  /// Lesson id → the day it was **first** completed.
  ///
  /// The date is not decoration: the daily free allowance counts first
  /// completions dated today, which closes the two-device leak where a phone
  /// and a tablet would each grant a full day's quota.
  final Map<String, int> completedLessons;

  /// Lesson id → best graded result, never downgraded.
  final Map<String, MasteryResult> bestResults;

  /// Days the learner completed a qualifying activity, as days since epoch.
  ///
  /// The streak, freezes held, freezes spent, frozen days and the week strip
  /// **all derive from this set**. A counter cannot merge — two devices offline
  /// at five days each do not make five — where a union of days is exactly
  /// right.
  final Set<int> activeDays;

  /// One-off moments the learner has already been shown, keyed by moment.
  ///
  /// Collapsed into one map rather than a field per moment: under a derived
  /// snapshot "has this happened?" stays permanently true, so every one-off
  /// beat needs a marker, and three had already accumulated. As a map a new
  /// moment costs a key; as fields it costs a schema change, a reset-registry
  /// entry and a guard update — which is how one eventually escapes Reset.
  final Map<String, int> acks;

  /// Every collectible earned. Stored in full rather than deriving from lesson
  /// completions, because the lesson id space has already been rewritten once
  /// on this project and a derived set would have silently revoked them.
  final Set<String> ownedCollectibles;

  /// Modules ever completed. A module that later grows stays complete.
  final Set<String> completedModules;

  /// Highest tree stage ever reached, read as `max(stored, derived)`.
  ///
  /// **The outcome, never the ingredients.** Storing the completed-lesson count
  /// and re-deriving the stage looks correct and ships the bug: at `31/36` the
  /// derivation still returns stage 9, so growing the course shrinks a finished
  /// learner's tree.
  ///
  /// Both halves exist now (#150). First completion writes the stage here,
  /// raise-only; the read takes the max with the stage the *current* course
  /// implies, which heals a learner whose stored value predates the writer
  /// without ever letting a grown course lower one.
  final int treeStage;

  /// Brew challenges completed at least once.
  final Set<String> challengesCompleted;

  /// Dictionary terms whose source lesson has been completed.
  final Set<String> learnedTerms;

  /// Challenge id → the reaction logged for it, most recent winning.
  final Map<String, ChallengeReaction> challengeReactions;

  /// Day → the completion events on it, as the free daily allowance counts
  /// them.
  ///
  /// Each entry is **one completion**, not one kind of completion: a set keyed
  /// on type collapses two vocab rounds into one mark, and the cap must see
  /// two (#65). It supersedes `miniGamePlays`, whose day-keyed set of game ids
  /// this generalises — the two-different-games streak rule now derives from
  /// the distinct game ids among a day's entries, unchanged in meaning.
  ///
  /// Meant to be pruned to the last couple of days once something writes it —
  /// best-effort, since a union merge with a peer still holding older days
  /// re-adds them, which is harmless because nothing reads beyond today.
  final Map<int, Set<String>> dailyActivity;

  /// Challenges parked for later. Removal is a first-class action, so this is
  /// last-writer-wins rather than a union that would resurrect every unsave.
  final Timestamped<Set<String>> challengesSaved;

  /// The one challenge in play, or null.
  final Timestamped<ActiveChallenge?> activeChallenge;

  /// Bookmarked lessons, terms and guides, as prefixed keys.
  ///
  /// Last-writer-wins for the same reason: unioning favourites resurrects every
  /// removed bookmark, forever, from any device that still holds it.
  final Timestamped<Set<String>> favourites;

  /// Progress keys written by a newer build, carried through untouched.
  ///
  /// **Scoped, not envelope-level.** Every real field lives inside a scope, so
  /// an envelope-only passthrough would preserve nothing that matters. Keeping
  /// them here also means Reset clears a newer build's progress fields along
  /// with this build's, instead of re-attaching them after the wipe.
  final Map<String, dynamic> unknown;

  /// A copy with the tree grown to at least [stage].
  ///
  /// Raise-only, which is the whole contract: the tree never shrinks, so
  /// growing the course — which lowers what the stage derivation returns for
  /// the same learner — cannot take a stage back.
  ClearedByReset withTreeStageAtLeast(int stage) => ClearedByReset(
    completedLessons: completedLessons,
    bestResults: bestResults,
    activeDays: activeDays,
    acks: acks,
    ownedCollectibles: ownedCollectibles,
    completedModules: completedModules,
    treeStage: stage > treeStage ? stage : treeStage,
    challengesCompleted: challengesCompleted,
    learnedTerms: learnedTerms,
    challengeReactions: challengeReactions,
    dailyActivity: dailyActivity,
    challengesSaved: challengesSaved,
    activeChallenge: activeChallenge,
    favourites: favourites,
    unknown: unknown,
  );

  /// Whether the one-off moment named [key] has been acknowledged.
  bool hasAck(String key) => acks.containsKey(key);

  /// A copy with [key] acknowledged on [day]. The one write the app performs
  /// on this scope so far — a deliberate monotonic add rather than a general
  /// `copyWith`, because every field here is monotonic and an arbitrary
  /// replace is exactly the operation this scope's design rules out.
  ClearedByReset withAck(String key, int day) =>
      _copy(acks: {...acks, key: day});

  /// The one hand-listed copy this scope needs. Private, so a field added to
  /// the scope has a single place to be forgotten.
  ClearedByReset _copy({Map<String, int>? acks}) => ClearedByReset(
    completedLessons: completedLessons,
    bestResults: bestResults,
    activeDays: activeDays,
    acks: acks ?? this.acks,
    ownedCollectibles: ownedCollectibles,
    completedModules: completedModules,
    treeStage: treeStage,
    challengesCompleted: challengesCompleted,
    learnedTerms: learnedTerms,
    challengeReactions: challengeReactions,
    dailyActivity: dailyActivity,
    challengesSaved: challengesSaved,
    activeChallenge: activeChallenge,
    favourites: favourites,
    unknown: unknown,
  );

  /// This scope's JSON form, with unrecognised keys written back verbatim.
  Map<String, dynamic> toJson() => {
    ...unknown,
    'completedLessons': completedLessons,
    'bestResults': masteryMapToJson(bestResults),
    'activeDays': sortedList(activeDays),
    'acks': acks,
    'ownedCollectibles': sortedList(ownedCollectibles),
    'completedModules': sortedList(completedModules),
    'treeStage': treeStage,
    'challengesCompleted': sortedList(challengesCompleted),
    'learnedTerms': sortedList(learnedTerms),
    'challengeReactions': reactionMapToJson(challengeReactions),
    'dailyActivity': dayEntriesToJson(dailyActivity),
    'challengesSaved': challengesSaved.toJson(sortedList),
    'activeChallenge': activeChallenge.toJson((held) => held?.toJson()),
    'favourites': favourites.toJson(sortedList),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClearedByReset &&
          mapEquals(other.completedLessons, completedLessons) &&
          mapEquals(other.bestResults, bestResults) &&
          setEquals(other.activeDays, activeDays) &&
          mapEquals(other.acks, acks) &&
          setEquals(other.ownedCollectibles, ownedCollectibles) &&
          setEquals(other.completedModules, completedModules) &&
          other.treeStage == treeStage &&
          setEquals(other.challengesCompleted, challengesCompleted) &&
          setEquals(other.learnedTerms, learnedTerms) &&
          mapEquals(other.challengeReactions, challengeReactions) &&
          _dayEntriesEqual(other.dailyActivity, dailyActivity) &&
          other.challengesSaved == challengesSaved &&
          other.activeChallenge == activeChallenge &&
          other.favourites == favourites &&
          mapEquals(other.unknown, unknown);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(completedLessons.keys),
    Object.hashAllUnordered(bestResults.keys),
    Object.hashAllUnordered(activeDays),
    Object.hashAllUnordered(acks.keys),
    Object.hashAllUnordered(ownedCollectibles),
    Object.hashAllUnordered(completedModules),
    treeStage,
    Object.hashAllUnordered(challengesCompleted),
    Object.hashAllUnordered(learnedTerms),
    Object.hashAllUnordered(challengeReactions.keys),
    Object.hashAllUnordered(dailyActivity.keys),
    challengesSaved,
    activeChallenge,
    favourites,
    Object.hashAllUnordered(unknown.keys),
  );
}

/// Everything **Delete Account** clears and Reset deliberately keeps.
///
/// The rule is what the learner *chose* rather than what they *did*: a tree
/// skin and a dressed-up companion survive a progress wipe, because "Reset
/// everything" means the trail, not the wardrobe.
@immutable
class ClearedByDeleteOnly {
  /// Creates a [ClearedByDeleteOnly].
  const ClearedByDeleteOnly({
    this.grove = _initialGrove,
    this.companion = _initialCompanion,
    this.unknown = const {},
  });

  /// Builds one from its JSON form.
  factory ClearedByDeleteOnly.fromJson(Map<String, dynamic> json) =>
      ClearedByDeleteOnly(
        grove: stampedObjectFromJson(
          json['grove'],
          Grove.fromJson,
          Grove.initial,
        ),
        companion: stampedObjectFromJson(
          json['companion'],
          CompanionConfig.fromJson,
          CompanionConfig.initial,
        ),
        unknown: unknownKeys(json, _knownKeys),
      );

  /// The uncustomised state, stamped to **win** the merge that carries a
  /// deletion to the other device. This is what Delete writes.
  ///
  /// Not [empty]: these fields merge last-writer-wins rather than by reset
  /// generation, and [empty] stamps them at the epoch — so an unstamped
  /// account tombstone loses to any grove the other device still holds, and the
  /// deletion is walked back by the very peer it was published to.
  ///
  /// The stamp is one past the newest write [current] already holds rather than
  /// [at] itself, because the wall clock is not reliably the maximum: the
  /// stored snapshot can carry a grove stamped *later* than this device reads,
  /// from a peer that synced ahead or from plain skew, and the raw clock then
  /// loses to the exact value the wipe exists to erase. It cannot dominate a
  /// write this device has never seen — no last-writer-wins field can — but it
  /// dominates every one it has.
  ///
  /// A named constructor rather than a stamp applied at the call site, so the
  /// wipe is written where the fields are: a field added to this scope is
  /// declared here, next to the two it joins, rather than in a caller nobody
  /// editing this class would think to open.
  factory ClearedByDeleteOnly.clearedAfter(
    ClearedByDeleteOnly current, {
    required int at,
    required String deviceId,
  }) {
    final stamp = max(at, current._latestStamp + 1);
    return ClearedByDeleteOnly(
      grove: Timestamped(
        value: Grove.initial,
        updatedAt: stamp,
        writerId: deviceId,
      ),
      companion: Timestamped(
        value: CompanionConfig.initial,
        updatedAt: stamp,
        writerId: deviceId,
      ),
    );
  }

  static const _initialGrove = Timestamped<Grove>(
    value: Grove.initial,
    updatedAt: epochMillis,
  );
  static const _initialCompanion = Timestamped<CompanionConfig>(
    value: CompanionConfig.initial,
    updatedAt: epochMillis,
  );

  /// The zero state a fresh install starts from. Delete writes
  /// [ClearedByDeleteOnly.clearedAfter] instead, for the reason recorded there.
  static const empty = ClearedByDeleteOnly();

  static const _knownKeys = {'grove', 'companion'};

  /// Species and light. The first non-monotonic fields on the snapshot.
  final Timestamped<Grove> grove;

  /// How Roasty is dressed.
  final Timestamped<CompanionConfig> companion;

  /// Account keys written by a newer build. Kept here rather than on the
  /// envelope so a Reset preserves them, exactly as it preserves the grove.
  final Map<String, dynamic> unknown;

  /// This scope's JSON form, with unrecognised keys written back verbatim.
  Map<String, dynamic> toJson() => {
    ...unknown,
    'grove': grove.toJson((planted) => planted.toJson()),
    'companion': companion.toJson((dressed) => dressed.toJson()),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClearedByDeleteOnly &&
          other.grove == grove &&
          other.companion == companion &&
          mapEquals(other.unknown, unknown);

  @override
  int get hashCode =>
      Object.hash(grove, companion, Object.hashAllUnordered(unknown.keys));

  /// The newest write this scope holds, from whichever device made it.
  int get _latestStamp => max(grove.updatedAt, companion.updatedAt);
}

bool _dayEntriesEqual(Map<int, Set<String>> a, Map<int, Set<String>> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    final other = b[entry.key];
    if (other == null || !setEquals(other, entry.value)) return false;
  }
  return true;
}
