import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/today_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Puts [TodayTour] on the Learn tab while the Tour is running, and takes it
/// off everywhere else.
///
/// **The gate is the lifetime.** The defect the rebuild retires was a callout
/// floating over the next tab, and the old engine could only be talked out of
/// it by a listener that had to stay correct. Here a tab that is not Learn
/// simply does not build the layer, so there is nothing to leave behind.
///
/// Leaving Learn also *ends* the run rather than parking it: someone who
/// navigates away mid-Tour has left it, and coming back to a card on stop three
/// would be a surprise rather than a courtesy.
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
      if (mounted) _end();
    });
  }

  void _end() => ref.read(tourRunningProvider.notifier).set(running: false);

  @override
  Widget build(BuildContext context) {
    final running = ref.watch(tourRunningProvider);
    if (!running || !widget.isOnLearn) return const SizedBox.shrink();
    return TodayTour(onFinish: _end);
  }
}

/// Starts the Tour.
///
/// Writes nothing to disk. `tourSeen` is the intro overlay's business, which is
/// what lets Replay reuse this untouched.
void startTour(WidgetRef ref) =>
    ref.read(tourRunningProvider.notifier).set(running: true);
