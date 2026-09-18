import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/dictionary/domain/vocab_providers.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_run.dart';
import 'package:brew_path/features/progress/domain/progress_write.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/progress_seed.dart';
import '../../../support/widget_harness.dart';

// Which day Keep Sharp is asked about comes from currentDayProvider, not the
// wall clock. Every other test of these two providers replaces them with
// stubs, so without this the day they read is exercised by nothing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(useInMemoryDatabase);

  final monday = DateTime(2026, 8, 17);

  /// Listeners are held while the reads are in flight: these providers auto
  /// dispose, and one dropped mid-await never emits.
  ProviderContainer containerOn(DateTime day) {
    final container = ProviderContainer(
      overrides: [currentDayProvider.overrideWithValue(day)],
    );
    addTearDown(container.dispose);
    container
      ..listen(vocabPoolsProvider, (_, _) {})
      ..listen(miniGameFormatsProvider, (_, _) {})
      ..listen(keepSharpRecommendationProvider, (_, _) {})
      ..listen(keepSharpAcknowledgedTodayProvider, (_, _) {});
    return container;
  }

  Future<PracticeType?> typeOn(DateTime day) async => (await containerOn(
    day,
  ).read(keepSharpRecommendationProvider.future))?.type;

  test('the recommendation is not constant across a rotation', () async {
    // A finished lesson makes replay eligible beside mini-games: over a single
    // eligible type every day reads the same, and this would pass whatever
    // clock was used. Adjacent days are not asserted to differ — with two of
    // four eligible the rotation skips onto the same one — but four days cover
    // every starting position, so a constant answer means the day went unread.
    await seedCompletedLesson(SnapshotRepository(), 'm1l1', at: monday);

    final picks = <PracticeType?>[];
    for (var ahead = 0; ahead < PracticeType.values.length; ahead++) {
      picks.add(
        await typeOn(DateTime(monday.year, monday.month, monday.day + ahead)),
      );
    }

    expect(picks.toSet().length, greaterThan(1));
  });

  test('activity counts as today only on the day the provider names', () async {
    // The rule only reads mini-game runs on a day that recommends them, so the
    // day is found rather than assumed — bounded, so a rotation that stopped
    // offering them fails here instead of hanging.
    var gamesDay = monday;
    for (var ahead = 0; ahead < PracticeType.values.length; ahead++) {
      if (await typeOn(gamesDay) == PracticeType.miniGames) break;
      gamesDay = DateTime(gamesDay.year, gamesDay.month, gamesDay.day + 1);
    }
    expect(
      await typeOn(gamesDay),
      PracticeType.miniGames,
      reason: 'no day in one rotation recommended mini-games',
    );

    final container = containerOn(gamesDay);
    final formats = await container.read(miniGameFormatsProvider.future);
    final playable = [
      for (final format in formats)
        if (playableMiniGameIds.contains(format.id)) format.id,
    ];
    await updateProgress(
      container.read(snapshotRepositoryProvider),
      // A fresh scope: the store is empty, so nothing is being dropped.
      (progress) => ClearedByReset(
        dailyActivity: {
          epochDay(gamesDay): {
            for (final id in playable.take(2))
              activityEntry(
                type: ActivityType.miniGame,
                token: mintActivityToken(),
                subject: id,
              ),
          },
        },
      ),
      now: gamesDay,
    );
    // The held listener built this against the empty store; a write is what
    // invalidates it in the app too.
    container.invalidate(keepSharpAcknowledgedTodayProvider);

    final onTheDay = await container.read(
      keepSharpAcknowledgedTodayProvider.future,
    );
    // Two days on, so the rotation has come back round to mini-games and only
    // the day the entries are filed under can account for the difference.
    final twoDaysOn = await containerOn(
      DateTime(gamesDay.year, gamesDay.month, gamesDay.day + 2),
    ).read(keepSharpAcknowledgedTodayProvider.future);

    expect(onTheDay, isTrue, reason: 'two games were played on this day');
    expect(twoDaysOn, isFalse, reason: 'a later day starts owing again');
  });
}
