import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Invalidates every provider derived against *today*.
///
/// Each is named rather than left to the dependency graph, which would put a
/// caller's correctness in another feature's wiring. Off the list on purpose:
/// the free day's allowance (ADR-0020) and the challenge windows (ADR-0030),
/// which read the clock as they rebuild instead of caching a day.
void invalidateDaySurfaces(WidgetRef ref) {
  ref
    ..invalidate(currentDayProvider)
    ..invalidate(streakStatusProvider)
    ..invalidate(keepSharpRecommendationProvider)
    ..invalidate(keepSharpAcknowledgedTodayProvider);
}
