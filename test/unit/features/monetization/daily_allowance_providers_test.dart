import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/daily_allowance.dart';
import 'package:brew_path/features/monetization/domain/daily_allowance_providers.dart';
import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// The allowance read end to end: entries written by the **real recorder**,
/// read the way a tap reads it. A test that wrote its own entries could pass
/// while the recorder wrote a shape the cap cannot see, and one that reached
/// past `activityAllowanceNow` would assert against a cache no tap consults.
void main() {
  setUp(useInMemoryDatabase);

  final today = DateTime(2026, 9, 5, 10);

  ProviderContainer harness({bool hasCourse = false, DateTime? now}) {
    final container = ProviderContainer(
      overrides: [
        currentDayProvider.overrideWithValue(dateOnly(now ?? today)),
        courseEntitlementProvider.overrideWith((ref) async => hasCourse),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Records [count] finished activities of [type] against [when].
  Future<void> record(
    ProviderContainer container, {
    required int count,
    ActivityType type = ActivityType.vocab,
    DateTime? when,
  }) async {
    for (var i = 0; i < count; i++) {
      await recordActivity(
        container.read(snapshotRepositoryProvider),
        type: type,
        subject: '',
        now: when ?? today,
      );
    }
  }

  test('a fresh day has room', () async {
    final container = harness();

    expect(await activityAllowanceNow(container), isTrue);
  });

  test('the cap closes on the third start', () async {
    final container = harness();
    await record(container, count: freeDailyActivities);
    expect(await activityAllowanceNow(container), isFalse);
  });

  test('replays spend the allowance like anything else', () async {
    // #65 §2: "permanently for replay" means never-expiring, not cap-exempt.
    final container = harness();
    await record(
      container,
      count: freeDailyActivities,
      type: ActivityType.replay,
    );
    expect(await activityAllowanceNow(container), isFalse);
  });

  test('Plus is never capped', () async {
    final container = harness(hasCourse: true);
    await record(container, count: freeDailyActivities * 2);
    expect(await activityAllowanceNow(container), isTrue);
  });

  test('a second read after a completion sees it, uninvalidated', () async {
    // The guard reads this on a tap and nothing watches it, so it is disposed
    // between reads and recomputed on the next one. If that ever stopped being
    // true, a learner would spend their second activity and the third tap
    // would still be waved through — this is the test that would say so, and
    // it deliberately does **not** invalidate.
    final container = harness();
    expect(await activityAllowanceNow(container), isTrue);

    await record(container, count: freeDailyActivities);

    expect(await activityAllowanceNow(container), isFalse);
  });

  test('the day rolling over gives the allowance back', () async {
    // Yesterday's two, read against today: the count is per local calendar
    // day, and the record is keyed by the same day value the streak uses.
    final container = harness();
    await record(
      container,
      count: freeDailyActivities,
      when: today.subtract(const Duration(days: 1)),
    );
    expect(await activityAllowanceNow(container), isTrue);
  });
}
