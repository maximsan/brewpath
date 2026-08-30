import 'package:brew_path/features/profile/presentation/widgets/profile_entry_card.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:flutter/material.dart';

/// The way into Your grove.
///
/// Draws the grove it opens rather than an icon: the door's whole job is to
/// say *this is yours and you can change it*, which a glyph cannot.
///
/// **Locked for a free learner**, and the lock is on the door rather than
/// inside the chooser — a learner should not walk through a door to be told
/// they cannot be there.
///
/// The card around all of that is [ProfileEntryCard], shared with Saved: on
/// Profile the design draws the two as one row pattern, so the pill, the
/// chevron and the well are settled once (#428).
class StudioDoor extends StatelessWidget {
  /// Creates a [StudioDoor].
  const StudioDoor({
    required this.treatment,
    required this.subtitle,
    required this.locked,
    required this.onTap,
    super.key,
  });

  /// The plant inside the well, drawn small enough to read as a thumbnail.
  static const double _plantSize = 56;

  /// The stage the door's plant shows — grown, because the door advertises what
  /// the grove becomes rather than where it starts.
  static const int _doorStage = 10;

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
    return ProfileEntryCard(
      art: CoffeeTree(
        stage: _doorStage,
        treatment: treatment,
        size: _plantSize,
        animate: false,
      ),
      kicker: 'Grove',
      title: 'Choose your plant',
      // The planted grove, which is what makes this a door onto something the
      // learner already owns rather than a menu item.
      support: subtitle,
      locked: locked,
      onTap: onTap,
    );
  }
}
