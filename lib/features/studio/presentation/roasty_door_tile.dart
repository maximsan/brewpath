import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/companion/application/companion_outfit.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_entry_card.dart';
import 'package:brew_path/features/studio/presentation/studio_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The mascot in the well, small enough to read as a thumbnail.
const double _mascotSize = 40;

/// What the door says it opens. The design writes the axes here rather than
/// the picks — the grove's door names what is planted, this one does not.
const String _support = 'Hat, gear, roast and sprout';

/// The way into Dress up Roasty, beside the grove's door.
///
/// Draws the mascot dressed, as the grove's door draws the planted grove: it
/// says *this is yours and you can change it*, which a glyph cannot. **Locked
/// for a free learner**, and drawn in the *gated* outfit — so the door is the
/// plain bean for them too, rather than the one screen that leaks it.
class RoastyDoorTile extends ConsumerWidget {
  /// Creates a [RoastyDoorTile].
  const RoastyDoorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Unresolved reads as locked, as the grove's door does: a door that opens
    // for a frame and then refuses is worse than one that asks twice.
    final isPlus = ref.watch(courseEntitlementProvider).asData?.value ?? false;
    final worn = ref.watch(companionOutfitProvider).asData?.value;

    return ProfileEntryCard(
      // Frozen, and in the gated outfit every other screen draws: a lapsed
      // learner meets the same plain bean here as everywhere else.
      art: Roasty(
        state: RoastyState.idle,
        size: _mascotSize,
        animate: false,
        outfit: worn,
      ),
      kicker: 'Companion',
      title: 'Dress up Roasty',
      support: _support,
      locked: !isPlus,
      onTap: () => isPlus
          ? context.goNamed(AppRoutes.roastyStudio.name)
          : showStudioLocked(context),
    );
  }
}
