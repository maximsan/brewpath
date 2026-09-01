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
/// Draws the grove it opens rather than an icon: the door's whole job is to say
/// *this is yours and you can change it*, which a glyph cannot.
///
/// **Locked for a free learner**, and the lock is on the door rather than
/// inside the chooser — a learner should not walk through a door to be told
/// they cannot be there. The design marks that with a Plus pill beside the
/// eyebrow and **keeps the chevron**: the door still goes somewhere, it just
/// asks first.
///
/// The card around all of that is [ProfileEntryCard], shared with Saved — on
/// Profile the design draws the two entries as one row pattern (#428). This
/// widget used to hand its parts to a `StudioDoor` in between; with the row
/// settled in one place that layer held nothing but three strings, so the
/// wiring and the drawing sit together here, as Saved's do.
///
/// **It says `GROVE · Choose your plant`, not the design's `STUDIO · Dress up
/// Roasty`.** The design's Studio is a hub of several doors, of which dressing
/// the mascot is one; v1 ships only the grove chooser
/// ([#140](https://github.com/maximsan/brewpath/issues/140)), so the card names
/// what it actually opens. The mascot wardrobe returns with the hub in v2.
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
