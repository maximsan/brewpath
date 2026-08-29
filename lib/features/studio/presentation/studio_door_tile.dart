import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/mini_games/domain/course_entitlement.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/studio/presentation/studio_gate.dart';
import 'package:brew_path/features/studio/presentation/widgets/studio_door.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Studio door, wired to what it needs.
///
/// The door widget itself is a drawing; this is the piece that knows whether
/// the learner may walk through it. Kept out of `ProfileScreen.build` so that
/// screen stays a list of sections rather than a place where entitlement is
/// decided.
class StudioDoorTile extends ConsumerWidget {
  /// Creates a [StudioDoorTile].
  const StudioDoorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grove = ref.watch(groveTreatmentProvider);
    // Unresolved reads as locked. The door is a promise about what a tap will
    // do, and one that opens for a frame and then refuses is worse than one
    // that asks twice.
    final isPlus = ref.watch(courseEntitlementProvider).asData?.value ?? false;

    return StudioDoor(
      treatment: grove.asData?.value ?? GroveTreatment.identity,
      locked: !isPlus,
      onTap: () => isPlus
          ? context.goNamed(AppRoutes.studio.name)
          : showStudioLocked(context),
    );
  }
}
