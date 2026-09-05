import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/tour/domain/micro_tip.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'micro_tip_providers.g.dart';

/// The ids of every micro-tip this learner has already been shown.
///
/// Read off the device-local settings row, beside `tourSeen` and under its rule
/// (#342): a tip having been shown is not progress, so it survives Reset and
/// goes with Delete Account.
@riverpod
Future<Set<String>> microTipsSeen(Ref ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return MicroTipsSeen.decode(settings.tipsSeen);
}

/// Records that [tip] has been shown.
///
/// Called the moment the card appears, not when it is dismissed: a tip the
/// learner has read and walked away from has done its job, and the X only hides
/// it. Same shape as `markTourSeen` — the write is what matters and the refresh
/// is best effort, because the screen that showed the tip may already be gone
/// by the time the write lands.
Future<void> markMicroTipSeen(WidgetRef ref, MicroTip tip) async {
  final repository = ref.read(settingsRepositoryProvider);
  final settings = await repository.getSettings();
  settings.tipsSeen = MicroTipsSeen.withTip(settings.tipsSeen, tip);
  await repository.saveSettings(settings);

  if (!ref.context.mounted) return;
  ref.invalidate(microTipsSeenProvider);
}

/// Whether a save has landed since the app opened.
///
/// A *rise* in the shelf, never its size: the tip answers the action the
/// learner just took, and someone who already keeps a dozen things is not told
/// what saving does every time they launch. A removal moves the same set the
/// other way and arms nothing.
///
/// Kept alive because it is the session's memory of an event. Letting it be
/// disposed and rebuilt would forget a save the moment nothing happened to be
/// watching, which is exactly the gap the flag exists to bridge.
@Riverpod(keepAlive: true)
class SaveMadeThisSession extends _$SaveMadeThisSession {
  @override
  bool build() {
    ref.listen(savedKeysProvider, (previous, next) {
      if (_grew(previous?.value?.length, next.value?.length)) state = true;
    });
    return false;
  }
}

/// Whether a lesson has been finished since the app opened — the beat the tree
/// tip follows.
///
/// The same shape, and kept alive for the same reason: the learner lands back
/// on the Learn tab a screen or two after the ending that grew the tree, and
/// the flag has to survive the trip.
@Riverpod(keepAlive: true)
class LessonFinishedThisSession extends _$LessonFinishedThisSession {
  @override
  bool build() {
    ref.listen(completedLessonIdsProvider, (previous, next) {
      if (_grew(previous?.value?.length, next.value?.length)) state = true;
    });
    return false;
  }
}

/// Whether [after] is a rise over [before], with an unresolved read counting as
/// no news.
///
/// The first resolve of either set is what a learner arrives with, not
/// something they just did, so a null [before] never arms a flag.
bool _grew(int? before, int? after) =>
    before != null && after != null && after > before;
