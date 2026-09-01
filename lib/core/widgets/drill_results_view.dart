import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How a drill ends: the companion, one number, and the two ways out.
///
/// The design's shared results layout (`dictionary-extras.jsx:95`) — the drills
/// and the Coffee Challenge all close on this shape, which is why it is here
/// rather than beside the first screen to want it
/// ([#389](https://github.com/maximsan/brewpath/issues/389)).
///
/// **It reports, it does not judge.** The big value is whatever the drill
/// counted, and the caller names what that count is; nothing here turns it into
/// a score. `MiniGameResultsView` stays separate for exactly that reason: it
/// carries a score out of a total and picks a pose from it, which is a
/// different thing to say.
///
/// The mascot arrives as a widget rather than being built here. Nothing else
/// in `lib/core/` reaches into a feature, and the companion is one — so the
/// drill that knows which pose it has earned passes the one it wants.
class DrillResultsView extends StatelessWidget {
  /// Creates a [DrillResultsView].
  const DrillResultsView({
    required this.companion,
    required this.kicker,
    required this.value,
    required this.note,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    super.key,
  });

  /// The mascot at the top, already posed by whoever finished the drill.
  final Widget companion;

  /// The smallcaps line above the number — which drill this was.
  final String kicker;

  /// The number itself, already written the way it should read.
  final String value;

  /// What the number counts, under it.
  final String note;

  /// A sentence about what just happened, and what to do next.
  final String message;

  /// The action that goes again.
  final String primaryLabel;

  /// Runs [primaryLabel].
  final VoidCallback onPrimary;

  /// The action that leaves.
  final String secondaryLabel;

  /// Runs [secondaryLabel].
  final VoidCallback onSecondary;

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
                child: Semantics(
                  // One announcement for the whole block: read out piece by
                  // piece, "FLASHCARDS / 12 / TERMS REVIEWED" is three
                  // fragments where the learner needs one sentence.
                  label: '$kicker. $value $note. $message',
                  excludeSemantics: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      companion,
                      const SizedBox(height: AppSpacing.lg),
                      SmallcapsLabel(kicker),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        value,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: mood.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SmallcapsLabel(note),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mood.inkMute,
                        ),
                      ),
                    ],
                  ),
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
            child: Column(
              children: [
                PrimaryButton(label: primaryLabel, onPressed: onPrimary),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onSecondary,
                    child: Text(secondaryLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
