import 'dart:async';

import 'dart:math' as math;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/swipe/horizontal_swipe.dart';
import 'package:brew_path/core/swipe/swipe_geometry.dart';
import 'package:brew_path/core/swipe/swipe_hint.dart';
import 'package:brew_path/core/swipe/swipe_hint_caption.dart';
import 'package:brew_path/core/swipe/swipe_surface.dart';
import 'package:brew_path/core/widgets/focus_revealed_button.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/presentation/challenge_card_actions.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_chevron.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_geometry.dart';
import 'package:brew_path/features/challenges/presentation/challenge_park_track.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _cardRadius = 12;
const double _iconSm = 18;

/// The design's `right: 9` on the chevron inside the card.
const double _chevronInset = 9;

/// The room the card's words leave for it. The chevron sits over the card at
/// its vertical middle, which is where the instruction's last line runs; a
/// glyph across the words it is meant to invite is worse than no glyph.
const double _chevronClearance = _chevronInset + ChallengeParkChevron.width;

/// The Coffee Challenge in play, on Today.
///
/// A **sibling** of the day's lesson card rather than a state of it. The two
/// answer different questions — what to learn next, and what to go and brew —
/// and a learner can have both at once.
class ActiveChallengeCard extends ConsumerStatefulWidget {
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

  /// The gesture's keyboard equivalent, in the design's own words.
  static const String _parkLabel = 'Save for later';

  /// The ring the focused control wears — the design's accent share.
  static const double _ringShare = 0.30;

  /// The challenge currently in play.
  final BrewChallenge challenge;

  @override
  ConsumerState<ActiveChallengeCard> createState() =>
      _ActiveChallengeCardState();
}

class _ActiveChallengeCardState extends ConsumerState<ActiveChallengeCard> {
  /// Whether the card has parked and is waiting for Today to let it go.
  ///
  /// The queue write lands a frame or more after the flight does, and the
  /// swipe springs its content home to wait — so without this the card that
  /// just left would sit back at centre until the store answered.
  bool _parked = false;

  @override
  void didUpdateWidget(ActiveChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.id != widget.challenge.id) _parked = false;
  }

  /// Parks the challenge, and retires the hint that taught the gesture.
  ///
  /// One place, because every way to park — the swipe, the focus-revealed
  /// control — owes both halves.
  void _park(SwipeHintState hint) {
    hint.markUsed();
    setState(() => _parked = true);
    unawaited(parkChallengeForLater(ref, widget.challenge));
  }

  @override
  Widget build(BuildContext context) {
    if (_parked) return const SizedBox.shrink();

    return SwipeHint(
      surface: SwipeSurface.challenge,
      nudge: challengeParkNudge,
      builder: (context, hint) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HorizontalSwipe(
            motion: ActiveChallengeCard._motion,
            // Left has nowhere to go, so it damps rather than moving.
            canAdvance: false,
            onBack: () => _park(hint),
            behind: (context, drag) => ChallengeParkTrack(
              offset: math.max(drag.offset, hint.offset),
              radius: _cardRadius,
            ),
            builder: (context, drag) => SwipeNudge(
              offset: hint.offset,
              child: _card(context, hint),
            ),
          ),
          SwipeHintCaption(
            show: hint.showing,
            aim: SwipeAim.back,
            label: ActiveChallengeCard._hint,
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, SwipeHintState hint) {
    final challenge = widget.challenge;
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
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                top: AppSpacing.md,
                bottom: AppSpacing.md,
                right: _chevronClearance,
              ),
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
                      onPressed: () => unawaited(
                        runChallengeLogFlow(context, ref, challenge),
                      ),
                      child: const Text('Log Result'),
                    ),
                  ),
                  FocusRevealedButton(
                    label: ActiveChallengeCard._parkLabel,
                    // `color-mix(in oklab, var(--accent) 30%, var(--rule))`.
                    ring: Color.lerp(
                      mood.rule,
                      mood.accent,
                      ActiveChallengeCard._ringShare,
                    )!,
                    onPressed: () => _park(hint),
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
    '${widget.challenge.title}.',
    widget.challenge.instruction,
    ?effort.trigger,
    ?effort.duration,
  ].join(' ');
}
