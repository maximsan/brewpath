import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/studio/presentation/widgets/plus_pill.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The art well beside the copy, at the design's 76.
const double _wellSize = 76;

/// The plant inside it, drawn small enough to read as a thumbnail.
const double _plantSize = 56;

/// The stage the door's plant shows — grown, because the door advertises what
/// the grove becomes rather than where it starts.
const int _doorStage = 10;

/// The way into Your grove.
///
/// Draws the grove it opens rather than an icon: the door's whole job is to
/// say *this is yours and you can change it*, which a glyph cannot.
///
/// **Locked for a free learner**, and the lock is on the door rather than
/// inside the chooser — a learner should not walk through a door to be told
/// they cannot be there. The design marks that with a Plus pill beside the
/// eyebrow and **keeps the chevron**: the door still goes somewhere, it just
/// asks first.
class StudioDoor extends StatelessWidget {
  /// Creates a [StudioDoor].
  const StudioDoor({
    required this.treatment,
    required this.subtitle,
    required this.locked,
    required this.onTap,
    super.key,
  });

  /// How the planted grove looks right now.
  final GroveTreatment treatment;

  /// What the door says it opens onto — the planted species, and its light
  /// when the light is not the default.
  final String subtitle;

  /// Whether the learner is outside the entitlement.
  final bool locked;

  /// Opens the chooser, or raises the gate.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: locked
          ? 'Choose your plant. $subtitle. BrewPath Plus'
          : 'Choose your plant. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.chrome),
              border: Border.all(color: mood.rule),
            ),
            child: Row(
              children: [
                Container(
                  width: _wellSize,
                  height: _wellSize,
                  decoration: BoxDecoration(
                    color: mood.bg,
                    borderRadius: BorderRadius.circular(AppRadii.chrome),
                    border: Border.all(color: mood.rule),
                  ),
                  child: Center(
                    child: SizedBox.square(
                      dimension: _plantSize,
                      child: CoffeeTree(
                        stage: _doorStage,
                        treatment: treatment,
                        animate: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          SmallcapsLabel('GROVE', color: mood.accentText),
                          if (locked) ...[
                            const SizedBox(width: AppSpacing.xs),
                            const PlusPill(),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Choose your plant',
                        style: AppText.heading(mood: mood),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      // The planted grove, which is what makes this a door onto
                      // something the learner already owns rather than a menu
                      // item.
                      Text(
                        subtitle,
                        style: AppText.support(
                          mood: mood,
                          color: mood.inkMute,
                        ),
                      ),
                    ],
                  ),
                ),
                const IconMark(AppIcon.chevron),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
