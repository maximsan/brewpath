import 'dart:math';

import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_codec.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/term_miss.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';
import 'package:flutter/foundation.dart';

/// Everything **Reset Progress** clears — and Delete Account clears too.
///
/// A type rather than a convention, so two decisions hold by construction:
/// reset is `clearedByReset: ClearedByReset.empty` and **cannot** forget a
/// field, and every snapshot field sits in exactly one scope. Every field here
/// is monotonic; Reset is the whole snapshot's only non-monotonic operation.
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
    this.termAnswers = const {},
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
    termAnswers: termMissMapFromJson(json['termAnswers']),
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
    'termAnswers',
    'challengeReactions',
    'dailyActivity',
    'challengesSaved',
    'activeChallenge',
    'favourites',
  };

  /// Lesson id → the day it was **first** completed.
  ///
  /// The day backfills the streak for a learner whose history predates the day
  /// set: `streakDaySet` unions these in and is their only reader. Merging
  /// keeps the **earliest** of two devices' answers. It does not feed the free
  /// daily allowance (#115) — `canStartActivity` counts [dailyActivity].
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
  /// One map rather than a field per moment: every one-off beat needs a
  /// marker, and as a map a new moment costs a key, where as a field it costs
  /// a schema change, a reset-registry entry and a guard update — which is how
  /// one eventually escapes Reset.
  final Map<String, int> acks;

  /// Every collectible earned. Stored in full rather than deriving from lesson
  /// completions, because the lesson id space has already been rewritten once
  /// on this project and a derived set would have silently revoked them.
  final Set<String> ownedCollectibles;

  /// Modules ever completed. A module that later grows stays complete.
  final Set<String> completedModules;

  /// Highest tree stage ever reached, read as `max(stored, derived)`.
  ///
  /// **The outcome, never the ingredients**: re-deriving the stage from the
  /// completed-lesson count ships the bug that growing the course shrinks a
  /// finished learner's tree. First completion writes here, raise-only; the
  /// read maxes it with what the *current* course implies (#150).
  final int treeStage;

  /// Brew challenges completed at least once.
  final Set<String> challengesCompleted;

  /// Dictionary terms whose source lesson has been completed.
  final Set<String> learnedTerms;

  /// Term id → when it was last answered wrong and last answered right.
  ///
  /// **Every answered term, not only the missed ones** (ADR-0022): a correct
  /// answer must write a key even for a term this device never saw missed,
  /// because a clear that cannot out-stamp the peer's miss never happens. The
  /// Misses deck is the subset whose miss is the later stamp.
  final Map<String, TermMiss> termAnswers;

  /// Challenge id → the reaction logged for it, most recent winning.
  final Map<String, ChallengeReaction> challengeReactions;

  /// Day → the completion events on it, as the free daily allowance counts
  /// them.
  ///
  /// Each entry is **one completion**, not one kind: a set keyed on type
  /// collapses two vocab rounds into one mark, and the cap must see two (#65).
  /// Pruned best-effort in [withActivity], since nothing reads beyond today.
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
  ClearedByReset withTreeStageAtLeast(int stage) =>
      _copy(treeStage: stage > treeStage ? stage : treeStage);

  /// A copy recording [entry] as a completion on [day], and marking the day
  /// active when [marksDay].
  ///
  /// Both halves are one event and both are unions, so a device that already
  /// knew either loses nothing. [dailyActivity] is **pruned here**, the only
  /// place it is rebuilt; [activeDays] never is — the streak folds them all.
  ClearedByReset withActivity(
    int day,
    String entry, {
    required bool marksDay,
  }) => _copy(
    dailyActivity: pruneDailyActivity({
      ...dailyActivity,
      day: {...?dailyActivity[day], entry},
    }, today: day),
    activeDays: marksDay ? {...activeDays, day} : activeDays,
  );

  /// A copy recording [lessonId] as first completed on [day], scoring
  /// [mastery].
  ///
  /// **Earliest day wins, result only rises** — as the merge's `min` and
  /// `MasteryResult.best` do. A local write that disagreed would date a
  /// completion later than it happened, or take back a run the learner had.
  ClearedByReset withLessonCompleted(
    String lessonId, {
    required int day,
    required MasteryResult mastery,
  }) {
    final first = completedLessons[lessonId];
    return _copy(
      completedLessons: {
        ...completedLessons,
        lessonId: first == null || day < first ? day : first,
      },
      bestResults: _bestResultsWith(lessonId, mastery),
    );
  }

  /// A copy with [mastery] folded into [lessonId]'s stored best.
  ///
  /// What a replay writes, and all it writes: it pays nothing and collects
  /// nothing, but it can lift a result. Raise-only, so a bad run never takes
  /// back a good one.
  ClearedByReset withBestResult(String lessonId, MasteryResult mastery) =>
      _copy(bestResults: _bestResultsWith(lessonId, mastery));

  /// [bestResults] with [mastery] folded in at [lessonId], never downgraded.
  Map<String, MasteryResult> _bestResultsWith(
    String lessonId,
    MasteryResult mastery,
  ) {
    final stored = bestResults[lessonId];
    return {
      ...bestResults,
      lessonId: stored == null ? mastery : MasteryResult.best(stored, mastery),
    };
  }

  /// A copy with the collectible [cardId] earned.
  ///
  /// A union, so collecting one already held changes nothing — which is what
  /// lets the module reward go without a ledger guarding it.
  ClearedByReset withCollectible(String cardId) =>
      _copy(ownedCollectibles: {...ownedCollectibles, cardId});

  /// Whether the one-off moment named [key] has been acknowledged.
  bool hasAck(String key) => acks.containsKey(key);

  /// A copy with [key] acknowledged on [day]. A deliberate monotonic add
  /// rather than a general `copyWith`, because every field here is monotonic
  /// and an arbitrary replace is exactly the operation this scope rules out.
  ClearedByReset withAck(String key, int day) =>
      _copy(acks: {...acks, key: day});

  /// A copy with the parked queue replaced by [saved].
  ///
  /// Last-writer-wins rather than a union, because removal is a first-class
  /// action here: unioning the queue would resurrect every challenge the
  /// learner ever dismissed, from any device that still remembered it.
  ClearedByReset withChallengesSaved(
    Set<String> saved, {
    required int at,
    required String writerId,
  }) => _copy(
    challengesSaved: Timestamped(
      value: saved,
      updatedAt: at,
      writerId: writerId,
    ),
  );

  /// A copy with the Saved shelf replaced by [favourites].
  ///
  /// Last-writer-wins rather than a union, for the reason recorded on the
  /// field: removal is a first-class action here, and unioning the shelf would
  /// resurrect every bookmark the learner ever took off, from any device that
  /// still remembered it.
  ClearedByReset withFavourites(
    Set<String> favourites, {
    required int at,
    required String writerId,
  }) => _copy(
    favourites: Timestamped(
      value: favourites,
      updatedAt: at,
      writerId: writerId,
    ),
  );

  /// A copy recording that [termId] was answered, right or wrong, at [at].
  ///
  /// The whole rule the Misses deck runs on: a wrong answer in any deck adds
  /// the term, a correct answer in any deck clears it, and nothing else
  /// touches the record — no decay and no cap.
  ClearedByReset withTermAnswered(
    String termId, {
    required bool correct,
    required int at,
  }) => _copy(
    termAnswers: {
      ...termAnswers,
      termId: (termAnswers[termId] ?? TermMiss.none).answered(
        correct: correct,
        at: at,
      ),
    },
  );

  /// A copy recording that [id] was logged with [reaction] on [day].
  ///
  /// Both halves move together because they are one event: the completion is
  /// what happened, the reaction is what it said. The completed set is a union
  /// — a brew never un-happens — while the reaction map keeps the newest
  /// answer per challenge, so a replay replaces what the last one said.
  ClearedByReset withChallengeLogged(
    String id, {
    required String reaction,
    required int day,
  }) => _copy(
    challengesCompleted: {...challengesCompleted, id},
    challengeReactions: {
      ...challengeReactions,
      id: ChallengeReaction(reaction: reaction, at: day),
    },
  );

  /// A copy with [challenge] as the one Coffee Challenge in play, or with none.
  ///
  /// Last-writer-wins, so the stamp travels with the value: only one challenge
  /// is ever active, and clearing it is a write in its own right rather than
  /// an absence — a challenge that has run out of time has to be able to say
  /// so to the other device.
  ClearedByReset withActiveChallenge(
    ActiveChallenge? challenge, {
    required int at,
    required String writerId,
  }) => _copy(
    activeChallenge: Timestamped(
      value: challenge,
      updatedAt: at,
      writerId: writerId,
    ),
  );

  /// The one hand-listed copy this scope needs: the *only* place fields are
  /// listed, and every writer above goes through it (#150/#104).
  ///
  /// ⚠️ **A parameter here makes its field replaceable**, so monotonicity
  /// stops being structural for it. Every writer that passes one must add,
  /// union or fold — never overwrite.
  ClearedByReset _copy({
    Map<String, int>? acks,
    Map<String, int>? completedLessons,
    Map<String, MasteryResult>? bestResults,
    Set<String>? ownedCollectibles,
    int? treeStage,
    Map<int, Set<String>>? dailyActivity,
    Set<int>? activeDays,
    Timestamped<ActiveChallenge?>? activeChallenge,
    Set<String>? challengesCompleted,
    Map<String, ChallengeReaction>? challengeReactions,
    Map<String, TermMiss>? termAnswers,
    Timestamped<Set<String>>? challengesSaved,
    Timestamped<Set<String>>? favourites,
  }) => ClearedByReset(
    completedLessons: completedLessons ?? this.completedLessons,
    bestResults: bestResults ?? this.bestResults,
    activeDays: activeDays ?? this.activeDays,
    acks: acks ?? this.acks,
    ownedCollectibles: ownedCollectibles ?? this.ownedCollectibles,
    completedModules: completedModules,
    treeStage: treeStage ?? this.treeStage,
    challengesCompleted: challengesCompleted ?? this.challengesCompleted,
    learnedTerms: learnedTerms,
    termAnswers: termAnswers ?? this.termAnswers,
    challengeReactions: challengeReactions ?? this.challengeReactions,
    dailyActivity: dailyActivity ?? this.dailyActivity,
    challengesSaved: challengesSaved ?? this.challengesSaved,
    activeChallenge: activeChallenge ?? this.activeChallenge,
    favourites: favourites ?? this.favourites,
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
    'termAnswers': termMissMapToJson(termAnswers),
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
          mapEquals(other.termAnswers, termAnswers) &&
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
    Object.hashAllUnordered(termAnswers.keys),
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
  /// Not [empty]: these fields merge last-writer-wins, and [empty]'s epoch
  /// stamp loses to any grove the peer still holds. The stamp is one past the
  /// newest write [current] holds, because the wall clock is not the maximum.
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

  /// A copy with [planted] as the grove, stamped so a peer holding an older
  /// pick loses to it.
  ///
  /// Last-writer-wins, like everything in this scope: two devices cannot both
  /// be right about which plant is in the ground, and the newer choice is the
  /// one the learner made most recently.
  ClearedByDeleteOnly withGrove(
    Grove planted, {
    required int at,
    required String writerId,
  }) => ClearedByDeleteOnly(
    grove: Timestamped(value: planted, updatedAt: at, writerId: writerId),
    companion: companion,
    unknown: unknown,
  );

  /// A copy with [dressed] as the outfit, stamped so a peer holding an older
  /// pick loses to it.
  ///
  /// Last-writer-wins, like the grove beside it: two devices cannot both be
  /// right about what Roasty is wearing.
  ClearedByDeleteOnly withCompanion(
    CompanionConfig dressed, {
    required int at,
    required String writerId,
  }) => ClearedByDeleteOnly(
    grove: grove,
    companion: Timestamped(value: dressed, updatedAt: at, writerId: writerId),
    unknown: unknown,
  );

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
