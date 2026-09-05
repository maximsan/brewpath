import 'dart:async';

import 'package:brew_path/core/widgets/reward_row.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The last `·`-separated part of an effort line, which is where the design
/// keeps the time — `Two cups · 5 min` reads as *(5 min)* beside the title.
///
/// Lowercased, because the row writes it inside a sentence rather than as a
/// label. Returns the whole string when there is no separator, so an effort
/// authored as a bare duration still says something.
String challengeEffortTime(String effort) =>
    effort.split('·').last.trim().toLowerCase();

/// How a reward list writes an offer's detail: what it is, and how long.
String challengeOfferDetail(BrewChallenge challenge) =>
    '${challenge.title} (${challengeEffortTime(challenge.effort)})';

/// Offers a Coffee Challenge as one row of a reward list.
///
/// **A row, not a card of its own.** It is one of the occasional beats an
/// ending reports, so it takes the same anatomy as the freeze and the new
/// card: a label, a quiet detail, one affordance.
///
/// **There is no decline.** Declining is continuing past the row — the
/// challenge waits on the Path either way, so the go button is the row's one
/// affordance and the screen's own way out is the not-now. That retires the
/// offer's *Save for later*: parking something never started was this screen's
/// own idea, and the design does not ask the learner to make that choice here.
/// Parking a challenge already **in play** is untouched — that is the log
/// sheet's *Save for later* on Today, which is a different act.
///
/// Whether there is an offer at all is [lessonChallengeOfferProvider]'s
/// question, asked by whoever builds the list — a row that decided its own
/// absence would still take a hairline from the row above it.
class ChallengeSuggestion extends ConsumerStatefulWidget {
  /// Creates a [ChallengeSuggestion].
  const ChallengeSuggestion({required this.challenge, super.key});

  /// What the row is called before it is taken up.
  static const String offerLabel = 'Optional challenge';

  /// What it says once it has been — the design's one sentence, not a label
  /// with a line under it: there is nothing left to act on, so the row has
  /// nothing to name and explain separately.
  static const String acceptedLabel = 'Added to Today — log it when you brew.';

  /// The challenge on offer.
  final BrewChallenge challenge;

  @override
  ConsumerState<ChallengeSuggestion> createState() =>
      _ChallengeSuggestionState();
}

class _ChallengeSuggestionState extends ConsumerState<ChallengeSuggestion> {
  /// Whether the offer has been taken up, so the row can confirm it without
  /// the screen navigating away from the celebration it is showing.
  bool _accepted = false;

  Future<void> _start() async {
    if (_accepted) return;
    setState(() => _accepted = true);
    await startChallenge(
      ref.read(snapshotRepositoryProvider),
      id: widget.challenge.id,
      now: DateTime.now(),
    );
    ref
      ..invalidate(activeChallengeProvider)
      ..invalidate(savedChallengesProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted) {
      return const RewardRow(label: ChallengeSuggestion.acceptedLabel);
    }
    return RewardRow(
      label: ChallengeSuggestion.offerLabel,
      detail: challengeOfferDetail(widget.challenge),
      onPress: () => unawaited(_start()),
    );
  }
}
