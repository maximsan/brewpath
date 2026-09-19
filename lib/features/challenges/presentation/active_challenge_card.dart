import 'dart:async';

import 'dart:math' as math;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/swipe/horizontal_swipe.dart';
import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/core/swipe/swipe_hint.dart';
import 'package:brew_path/core/swipe/swipe_hint_caption.dart';
import 'package:brew_path/core/swipe/swipe_surface.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/challenge_log_sheet.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_controls.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_geometry.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_track.dart';
import 'package:brew_path/features/challenges/presentation/challenge_recap_sheet.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _cardRadius = 12;
const double _iconSm = 18;

/// The design's `right: 9` on the chevron inside the card.
const double _chevronInset = 9;

/// The Coffee Challenge in play, on Today.
///
/// A **sibling** of the day's lesson card rather than a state of it. The two
/// answer different questions — what to learn next, and what to go and brew —
/// and a learner can have both at once.
class ActiveChallengeCard extends ConsumerWidget {
  /// Creates an [ActiveChallengeCard].
  const ActiveChallengeCard({required this.challenge, super.key});

  /// The card parks rather than advances, and it leaves by flying off.
  static const SwipeMotion _motion = SwipeMotion(
    commitThreshold: challengeParkAt,
    maxDrag: challengeParkMaxDrag,
    exitDistance: challengeParkExit,
    exitDuration: challengeParkExitDuration,
  );

  /// The first-run hint's words.
  static const String _hint = 'Slide the card aside to save it for later';

  /// The challenge currently in play.
  final BrewChallenge challenge;

  /// Takes the challenge off Today and puts it in the queue.
  Future<void> _park(WidgetRef ref) async {
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
  Future<void> _log(BuildContext context, WidgetRef ref) async {
    final result = await showChallengeLogSheet(
      context: context,
      challenge: challenge,
    );
    if (result == null || !context.mounted) return;

    if (result is ChallengeSavedForLater) {
      await _park(ref);
      return;
    }

    final reaction = (result as ChallengeLogged).reaction;
    final points = await logChallenge(
      ref.read(snapshotRepositoryProvider),
      id: challenge.id,
      reaction: reaction,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) => SwipeHint(
    surface: SwipeSurface.challenge,
    nudge: challengeParkNudge,
    builder: (context, hint) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HorizontalSwipe(
          motion: _motion,
          // Left has nowhere to go, so it damps rather than moving.
          canAdvance: false,
          onBack: () {
            hint.markUsed();
            unawaited(_park(ref));
          },
          behind: (context, drag) => ChallengeParkTrack(
            offset: math.max(drag.offset, hint.offset),
            radius: _cardRadius,
          ),
          builder: (context, drag) => SwipeNudge(
            offset: hint.offset,
            child: _card(context, ref, hint),
          ),
        ),
        SwipeHintCaption(
          show: hint.showing,
          aim: SwipeAim.back,
          label: _hint,
        ),
      ],
    ),
  );

  Widget _card(BuildContext context, WidgetRef ref, SwipeHintState hint) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final effort = effortParts(challenge.effort);

    return Semantics(
      container: true,
      label: _semanticsLabel(effort),
      child: Card(
        margin: EdgeInsets.zero,
        color: mood.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: mood.rule),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _eyebrow(theme, mood),
                  const SizedBox(height: AppSpacing.xs),
                  // One step below a lesson title, because the challenge is
                  // optional — the design added this rung rather than let the
                  // two read as equals.
                  Text(challenge.title, style: AppText.subtitle(mood: mood)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    challenge.instruction,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mood.inkMute,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _effortLine(theme, mood, effort),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    // Deliberately not full width — an action on a card, sized
                    // to its label rather than the screen.
                    child: FilledButton(
                      onPressed: () => _log(context, ref),
                      child: const Text('Log Result'),
                    ),
                  ),
                  ChallengeParkButton(
                    onPark: () {
                      hint.markUsed();
                      unawaited(_park(ref));
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: _chevronInset,
              child: Center(
                child: ChallengeParkChevron(
                  hinting: hint.showing,
                  used: hint.used,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eyebrow(ThemeData theme, MoodColors mood) => Row(
    children: [
      IconMark(AppIcon.cup, size: _iconSm, color: mood.accent),
      const SizedBox(width: AppSpacing.xxs),
      Text(
        'COFFEE CHALLENGE',
        style: theme.textTheme.labelSmall?.copyWith(
          color: mood.accentText,
        ),
      ),
    ],
  );

  Widget _effortLine(
    ThemeData theme,
    MoodColors mood,
    ChallengeEffort effort,
  ) => Text(
    [
      ?effort.trigger,
      ?effort.duration,
    ].join(' · '),
    style: theme.textTheme.labelMedium?.copyWith(color: mood.inkMute),
  );

  String _semanticsLabel(ChallengeEffort effort) => [
    'Coffee Challenge.',
    '${challenge.title}.',
    challenge.instruction,
    ?effort.trigger,
    ?effort.duration,
  ].join(' ');
}
