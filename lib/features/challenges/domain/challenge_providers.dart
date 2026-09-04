import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/challenges/domain/card_challenge_state.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_completion.dart';
import 'package:brew_path/features/challenges/domain/challenge_lifecycle.dart';
import 'package:brew_path/features/challenges/domain/challenge_parking.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_providers.g.dart';

/// The twelve Coffee Challenges.
@riverpod
Future<List<BrewChallenge>> challengeBank(Ref ref) =>
    ref.watch(contentRepositoryProvider).getBrewChallenges();

/// The challenge Today should show, or null when nothing is in play.
///
/// A lapsed window stops showing here and stores nothing — clearing the pair
/// and parking the challenge is the expiry path's write, not a read's side
/// effect.
@riverpod
Future<BrewChallenge?> activeChallenge(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap, where the old build's ref is
  // already disposed.
  final snapshots = ref.watch(snapshotRepositoryProvider);
  final bank = ref.watch(challengeBankProvider.future);
  final nowMillis = DateTime.now().millisecondsSinceEpoch;

  final stored = (await snapshots.read()).clearedByReset.activeChallenge.value;
  final id = liveChallengeId(stored, nowMillis: nowMillis);
  return id == null ? null : challengeById(await bank, id);
}

/// Every challenge the learner has logged at least once.
@riverpod
Future<Set<String>> completedChallenges(Ref ref) async {
  final snapshots = ref.watch(snapshotRepositoryProvider);
  return (await snapshots.read()).clearedByReset.challengesCompleted;
}

/// What [cardId]'s challenge is doing, as a tile shows it.
///
/// Three states, not two: a card can have no challenge at all, one waiting to
/// be brewed, or one already brewed. The tile draws the last two differently —
/// solid for done, dashed for an offer — so it needs to tell them apart, and
/// the arithmetic lives here rather than in the widget.
///
/// **Every unbrewed challenge is an offer**, not only the one currently in
/// play. The design's `challengeOpen` (`screens.jsx:1621`) is *earned, has a
/// challenge, has not completed it* — so a learner sees every card that still
/// owes them a brew, rather than the single one the lifecycle happens to have
/// active. Reading the active challenge here would ring at most one tile and
/// would blink off when its window lapsed.
@riverpod
Future<CardChallengeState> cardChallengeState(Ref ref, String cardId) async {
  if (await ref.watch(cardChallengeTriedProvider(cardId).future)) {
    return CardChallengeState.tried;
  }

  final bank = await ref.watch(challengeBankProvider.future);
  return challengeForCard(bank, cardId) == null
      ? CardChallengeState.none
      : CardChallengeState.open;
}

/// Whether the challenge on [cardId] has been brewed.
///
/// The card's sheet asks this twice over — once for the seal on its header,
/// once for the stamp block at its foot — so the three reads behind the answer
/// live here rather than in either widget. A card with no challenge, or a bank
/// still loading, answers *not tried*: the honest reading while there is
/// nothing to say yes about.
@riverpod
Future<bool> cardChallengeTried(Ref ref, String cardId) async {
  final bank = await ref.watch(challengeBankProvider.future);
  final challenge = challengeForCard(bank, cardId);
  if (challenge == null) return false;

  final completed = await ref.watch(completedChallengesProvider.future);
  return completed.contains(challenge.id);
}

/// Whether [challenge] has been earned by the learner's own progress.
Future<bool> _isOfferable(
  BrewChallenge challenge,
  ContentRepository content,
  Set<String> completedLessonIds,
) async {
  final modules = await content.getModules();
  final module = modules.where((m) => m.id == challenge.moduleId).firstOrNull;
  if (module == null) return false;

  return challengeOfferable(
    challenge: challenge,
    moduleLessonIds: module.lessonIds.toSet(),
    completedLessonIds: completedLessonIds,
  );
}

