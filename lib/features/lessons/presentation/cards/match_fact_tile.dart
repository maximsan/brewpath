import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How far a placed fact recedes: it stays readable as the record of what was
/// matched, without competing with the facts still in play.
const double _placedFactTint = 0.5;

/// Border weights: the selected fact carries the heavier one.
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.chrome),
            border: Border.all(
              color: selected ? mood.accent : mood.rule,
              width: selected ? _selectedBorder : _plainBorder,
            ),
            color: _placed ? mood.surface2 : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _placed
                        ? mood.ink.withValues(alpha: _placedFactTint)
                        : mood.ink,
                  ),
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
