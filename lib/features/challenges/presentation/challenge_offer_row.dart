import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/features/challenges/presentation/challenge_suggestion.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The Coffee Challenge offer, as one row of a reward screen.
///
/// The app's port of the design's `ChallengeSuggestion`. It is not the only
/// one yet: the lesson ending still runs [ChallengeSuggestion], an older
/// bordered card with its own *Save for later*, and converging the two onto
/// this row is #490's job rather than this one's. Until then the confirmation
/// sentence and the write exist in both places, deliberately.
///
/// **One affordance, and no way to say no.** The design gives the row a go
/// button and nothing else: declining is walking past it, because the challenge
/// waits on the Path either way. That is why there is no *not now* here — a
/// dismissal would have to mean something, and there is nothing for it to mean.
///
/// **The row is the button**, not the circle inside it — the anatomy every
/// actionable reward row shares (*"Span, not button: the row itself is the
/// button"*). The design's own offer wires the tap to the 38-px circle alone,
/// which is under every platform's minimum touch target; the row is well over
/// it and the circle still reads as the affordance.
class ChallengeOfferRow extends StatelessWidget {
  /// Creates a [ChallengeOfferRow].
  const ChallengeOfferRow({
    required this.challenge,
    required this.onStart,
    super.key,
  });

  /// The challenge being offered.
  final BrewChallenge challenge;

  /// Puts it in play.
  final VoidCallback onStart;

  /// What the offer is, before what it asks for.
  static const String kicker = 'Optional challenge';

  /// How the row's action is announced.
  static const String startAction = 'Start challenge';

  /// The design's accent go button — `width: 38, height: 38,
  /// borderRadius: 999`.
  static const double _goSize = 38;

  /// The arrow inside it — `<svg width="16" height="16">`.
  static const double _goGlyph = 16;

  /// The title, with how long the brew takes after it.
  ///
  /// The design prints `{title} ({time.toLowerCase()})`, taking the time from
  /// the second half of the effort string. A record that authored only one half
  /// has no time to print, and the title stands alone rather than trailing an
  /// empty bracket.
  String get _detail {
    final duration = effortParts(challenge.effort).duration;
    return duration == null
        ? challenge.title
        : '${challenge.title} (${duration.toLowerCase()})';
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: '$kicker. $_detail. $startAction',
      excludeSemantics: true,
      child: InkWell(
        onTap: onStart,
        child: Padding(
          // The design trims this row to `padding: 10px 0` — tighter than a
          // plain one, because the go button sets the height instead. Snapped
          // to the nearest stop, keeping it tighter than the plain row below.
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kicker,
                      style: AppText.support(
                        mood: mood,
                        color: mood.ink,
                        face: AppFace.control,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.support(mood: mood, color: mood.inkMute),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: _goSize,
                height: _goSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mood.accent,
                  shape: BoxShape.circle,
                ),
                child: IconMark(
                  AppIcon.arrow,
                  size: _goGlyph,
                  color: mood.accentInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the offer row becomes once the challenge is in play.
///
/// It stays on the screen rather than navigating: the ending is celebrating
/// something, and its own action is what leaves. The learner is told where the
/// challenge went, and the day's own name is set in the design's bold so the
/// destination is the part that reads.
class ChallengeStartedRow extends StatelessWidget {
  /// Creates a [ChallengeStartedRow].
  const ChallengeStartedRow({super.key});

  /// The confirmation, either side of the day's own name.
  static const String addedPrefix = 'Added to ';

  /// See [addedPrefix].
  static const String addedSuffix = ' — log it when you brew.';

  /// The whole sentence, for a screen reader and for a test that wants it in
  /// one piece.
  static const String added = '$addedPrefix${AppLabels.tabToday}$addedSuffix';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: added,
      excludeSemantics: true,
      child: Padding(
        // The design's `padding: 13px 0`, on the scale: a plain row, with no
        // button in it to set the height, so it sits a stop above the offer's.
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text.rich(
          TextSpan(
            style: AppText.support(mood: mood, color: mood.ink),
            children: [
              const TextSpan(text: addedPrefix),
              // The design's `<strong>`, read off the ladder rather than
              // asked for as a weight: 500 is the heaviest cut the bundle
              // ships, and it is the one the control face carries (#380).
              TextSpan(
                text: AppLabels.tabToday,
                style: AppText.support(
                  mood: mood,
                  color: mood.ink,
                  face: AppFace.control,
                ),
              ),
              const TextSpan(text: addedSuffix),
            ],
          ),
        ),
      ),
    );
  }
}