/// The challenges waiting in the saved queue, in bank order.
///
/// Excludes whatever is in play and anything already logged, and drops any
/// challenge whose lesson the learner has not reached — a queue advertising
/// work locked behind content is worse than an empty one.
@riverpod
Future<List<BrewChallenge>> savedChallenges(Ref ref) async {
  final snapshots = ref.watch(snapshotRepositoryProvider);
  final content = ref.watch(contentRepositoryProvider);
  final progressRepo = ref.watch(progressRepositoryProvider);
  final bank = await ref.watch(challengeBankProvider.future);
  final nowMillis = DateTime.now().millisecondsSinceEpoch;

  final progress = (await snapshots.read()).clearedByReset;
  final completedLessons = await progressRepo.getAllCompleted();
  final completedLessonIds = {
    for (final record in completedLessons) record.lessonId,
  };

  final offerable = <String>{};
  for (final challenge in bank) {
    if (await _isOfferable(challenge, content, completedLessonIds)) {
      offerable.add(challenge.id);
    }
  }

  final visible = visibleSavedChallenges(
    saved: progress.challengesSaved.value,
    activeId: liveChallengeId(
      progress.activeChallenge.value,
      nowMillis: nowMillis,
    ),
    completed: progress.challengesCompleted,
    bankOrder: [for (final challenge in bank) challenge.id],
    isOfferable: offerable.contains,
  );
  return [for (final id in visible) challengeById(bank, id)!];
}

/// The capstone [moduleId] offers, or null when it has none or is unearned.
@riverpod
Future<BrewChallenge?> moduleChallengeOffer(Ref ref, String moduleId) async {
  final content = ref.watch(contentRepositoryProvider);
  final progress = ref.watch(progressRepositoryProvider);
  final bank = await ref.watch(challengeBankProvider.future);

  final challenge = challengeForModule(bank, moduleId);
  if (challenge == null) return null;

  final completed = await progress.getAllCompleted();
  final offerable = await _isOfferable(
    challenge,
    content,
    {for (final record in completed) record.lessonId},
  );
  return offerable ? challenge : null;
}

/// The capstone [moduleId] is offering **right now**, or null.
///
/// A reward screen shows the offer only while it is live — the design's
/// `offerLive`: the challenge is neither in play nor already brewed. A saved
/// challenge is still live; parking it was the learner saying *not yet*.
///
/// Eligibility is not re-derived here. [moduleChallengeOfferProvider] owns the
/// gate — a module challenge needs its module's every lesson complete (#143) —
/// and this only narrows what that gate returns.
@riverpod
Future<BrewChallenge?> liveModuleChallengeOffer(
  Ref ref,
  String moduleId,
) async {
  // Every watch resolved before the first await, as the rest of this file
  // does: a rebuild mid-flight must not find a watch on the far side of an
  // async gap, where the old build's ref is already disposed.
  final offer = ref.watch(moduleChallengeOfferProvider(moduleId).future);
  final activeChallenge = ref.watch(activeChallengeProvider.future);
  final completed = ref.watch(completedChallengesProvider.future);

  final challenge = await offer;
  if (challenge == null) return null;

  if ((await activeChallenge)?.id == challenge.id) return null;
  return (await completed).contains(challenge.id) ? null : challenge;
}

/// Puts [id] in play, parking whatever it displaced.
///
/// Returns the challenge that was pushed out, if any. Starting a second
/// challenge is not a way to abandon the first: the learner asked for it, so
/// it goes into the queue rather than out of existence. Taking [id] itself out
/// of the queue is part of the same write — a challenge cannot be both waiting
/// and in play.
Future<String?> startChallenge(
  SnapshotRepository repository, {
  required String id,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final progress = snapshot.clearedByReset;
  final at = now.millisecondsSinceEpoch;

  final start = startChallengeTransition(
    id: id,
    current: progress.activeChallenge.value,
    completed: progress.challengesCompleted,
    nowMillis: at,
  );

  var saved = unparkChallenge(progress.challengesSaved.value, id);
  final displaced = start.displaced;
  if (displaced != null) saved = parkChallenge(saved, displaced);

  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByReset: progress
          .withChallengesSaved(saved, at: at, writerId: snapshot.deviceId)
          .withActiveChallenge(
            start.active,
            at: at,
            writerId: snapshot.deviceId,
          ),
    ),
  );
  return displaced;
}

