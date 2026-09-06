import 'dart:math';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/term_miss.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';

/// Seeded generator for random-but-plausible snapshots.
///
/// Hand-rolled rather than pulled from a package. The merge is **field-wise**,
/// so the algebraic laws compose: prove each operator is a semilattice
/// operation and the snapshot-level law follows. That makes every generator one
/// field wide, so a failure already names the broken field — which is most of
/// what a property-testing library's shrinking would have bought.
///
/// **The pools are deliberately tiny.** Ids collide, days collide and — most
/// importantly — timestamps collide, because the interesting cases are exactly
/// the ones where two devices touched the same key. Widening the pools makes
/// the generator look thorough while testing almost nothing.
class SnapshotGen {
  /// Creates a generator. The same [seed] always produces the same sequence,
  /// so a failure is reproducible from the message alone.
  SnapshotGen(int seed) : _rng = Random(seed);

  final Random _rng;

  static const _lessons = ['m1l1', 'm1l2', 'm1l3', 'm1l4'];
  static const _collectibles = ['c1', 'c2', 'c3'];
  static const _modules = ['m1', 'm2'];
  static const _challenges = ['bc-m1', 'bc-m1l1'];
  static const _terms = ['arabica', 'robusta', 'crema'];
  static const _games = ['g-match', 'g-quiz', 'g-flavor'];
  static const _ackKeys = ['freezeNotice', 'milestone', 'courseComplete'];
  static const _devices = ['device-a', 'device-b'];
  static const _varieties = ['arabica', 'robusta', 'liberica'];
  static const _lights = ['daylight', 'moonlit'];

  /// Only three distinct stamps, so equal-timestamp ties — the case the device
  /// tie-break exists for — are hit constantly rather than never.
  static const _stamps = [1000, 2000, 3000];

  static const _dayRange = 6;

  /// Tiny on purpose: entries must repeat across two generated snapshots.
  static const _tokenPool = 4;
  static const _maxTreeStage = 10;
  static const _maxGraded = 7;
  static const _maxGeneration = 3;

  /// A whole snapshot.
  ProgressSnapshot snapshot() => ProgressSnapshot(
    updatedAt: _pick(_stamps),
    deviceId: _pick(_devices),
    resetGeneration: _rng.nextInt(_maxGeneration),
    clearedByReset: progress(),
    clearedByDeleteOnly: account(),
    unknown: _rng.nextBool() ? {'futureField': _rng.nextInt(100)} : const {},
  );

  /// The progress-scoped fields.
  ClearedByReset progress() => ClearedByReset(
    completedLessons: _dayMap(_lessons),
    bestResults: _bestResults(),
    activeDays: _days(),
    acks: _dayMap(_ackKeys),
    ownedCollectibles: _subset(_collectibles),
    completedModules: _subset(_modules),
    treeStage: _rng.nextInt(_maxTreeStage + 1),
    challengesCompleted: _subset(_challenges),
    learnedTerms: _subset(_terms),
    missedTerms: _misses(),
    challengeReactions: _reactions(),
    dailyActivity: _dailyActivity(),
    challengesSaved: _stampedSet(_challenges),
    activeChallenge: _stampedChallenge(),
    favourites: _stampedSet(_lessons.map((id) => 'l:$id').toList()),
    unknown: _futureKeys(),
  );

  /// The account-scoped fields.
  ClearedByDeleteOnly account() => ClearedByDeleteOnly(
    grove: Timestamped(
      value: Grove(variety: _pick(_varieties), light: _pick(_lights)),
      updatedAt: _pick(_stamps),
      writerId: _pick(_devices),
    ),
    companion: Timestamped(
      value: CompanionConfig(
        roast: _pick(const ['light', 'medium', 'dark']),
        hat: _pick(const ['none', 'field']),
        gear: _pick(const ['none', 'glasses']),
        sprout: _pick(const ['leaf', 'flower']),
      ),
      updatedAt: _pick(_stamps),
      writerId: _pick(_devices),
    ),
    unknown: _futureKeys(),
  );

  /// Keys a newer build might have written. Small pool so two snapshots collide
  /// on the same key with different values — the case that has to converge.
  Map<String, dynamic> _futureKeys() => {
    if (_rng.nextBool()) 'futureFlag': _rng.nextBool(),
    if (_rng.nextBool()) 'futureCount': _rng.nextInt(3),
  };

  T _pick<T>(List<T> from) => from[_rng.nextInt(from.length)];

  Set<T> _subset<T>(List<T> from) => {
    for (final item in from)
      if (_rng.nextBool()) item,
  };

  Set<int> _days() => {
    for (var day = 0; day < _dayRange; day++)
      if (_rng.nextBool()) day,
  };

  Map<String, int> _dayMap(List<String> keys) => {
    for (final key in keys)
      if (_rng.nextBool()) key: _rng.nextInt(_dayRange),
  };

  Map<String, MasteryResult> _bestResults() => {
    for (final id in _lessons)
      if (_rng.nextBool())
        id: () {
          final total = 1 + _rng.nextInt(_maxGraded);
          return MasteryResult(correct: _rng.nextInt(total + 1), total: total);
        }(),
  };

  /// Answer stamps over the same tiny term pool, drawn from the same three
  /// stamps as everything else — so two generated snapshots collide on a term
  /// with a miss on one side and a clear on the other, which is the only case
  /// the per-stamp join has to get right.
  Map<String, TermMiss> _misses() => {
    for (final id in _terms)
      if (_rng.nextBool())
        id: TermMiss(
          lastMissedAt: _rng.nextBool() ? _pick(_stamps) : 0,
          lastCorrectAt: _rng.nextBool() ? _pick(_stamps) : 0,
        ),
  };

  Map<String, ChallengeReaction> _reactions() => {
    for (final id in _challenges)
      if (_rng.nextBool())
        id: ChallengeReaction(
          reaction: _pick(const ['Sharper', 'Sweeter', 'No change']),
          at: _rng.nextInt(_dayRange),
        ),
  };

  /// Days of completion events, in the real encoding.
  ///
  /// Tokens come from the seeded generator over a deliberately tiny pool, for
  /// the same reason the ids and days do: two generated snapshots must share
  /// entries, or the union merge is never tested against anything to union.
  /// Minting real tokens here would make every entry globally unique and the
  /// merge laws vacuous over this field.
  Map<int, Set<String>> _dailyActivity() => {
    for (var day = 0; day < _dayRange; day++)
      if (_rng.nextBool())
        day: {
          for (final game in _subset(_games))
            activityEntry(
              type: ActivityType.miniGame,
              token: _token(),
              subject: game,
            ),
          if (_rng.nextBool())
            activityEntry(type: ActivityType.vocab, token: _token()),
        },
  };

  /// One of a handful of tokens, so repeats are common.
  String _token() => 't${_rng.nextInt(_tokenPool)}';

  Timestamped<Set<String>> _stampedSet(List<String> pool) => Timestamped(
    value: _subset(pool),
    updatedAt: _pick(_stamps),
    writerId: _pick(_devices),
  );

  Timestamped<ActiveChallenge?> _stampedChallenge() => Timestamped(
    value: _rng.nextBool()
        ? ActiveChallenge(id: _pick(_challenges), startedAt: _pick(_stamps))
        : null,
    updatedAt: _pick(_stamps),
    writerId: _pick(_devices),
  );
}
