import 'package:brew_path/features/challenges/domain/challenge_completion.dart';
import 'package:brew_path/features/challenges/presentation/challenge_reaction_chips.dart';
import 'package:brew_path/features/challenges/presentation/challenge_sheet_shell.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

const double _promptLetterSpacing = 0.6;

/// What the learner chose to report, or null when they closed the sheet.
///
/// Dismissal and logging are different events, and a null here is what keeps
/// "I looked at this" from being recorded as "I brewed it".
typedef ChallengeLogResult = String?;

/// Opens the log sheet for [challenge] and resolves with the outcome picked,
/// or null when the learner dismissed it.
Future<ChallengeLogResult> showChallengeLogSheet({
  required BuildContext context,
  required BrewChallenge challenge,
}) => showChallengeSheet<String>(
  context: context,
  label: 'Log your result for ${challenge.title}',
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
        Semantics(
          header: true,
          child: Text(
            challenge.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
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
        FilledButton(
          // Disabled until an outcome is picked. Every authored reaction
          // asserts the brew happened, so logging without one would record a
          // claim the learner never made.
          onPressed: canLogResult(_picked)
              ? () => Navigator.of(context).pop(_picked)
              : null,
          child: const Text('Mark as done'),
        ),
      ],
    );
  }
}
