import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The tier's name, which is **Plus** and never *Premium* (#30).
const String _label = 'PLUS';

/// The mark that a surface belongs to the paid tier.
///
/// A pill beside a door's eyebrow, which is how the design says "locked" here
/// — rather than swapping the chevron for a padlock. The door still goes
/// somewhere; it just asks first.
///
/// It says only the tier's name. What Plus *costs* and what it *includes* is
/// the gate sheet's ([#89](https://github.com/maximsan/brewpath/issues/89)),
/// and a second place saying it is a second place to get it wrong.
class PlusPill extends StatelessWidget {
  /// Creates a [PlusPill].
  const PlusPill({super.key});

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: mood.accent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        _label,
        style: AppText.micro(
          mood: mood,
          face: AppFace.mono,
          color: mood.accentInk,
        ),
      ),
    );
  }
}
