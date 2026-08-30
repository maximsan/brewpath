import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/studio/presentation/widgets/grove_selection.dart';
import 'package:brew_path/shared/models/content/grove_variety.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The plant preview beside each name, small enough to read as a swatch.
const double _plantSize = 52;

/// The stage a row's plant is drawn at — nearly grown, so the silhouettes are
/// distinguishable from one another rather than three identical seedlings.
const int _rowStage = 9;

/// Size of the tick on the chosen row.
const double _tickSize = 22;
const double _tickMark = 12;

/// One species to plant, previewed under the light currently picked.
///
/// The row draws the plant rather than naming it, because the difference
/// between the three *is* the silhouette — a list of names would make the
/// choice arbitrary.
class PlantRow extends StatelessWidget {
  /// Creates a [PlantRow].
  const PlantRow({
    required this.variety,
    required this.treatment,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// The species this row offers.
  final GroveVariety variety;

  /// How it looks under the light currently picked.
  final GroveTreatment treatment;

  /// Whether it is the one being previewed.
  final bool selected;

  /// Picks it.
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      selected: selected,
      label: '${variety.name}, ${variety.use}',
      excludeSemantics: true,
      child: Material(
        color: GroveSelection.fill(mood, picked: selected),
        borderRadius: BorderRadius.circular(AppRadii.editorial),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(AppRadii.editorial),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.editorial),
              border: Border.all(
                color: GroveSelection.edge(mood, picked: selected),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: _plantSize,
                  height: _plantSize,
                  child: CoffeeTree(
                    stage: _rowStage,
                    treatment: treatment,
                    animate: false,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(variety.name, style: AppText.heading(mood: mood)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        variety.use.toUpperCase(),
                        style: AppText.micro(
                          mood: mood,
                          face: AppFace.mono,
                          color: selected ? mood.accentText : mood.inkMute,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Container(
                    width: _tickSize,
                    height: _tickSize,
                    decoration: BoxDecoration(
                      color: mood.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconMark(
                        AppIcon.check,
                        size: _tickMark,
                        color: mood.accentInk,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
