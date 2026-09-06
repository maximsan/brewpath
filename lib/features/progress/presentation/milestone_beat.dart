import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The celebration half of a milestone day: Roasty, the count, one button.
///
/// The whole screen while it plays, chrome included — the design renders it
/// instead of the streak page rather than inside it.
class MilestoneBeat extends StatelessWidget {
  /// Creates a [MilestoneBeat] for a [streak] of days.
  const MilestoneBeat({
    required this.streak,
    required this.onContinue,
    super.key,
  });

  /// The streak being celebrated.
  final int streak;

  /// What the one button does.
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CompanionCelebration(
                      reaction: CompanionReaction.streakMilestone,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('STREAK', style: AppText.label(mood: mood)),
                    const SizedBox(height: AppSpacing.xs),
                    Semantics(
                      header: true,
                      child: Text(
                        '$streak days in a row.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: mood.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: PrimaryButton(label: 'Continue', onPressed: onContinue),
          ),
        ],
      ),
    );
  }
}