/// Parks the challenge in play for later, clearing Today.
///
/// "Save for later" is not a penalty and not an archive — it is the learner
/// saying *not now*, which the queue is for.
Future<void> saveActiveChallengeForLater(
  SnapshotRepository repository, {
  required String id,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final progress = snapshot.clearedByReset;
  final at = now.millisecondsSinceEpoch;

  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByReset: progress
          .withChallengesSaved(
            parkChallenge(progress.challengesSaved.value, id),
            at: at,
            writerId: snapshot.deviceId,
          )
          .withActiveChallenge(null, at: at, writerId: snapshot.deviceId),
    ),
  );
}

/// Parks [id] for later without touching whatever is in play.
///
/// The lesson-complete offer's *Save for later*: the learner is parking a
/// challenge they never started, so clearing Today would throw away a
/// different challenge they are part-way through.
Future<void> saveChallengeForLater(
  SnapshotRepository repository, {
  required String id,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final progress = snapshot.clearedByReset;
  final at = now.millisecondsSinceEpoch;

  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByReset: progress.withChallengesSaved(
        parkChallenge(progress.challengesSaved.value, id),
        at: at,
        writerId: snapshot.deviceId,
      ),
    ),
  );
}

/// Takes [id] out of the queue entirely.
Future<void> unsaveChallenge(
  SnapshotRepository repository, {
  required String id,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final progress = snapshot.clearedByReset;
  final at = now.millisecondsSinceEpoch;

  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByReset: progress.withChallengesSaved(
        unparkChallenge(progress.challengesSaved.value, id),
        at: at,
        writerId: snapshot.deviceId,
      ),
    ),
  );
}

/// Parks a challenge whose window has run out, and clears the stale pair.
///
/// **Writes nothing when nothing has lapsed**, which is what lets this run on
/// every app open and resume without churning the stamp. Fixes the defect the
/// design shipped: the pair was never cleared, so a challenge that expired
/// months ago would keep syncing between devices as the active one forever.
Future<bool> parkExpiredChallenge(
  SnapshotRepository repository, {
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final progress = snapshot.clearedByReset;
  final at = now.millisecondsSinceEpoch;

  final park = expiryPark(
    active: progress.activeChallenge.value,
    saved: progress.challengesSaved.value,
    completed: progress.challengesCompleted,
    nowMillis: at,
  );
  if (park == null) return false;

  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByReset: progress
          .withChallengesSaved(
            park.saved,
            at: at,
            writerId: snapshot.deviceId,
          )
          .withActiveChallenge(
            park.active,
            at: at,
            writerId: snapshot.deviceId,
          ),
    ),
  );
  return true;
}

/// Records that [id] was brewed, with the outcome the learner reported.
///
/// One write. The completion, the reaction and clearing the active pair are a
/// single event, so they land together or not at all — a challenge recorded as
/// done while still sitting on Today is a state nothing else knows how to read.
///
/// Returns the points paid: the flat award on a first completion, and zero on
/// every replay.
///
/// **Records nothing toward the streak or the daily allowance.** A Coffee
/// Challenge is not an activity — its completion can be reported without the
/// app being able to tell — and that exclusion is structural rather than a
/// branch that could be forgotten here.
Future<int> logChallenge(
  SnapshotRepository repository, {
  required String id,
  required String reaction,
  required DateTime now,
}) async {
  final snapshot = await repository.read();
  final progress = snapshot.clearedByReset;
  final payout = challengePayout(
    id: id,
    completed: progress.challengesCompleted,
  );
  final at = now.millisecondsSinceEpoch;

  await repository.write(
    snapshot.copyWith(
      updatedAt: at,
      clearedByReset: progress
          .withChallengeLogged(id, reaction: reaction, day: epochDay(now))
          .withChallengesSaved(
            unparkChallenge(progress.challengesSaved.value, id),
            at: at,
            writerId: snapshot.deviceId,
          )
          .withActiveChallenge(null, at: at, writerId: snapshot.deviceId),
    ),
  );

  // The payout is not banked anywhere: a logged challenge's id in the
  // completed set above *is* the record, and the total is summed off it.
  return payout;
}
