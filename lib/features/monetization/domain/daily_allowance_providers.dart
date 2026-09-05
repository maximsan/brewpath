/// Whether the learner may start another activity today.
library;

import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/daily_allowance.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_allowance_providers.g.dart';

/// Whether a full learning/practice activity may start right now.
///
/// **Derived, never stored.** The count is the cardinality of today's entries
/// in the activity record — a stored quota would be neither monotonic nor an
/// outcome, and #65 refused that shape three times before this landed.
///
/// **Read it through [activityAllowanceNow], never straight from the cache.**
@riverpod
Future<bool> canStartActivity(Ref ref) async {
  // Watches before awaits: a mid-flight rebuild must not reach a watch across
  // an async gap on a disposed ref.
  final today = epochDay(ref.watch(currentDayProvider));
  final entitlementFuture = ref.watch(courseEntitlementProvider.future);
  final snapshot = await ref.watch(snapshotRepositoryProvider).read();

  return mayStartActivity(
    hasCourse: await entitlementFuture,
    entriesToday: snapshot.clearedByReset.dailyActivity[today] ?? const {},
  );
}

/// Re-derives the allowance rather than recalling it.
///
/// `refresh` and not `read`: nothing watches this provider, so its cached
/// value is only ever as old as the last tap — and the write that spends an
/// activity happens between two taps. Making freshness the read's job rather
/// than a register's is what stops a completion path added later from being
/// the one that forgot to invalidate.
Future<bool> activityAllowanceNow(ProviderContainer container) =>
    container.refresh(canStartActivityProvider.future);
