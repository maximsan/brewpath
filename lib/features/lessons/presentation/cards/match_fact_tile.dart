import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// `.match-item.selected` is a hairline border plus an inset second line;
/// doubling the width is how that reads without painting two.
const double _selectedBorder = 2;
const double _plainBorder = 1;

/// One fact on a match board — in play, selected, or placed under its answer.
class MatchFactTile extends StatelessWidget {
  /// Creates a [MatchFactTile].
  const MatchFactTile({
    required this.text,
    required this.selected,
    required this.placedUnder,
    required this.onTap,
    super.key,
  });

  /// The fact itself.
  final String text;

  /// Whether this fact is the one waiting to be placed.
  final bool selected;

  /// The answer it was placed under, or null while it is still in play.
  final String? placedUnder;

  /// Selects this fact. Ignored once it is placed.
  final VoidCallback onTap;

  bool get _placed => placedUnder != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      button: !_placed,
      selected: selected,
      label: _placed ? '$text, placed under $placedUnder' : text,
      excludeSemantics: true,
      child: InkWell(
        onTap: _placed ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          // `.match-item.matched` is a **sage** border over a sage 12% wash,
          // and its text stays full ink — a paired fact is finished, not
          // dimmed. The app had it as a grey `surface2` box with half-alpha
          // ink, which read as disabled rather than solved.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.chrome),
            border: Border.all(
              color: switch ((_placed, selected)) {
                (true, _) => mood.sage,
                (false, true) => mood.accent,
                (false, false) => mood.rule,
              },
              width: selected && !_placed ? _selectedBorder : _plainBorder,
            ),
            color: _placed ? mood.sage.withValues(alpha: CardTints.wash) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(color: mood.ink),
                ),
              ),
              if (_placed) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  placedUnder!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: mood.sage,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
