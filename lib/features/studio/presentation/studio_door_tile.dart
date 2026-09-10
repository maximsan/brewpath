import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_entry_card.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/studio/domain/studio_providers.dart';
import 'package:brew_path/features/studio/presentation/studio_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The plant in the well, drawn small enough to read as a thumbnail.
const double _plantSize = 56;

/// The stage it shows — grown, because the door advertises what the grove
/// becomes rather than where it starts.
const int _doorStage = 10;

/// The way into Your grove, wired to what it needs.
///
/// Draws the grove it opens rather than an icon, and locks on the **door**
/// rather than inside the chooser — Plus pill beside the eyebrow, chevron
/// kept, so it still goes somewhere and just asks first. Its title names what
/// it opens; the wardrobe is the Studio's second door (#367).
class StudioDoorTile extends ConsumerWidget {
  /// Creates a [StudioDoorTile].
  const StudioDoorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank = ref.watch(studioGroveProvider).asData?.value;
    // Unresolved reads as locked. The door is a promise about what a tap will
    // do, and one that opens for a frame and then refuses is worse than one
    // that asks twice.
    final isPlus = ref.watch(courseEntitlementProvider).asData?.value ?? false;

    return ProfileEntryCard(
      art: CoffeeTree(
        stage: _doorStage,
        treatment: bank == null
            ? GroveTreatment.identity
            : bank.treatmentFor(bank.planted.variety, bank.planted.light),
        size: _plantSize,
        animate: false,
      ),
      kicker: 'Grove',
      title: 'Choose your plant',
      // The planted species — and its light when the light is not the default
      // — which is what makes this a door onto something the learner already
      // owns rather than a menu item. Empty until the bank resolves.
      support: bank == null ? '' : bank.doorSubtitle,
      locked: !isPlus,
      onTap: () => isPlus
          ? context.goNamed(AppRoutes.studio.name)
          : showStudioLocked(context),
    );
  }
}
