import 'dart:async';

import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/today_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Puts [TodayTour] on the Learn tab while the Tour is running, and takes it
/// off everywhere else.
///
/// The gate is the lifetime: a tab that is not Learn simply does not build the
/// layer, so there is nothing to leave behind. Leaving Learn *ends* the run
/// rather than parking it — returning to stop three would surprise, not serve.
class TourLayerHost extends ConsumerStatefulWidget {
  /// Creates a [TourLayerHost] for a shell currently showing (or not showing)
  /// the Learn tab's root.
  const TourLayerHost({required this.isOnLearn, super.key});

  /// Whether the Learn tab's own root is what the learner is looking at.
  ///
  /// Passed as a value rather than read from the router so the rule is a widget
  /// input — a test changes it directly, with no route to drive.
  final bool isOnLearn;

  @override
  ConsumerState<TourLayerHost> createState() => _TourLayerHostState();
}

class _TourLayerHostState extends ConsumerState<TourLayerHost> {
  @override
  void didUpdateWidget(TourLayerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isOnLearn || widget.isOnLearn) return;
    // Next frame, not this one: the branch changes *during* a build, and
    // ending the Tour writes a provider, which Riverpod refuses mid-build.
    // Nothing is visible in the meantime — the layer is already not built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _leave();
    });
  }

  /// Ends a run the learner walked away from. Nothing is written: the design
  /// sets its flag by finishing, so a Tour left at stop one is still owed and
  /// runs again on the next launch.
  void _leave() => ref.read(tourRunningProvider.notifier).end();

  /// Ends a run by Skip or Done, which is what spends the first run.
  void _finish() {
    final run = ref.read(tourRunningProvider);
    ref.read(tourRunningProvider.notifier).end();
    if (run == TourRun.first) unawaited(markTourSeen(ref));
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(tourRunningProvider);
    if (!run.isRunning || !widget.isOnLearn) return const SizedBox.shrink();
    return TodayTour(onFinish: _finish);
  }
}

/// Starts [run].
///
/// Writes nothing to disk: `tourSeen` is written when a first run finishes,
/// which is what lets Replay reuse this untouched.
void startTour(WidgetRef ref, TourRun run) =>
    ref.read(tourRunningProvider.notifier).start(run);
