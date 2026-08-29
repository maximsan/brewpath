import 'package:brew_path/shared/models/content/grove_light.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The colour dot that shows what the light does, at the design's 14px.
const double _swatchSize = 14;

/// The design's minimum for this control, which is also the platform's.
const double _minTarget = 44;

/// Alpha on the swatch's hairline — enough to read against a pale swatch
/// without becoming a ring in its own right.
const double _swatchEdgeAlpha = 0.22;

/// Wash behind the chosen pill.
const double _selectedWash = 0.12;

/// One light the grove can stand in.
///
/// A pill, which is what the design draws — and one of the few places it does
/// (`AppRadii.pill`). The swatch carries the meaning: the names alone would
/// not tell a learner what Moonlit looks like.
class LightPill extends StatelessWidget {
  /// Creates a [LightPill].
  const LightPill({
    required this.light,
    required this.swatch,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// The light this pill offers.
  final GroveLight light;

  /// Its swatch, already parsed from the bank's authored colour.
  final Color swatch;

  /// Whether the preview is currently standing in it.
  final bool selected;

  /// Picks it.
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      selected: selected,
      label: light.name,
      excludeSemantics: true,
      child: Material(
        color: selected ? mood.accent.withValues(alpha: _selectedWash) : null,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onSelect,
          customBorder: const StadiumBorder(),
          child: Container(
            constraints: const BoxConstraints(minHeight: _minTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: ShapeDecoration(
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? mood.accent : mood.rule,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: _swatchSize,
                  height: _swatchSize,
                  decoration: BoxDecoration(
                    color: swatch,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: mood.ink.withValues(alpha: _swatchEdgeAlpha),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  light.name,
                  style: AppText.support(
                    mood: mood,
                  ).copyWith(fontWeight: selected ? FontWeight.w500 : null),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
