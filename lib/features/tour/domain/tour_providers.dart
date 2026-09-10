import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tour_providers.g.dart';

/// Whether the Tour has finished once on this device.
///
/// The auto-run gate, and nothing else: `false` means the first run is still
/// owed. It is written when a first run ends by Skip or Done (#537) — never by
/// leaving the tab, so a Tour walked away from returns on the next launch, as
/// the design's `tourDone` does. A replay neither reads nor writes it.
@riverpod
Future<bool> tourSeen(Ref ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return settings.tourSeen;
}

/// Which run of the Tour is on screen, if any.
enum TourRun {
  /// No Tour on screen.
  none,

  /// The once-per-device run Learn starts unasked; finishing it writes
  /// `tourSeen`.
  first,

  /// A run asked for from the App Guide, which writes nothing: the learner
  /// asking for the Tour again is not a learner still owed it.
  replay;

  /// Whether a Tour is on screen.
  bool get isRunning => this != none;
}

/// The run on screen.
///
/// Read by more than the layer: the Learn list mounts every child while a run
/// is on, so the engine can scroll to a stop that would otherwise still be
/// off-screen and unmounted. See `LearnListView` for why that is the
/// mitigation chosen.
@riverpod
class TourRunning extends _$TourRunning {
  @override
  TourRun build() => TourRun.none;

  /// Puts [run] on screen.
  // ignore: use_setters_to_change_properties
  void start(TourRun run) => state = run;

  /// Takes the Tour off screen.
  void end() => state = TourRun.none;
}

/// A pending request to replay the Tour, raised from outside the Learn tab.
///
/// Replay is asked for on Profile and happens on Learn, which are two branches
/// of the shell that cannot call each other — so the ask is state rather than a
/// callback. Learn consumes it the moment it arrives and runs the stops as a
/// [TourRun.replay], which writes nothing.
@riverpod
class TourReplayRequest extends _$TourReplayRequest {
  @override
  bool build() => false;

  /// Asks Learn to run the stops.
  void request() => state = true;

  /// Clears the ask, so a later rebuild does not run the Tour a second time.
  void consume() => state = false;
}

/// Records that a first run of the Tour finished, by either door.
///
/// The write is what matters; the refresh is best effort. By the time the
/// write lands, the widget that ended the Tour may be gone — a learner who
/// taps Done and switches tab at once — and a `WidgetRef` on an unmounted
/// widget throws. The flag is on disk either way, and re-read on next build.
Future<void> markTourSeen(WidgetRef ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  final settings = await repo.getSettings()
    ..tourSeen = true;
  await repo.saveSettings(settings);

  if (!ref.context.mounted) return;
  ref.invalidate(tourSeenProvider);
}
