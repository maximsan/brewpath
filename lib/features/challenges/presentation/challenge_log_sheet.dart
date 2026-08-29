import 'package:brew_path/core/widgets/app_sheet.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/challenges/domain/challenge_completion.dart';
import 'package:brew_path/features/challenges/presentation/challenge_reaction_chips.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

const double _promptLetterSpacing = 0.6;

/// What the learner did with the sheet.
///
/// Three outcomes, and only one of them is a claim that the brew happened.
/// Dismissal resolves null: "I looked at this" must never be recorded as
/// "I brewed it".
sealed class ChallengeLogResult {
  const ChallengeLogResult();
}

/// The learner reported an outcome.
class ChallengeLogged extends ChallengeLogResult {
  /// Creates a [ChallengeLogged].
  const ChallengeLogged(this.reaction);

  /// The outcome they picked, as authored.
  final String reaction;
}

/// The learner parked it for later.
class ChallengeSavedForLater extends ChallengeLogResult {
  /// Creates a [ChallengeSavedForLater].
  const ChallengeSavedForLater();
}

/// Opens the log sheet for [challenge], resolving with what the learner did,
/// or null when they dismissed it.
Future<ChallengeLogResult?> showChallengeLogSheet({
  required BuildContext context,
  required BrewChallenge challenge,
}) => showAppSheet<ChallengeLogResult>(
  context: context,
  title: challenge.title,
  builder: (context) => _LogSheetBody(challenge: challenge),
);

class _LogSheetBody extends StatefulWidget {
  const _LogSheetBody({required this.challenge});

  final BrewChallenge challenge;

  @override
  State<_LogSheetBody> createState() => _LogSheetBodyState();
}

class _LogSheetBodyState extends State<_LogSheetBody> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final challenge = widget.challenge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The challenge's own question, not a generic one. A card that asks
        // "how did it go?" invites a verdict on the learner; "WHICH CUP WON?"
        // asks about the coffee.
        Text(
          challenge.prompt,
          style: theme.textTheme.labelSmall?.copyWith(
            color: mood.inkMute,
            fontWeight: FontWeight.w700,
            letterSpacing: _promptLetterSpacing,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ChallengeReactionChips(
          reactions: challenge.reactions,
          picked: _picked,
          onPicked: (picked) => setState(() => _picked = picked),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Mark as done',
          // Disabled until an outcome is picked. Every authored reaction
          // asserts the brew happened, so logging without one would record a
          // claim the learner never made.
          onPressed: canLogResult(_picked)
              ? () => Navigator.of(context).pop(ChallengeLogged(_picked!))
              : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          // Not a penalty and not an archive — the learner saying *not now*,
          // which is exactly what the queue is for.
          onPressed: () => Navigator.of(
            context,
          ).pop(const ChallengeSavedForLater()),
          child: const Text('Save for later'),
        ),
      ],
    );
  }
}
