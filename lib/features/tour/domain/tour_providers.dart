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

/// Records that the intro overlay was answered, whichever button answered it.
///
/// Takes a [WidgetRef] rather than a provider [Ref] because the caller is a
/// button handler and owns the lifetime of this async work — the same shape
/// `resetProgress` uses for the wipe.
Future<void> markTourSeen(WidgetRef ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  final settings = await repo.getSettings()
    ..tourSeen = true;
  await repo.saveSettings(settings);

  ref.invalidate(tourSeenProvider);
}
