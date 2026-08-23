import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Invalidates every provider derived against *today*.
///
/// The list lives here because three call sites each held their own copy of
/// it — a lesson that recorded a day, a mini-game that marked one, and a
/// resume that crossed midnight. A fourth day-dependent provider would have
/// had to be added to all three, and the one that got missed fails silently:
/// a surface quietly showing yesterday's answer, which is the defect
/// [#202](https://github.com/maximsan/brewpath/issues/202) existed to end.
///
/// **The app header's date is the fourth**, added when the shared header
/// landed — the case this doc predicted, where a day-dependent surface added
/// later gets missed and quietly shows yesterday.
///
/// **`keepSharpAcknowledgedToday` is named deliberately**, even though it
/// watches the recommendation and so already rebuilds when that one is
/// invalidated. Trimming this to what the dependency graph currently makes
/// sufficient would make every caller's correctness depend on wiring inside
/// another feature, and no test can catch that being rewired — a test with
/// overridden providers severs the very edge it would be relying on. Naming
/// all three is what stops this list from being knowledge each caller has to
/// hold correctly.
///
/// It lives in `app/` because the trio spans progress and learn and belongs to
/// neither: the day it turns on is the app's, not a feature's.
void invalidateDaySurfaces(WidgetRef ref) {
  ref
    ..invalidate(currentDayProvider)
    ..invalidate(streakStatusProvider)
    ..invalidate(keepSharpRecommendationProvider)
    ..invalidate(keepSharpAcknowledgedTodayProvider);
}
