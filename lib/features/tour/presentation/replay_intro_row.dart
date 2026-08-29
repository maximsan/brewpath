import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Replay Today introduction", at the foot of the App Guide.
///
/// The way back into a Tour that can now be skipped — and the design's own home
/// for it, alongside the written guide rather than among Profile's preferences,
/// where it used to read as a setting.
class ReplayIntroRow extends ConsumerWidget {
  /// Creates a [ReplayIntroRow].
  const ReplayIntroRow({super.key});

  void _replay(BuildContext context, WidgetRef ref) {
    // Switch first, then ask. Learn consumes the request as soon as it is
    // raised, and the stops it spotlights have to be the ones on screen.
    //
    // `go`, not `pop`: this row is two pushes deep on the root navigator, and
    // the Tour has to run with nothing of Settings left over it.
    context.goNamed(AppRoutes.learn.name);
    ref.read(tourReplayRequestProvider.notifier).request();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: const IconMark(AppIcon.rematch),
    title: const Text(TourCopy.replayTitle),
    subtitle: const Text(TourCopy.replayBody),
    trailing: const IconMark(AppIcon.chevron),
    onTap: () => _replay(context, ref),
  );
}
