import 'package:brew_path/core/swipe/swipe_surface.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/id_set.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_hint_providers.g.dart';

/// Replays every first-run swipe hint, whatever this device has learned.
///
/// The one debug toggle the hint answers to (README, _Run-time flags_). It
/// reads the flag rather than clearing it, so a tester loses nothing.
const bool kReplaySwipeHints = bool.fromEnvironment('REPLAY_SWIPE_HINTS');

/// The swipe surfaces whose gesture this learner has used.
///
/// A used gesture is what retires its hint — never a count of showings, which
/// only ever fires on the learner who has not learned it.
@riverpod
Future<Set<String>> swipesUsed(Ref ref) async {
  if (kReplaySwipeHints) return const {};
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return IdSet.decode(settings.swipesUsed);
}

/// Records that [surface]'s gesture has been used.
///
/// Same shape as `markMicroTipSeen`: the write is what matters and the refresh
/// is best effort, because the surface may already be gone by the time it
/// lands.
Future<void> markSwipeUsed(WidgetRef ref, SwipeSurface surface) async {
  final repository = ref.read(settingsRepositoryProvider);
  final settings = await repository.getSettings();
  settings.swipesUsed = IdSet.plus(settings.swipesUsed, surface.id);
  await repository.saveSettings(settings);

  if (!ref.context.mounted) return;
  ref.invalidate(swipesUsedProvider);
}
