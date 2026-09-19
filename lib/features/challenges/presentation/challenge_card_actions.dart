/// What the challenge card's two actions write: parking a brew for later, and
/// logging one.
library;

import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_log_sheet.dart';
import 'package:brew_path/features/challenges/presentation/challenge_recap_sheet.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Takes [challenge] off Today and puts it in the queue.
Future<void> parkChallengeForLater(
  WidgetRef ref,
  BrewChallenge challenge,
) async {
  await saveActiveChallengeForLater(
    ref.read(snapshotRepositoryProvider),
    id: challenge.id,
    now: DateTime.now(),
  );
  ref
    ..invalidate(activeChallengeProvider)
    ..invalidate(savedChallengesProvider);
}

/// Logs the brew, then celebrates it and offers to run it again.
///
/// Dismissing the log sheet resolves null and writes nothing — looking is
/// free, and only a picked outcome is a claim that the brew happened.
Future<void> runChallengeLogFlow(
  BuildContext context,
  WidgetRef ref,
  BrewChallenge challenge,
) async {
  final result = await showChallengeLogSheet(
    context: context,
    challenge: challenge,
  );
  if (result == null || !context.mounted) return;

  if (result is ChallengeSavedForLater) {
    await parkChallengeForLater(ref, challenge);
    return;
  }

  final points = await logChallenge(
    ref.read(snapshotRepositoryProvider),
    id: challenge.id,
    reaction: (result as ChallengeLogged).reaction,
    now: DateTime.now(),
  );
  if (!context.mounted) return;

  ref
    ..invalidate(activeChallengeProvider)
    ..invalidate(completedChallengesProvider)
    ..invalidate(savedChallengesProvider)
    ..invalidate(totalPointsProvider);

  final choice = await showChallengeRecapSheet(
    context: context,
    challenge: challenge,
    pointsAwarded: points,
  );
  if (choice != ChallengeRecapChoice.brewAgain || !context.mounted) return;

  await startChallenge(
    ref.read(snapshotRepositoryProvider),
    id: challenge.id,
    now: DateTime.now(),
  );
  ref
    ..invalidate(activeChallengeProvider)
    ..invalidate(savedChallengesProvider);
}
