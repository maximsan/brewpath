import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tour_providers.g.dart';

/// Whether the learner has already answered the Tour's intro overlay.
///
/// The auto-run gate, and nothing else: `false` means the intro is still owed,
/// not that the Tour was abandoned mid-way. Abandonment deliberately does not
/// re-arm it — the flag is written when the overlay is *answered*, so someone
/// who started the Tour and backgrounded the app is not asked again.
@riverpod
Future<bool> tourSeen(Ref ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return settings.tourSeen;
}

/// Whether the Tour is currently on screen.
///
/// Exists for one reason: the Learn list mounts every child while it is true,
/// so the engine can scroll to a stop that would otherwise still be off-screen
/// and unmounted. See `LearnListView` for why that is the mitigation chosen.
@riverpod
class TourRunning extends _$TourRunning {
  @override
  bool build() => false;

  /// Marks the Tour as on screen (or off it again).
  // ignore: use_setters_to_change_properties
  void set({required bool running}) => state = running;
}

/// A pending request to replay the Tour, raised from outside the Learn tab.
///
/// Replay is asked for on Profile and happens on Learn, which are two branches
/// of the shell that cannot call each other — so the ask is state rather than a
/// callback. Learn consumes it the moment it arrives and runs the stops with no
/// intro overlay and no write, because the learner asking for the Tour again is
/// not a learner being offered it.
@riverpod
class TourReplayRequest extends _$TourReplayRequest {
  @override
  bool build() => false;

  /// Asks Learn to run the stops.
  void request() => state = true;

  /// Clears the ask, so a later rebuild does not run the Tour a second time.
  void consume() => state = false;
}

/// Records that the intro overlay was answered, whichever button answered it.
///
/// Takes a [WidgetRef] rather than a provider [Ref] because the caller is a
/// button handler and owns the lifetime of this async work — the same shape
/// `resetProgress` uses for the wipe.
///
/// The write is what matters; the refresh is best effort. By the time the
/// write lands, the screen that offered the Tour may be gone — a learner who
/// answers and switches tab at once, or the smoke walk finishing — and a
/// `WidgetRef` on an unmounted widget throws. The flag is on disk either way,
/// and the provider re-reads it on its next build.
Future<void> markTourSeen(WidgetRef ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  final settings = await repo.getSettings()
    ..tourSeen = true;
  await repo.saveSettings(settings);

  if (!ref.context.mounted) return;
  ref.invalidate(tourSeenProvider);
}
