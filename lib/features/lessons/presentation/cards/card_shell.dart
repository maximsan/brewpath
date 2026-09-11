import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_cue.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_cue_row.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The commit a card offers before it has latched, in place of Continue.
///
/// Its own value rather than a label and a callback passed loose, because the
/// shell shows the action only when both are present — one nullable field
/// makes that unrepresentable rather than merely unlikely.
@immutable
class CardCommit {
  /// Creates a [CardCommit].
  const CardCommit({required this.label, required this.onCommit});

  /// What the button says, e.g. `Check answers`.
  final String label;

  /// Null while the card has nothing to commit, which disables the button.
  final VoidCallback? onCommit;
}

/// The frame every card renders inside.
///
/// It owns one rule so no card can forget it: continuing is gated on the card
/// having latched, and a wrong answer gets no second label. A kind that commits
/// separately from answering passes [commit], and the shell swaps that action
/// for Continue rather than letting the card draw a second way forward.
class CardShell extends StatelessWidget {
  /// Creates a [CardShell].
  const CardShell({
    required this.latched,
    required this.onContinue,
    required this.children,
    this.cue,
    this.label,
    this.title,
    this.commit,
    this.continueLabel = AppLabels.continueLabel,
    super.key,
  });

  /// Whether the card has been committed. Until it is, continue stays disabled.
  final bool latched;

  /// Called when the learner moves on.
  final CardAdvance onContinue;

  /// The card's own body.
  final List<Widget> children;

  /// The format this card is playing, named in the accent with the `?` that
  /// explains it. The ten kinds the design writes help for pass one; the five
  /// that carry an authored eyebrow instead pass [label].
  final CardCue? cue;

  /// Small-caps eyebrow, e.g. `CONCEPT` or `AT THE SHELF`.
  final String? label;

  /// The card's heading, where its kind has one.
  final String? title;

  /// The action shown instead of Continue until the card latches, for a kind
  /// that commits separately from answering. Null for every other kind, which
  /// shows a disabled Continue while it waits.
  final CardCommit? commit;

  /// What the way forward says: Continue, unless the design words this card's
  /// gate itself — the predict card's *Make a guess*, then *Find out*.
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    // Two halves, spread apart: when the host gives the card the viewport's
    // height the way on sits at the foot, as the design's `flex: 1` spacer
    // puts it, and a taller card simply runs on with the button after it.
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (cue case final cue?) ...[
              CardCueRow(cue: cue),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (label != null) ...[
              Text(
                label!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: mood.inkMute,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            ...children,
          ],
        ),
        // The lesson's own CTA, so it is the design's `.btn-primary` at full
        // width and 52 — not Material's 40, which left the most-pressed button
        // in the app shorter than the Continue on the screen after it. The
        // design pads it `paddingTop: 32` off the content.
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl),
          child: commit != null && !latched
              ? PrimaryButton(label: commit!.label, onPressed: commit!.onCommit)
              : PrimaryButton(
                  label: continueLabel,
                  onPressed: latched ? onContinue : null,
                ),
        ),
      ],
    );
  }
}
