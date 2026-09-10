import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_entry_card.dart';
import 'package:brew_path/features/studio/domain/roasty_studio_providers.dart';
import 'package:brew_path/features/studio/presentation/studio_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The mascot in the well, small enough to read as a thumbnail.
const double _mascotSize = 40;

/// The way into Dress up Roasty, beside the grove's door.
///
/// Draws the mascot as he is dressed, for the reason the grove's door draws
/// the planted grove: it says *this is yours and you can change it*, which a
/// glyph cannot. **Locked for a free learner** through the same sheet, on the
/// door rather than inside.
class RoastyDoorTile extends ConsumerWidget {
  /// Creates a [RoastyDoorTile].
  const RoastyDoorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank = ref.watch(roastyStudioProvider).asData?.value;
    // Unresolved reads as locked, as the grove's door does: a door that opens
    // for a frame and then refuses is worse than one that asks twice.
    final isPlus = ref.watch(courseEntitlementProvider).asData?.value ?? false;

    return ProfileEntryCard(
      // Frozen and undressed-by-default: the thumbnail shows what is stored
      // rather than the gated outfit, because this is the door onto changing
      // it. Free learners cannot open it, so nothing leaks past the gate.
      art: Roasty(
        state: RoastyState.idle,
        size: _mascotSize,
        animate: false,
        outfit: bank?.worn,
      ),
      kicker: 'Studio',
      title: 'Dress up Roasty',
      support: bank == null ? '' : bank.doorSubtitle,
      locked: !isPlus,
      onTap: () => isPlus
          ? context.goNamed(AppRoutes.roastyStudio.name)
          : showStudioLocked(context),
    );
  }
}
