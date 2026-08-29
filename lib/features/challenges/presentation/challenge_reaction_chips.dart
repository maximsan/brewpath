import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

const double _chipPaddingH = 14;
const double _chipPaddingV = 10;

/// The outcomes a challenge offers, as a single-choice row that wraps.
///
/// **Never assumes a count.** Eleven records author three reactions and one
/// authors two, so this lays out whatever the record carries. A tap on the
/// selected chip clears it, which is also how a learner takes back an answer
/// they mis-tapped before committing to it.
class ChallengeReactionChips extends StatelessWidget {
  /// Creates a [ChallengeReactionChips].
  const ChallengeReactionChips({
    required this.reactions,
    required this.picked,
    required this.onPicked,
    super.key,
  });

  /// The outcomes this challenge authors.
  final List<String> reactions;

  /// The outcome chosen so far, or null.
  final String? picked;

  /// Called with the new choice, or null when the learner clears it.
  final ValueChanged<String?> onPicked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final reaction in reactions)
          _Chip(
            label: reaction,
            selected: reaction == picked,
            theme: theme,
            mood: mood,
            onTap: () => onPicked(reaction == picked ? null : reaction),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.theme,
    required this.mood,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final ThemeData theme;
  final MoodColors mood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _chipPaddingH,
            vertical: _chipPaddingV,
          ),
          decoration: BoxDecoration(
            color: selected ? mood.accent : mood.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: selected ? mood.accent : mood.rule),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? mood.accentInk : mood.ink,
            ),
          ),
        ),
      ),
    );
  }
}
