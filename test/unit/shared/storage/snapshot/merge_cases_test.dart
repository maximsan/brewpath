import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:brew_path/shared/storage/snapshot/merge_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/progress_snapshot.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:brew_path/shared/storage/snapshot/term_miss.dart';
import 'package:brew_path/shared/storage/snapshot/timestamped.dart';
import 'package:flutter_test/flutter_test.dart';

/// Named cases, on top of the generated laws.
///
/// The laws prove the merge is a lattice join; these prove it is the *intended*
/// join. Each one is a trap identified during design, and several describe the
/// obvious implementation being wrong in the direction that looks correct.
ProgressSnapshot _snap({
  int updatedAt = 0,
  String deviceId = 'device-a',
  int resetGeneration = 0,
  ClearedByReset progress = ClearedByReset.empty,
  ClearedByDeleteOnly account = ClearedByDeleteOnly.empty,
  Map<String, dynamic> unknown = const {},
  int version = ProgressSnapshot.currentVersion,
}) => ProgressSnapshot(
  version: version,
  updatedAt: updatedAt,
  deviceId: deviceId,
  resetGeneration: resetGeneration,
  clearedByReset: progress,
  clearedByDeleteOnly: account,
  unknown: unknown,
);

void main() {
  group('favourites — the resurrection trap', () {
    test('a removal is not undone by the device that never touched it', () {
      // The obvious per-key upsert resurrects every removed bookmark forever.
      // Worse, resolving against a *snapshot-level* timestamp lets the device
      // that never touched the field win purely by being active more recently.
      final iPadRemoved = _snap(
        updatedAt: 9000, // stale snapshot…
        progress: const ClearedByReset(
          favourites: Timestamped(
            value: {'l:m1l1'}, // …but a NEWER favourites edit
            updatedAt: 5000,
            writerId: 'ipad',
          ),
        ),
      );
      final phoneUntouched = _snap(
        updatedAt: 10000, // newer snapshot overall…
        deviceId: 'phone',
        progress: const ClearedByReset(
          favourites: Timestamped(
            value: {'l:m1l1', 'l:m1l2'}, // …with an OLDER favourites value
            updatedAt: 1000,
            writerId: 'phone',
          ),
        ),
      );

      final merged = mergeSnapshot(phoneUntouched, iPadRemoved);

      expect(merged.clearedByReset.favourites.value, {'l:m1l1'});
    });
  });

  group('bestResults — never downgrade', () {
    test('a worse replay does not lower a stored best', () {
      final good = _snap(
        progress: const ClearedByReset(
          bestResults: {'m1l1': MasteryResult(correct: 5, total: 5)},
        ),
      );
      final worse = _snap(
        deviceId: 'phone',
        progress: const ClearedByReset(
          bestResults: {'m1l1': MasteryResult(correct: 2, total: 5)},
        ),
      );

      expect(
        mergeSnapshot(worse, good).clearedByReset.bestResults['m1l1'],
        const MasteryResult(correct: 5, total: 5),
      );
    });
  });

  group('completedLessons — first completion is the true one', () {
    test('a collision keeps the earlier day', () {
      final early = _snap(
        progress: const ClearedByReset(completedLessons: {'m1l1': 3}),
      );
      final late = _snap(
        deviceId: 'phone',
        progress: const ClearedByReset(completedLessons: {'m1l1': 9}),
      );

      expect(
        mergeSnapshot(late, early).clearedByReset.completedLessons['m1l1'],
        3,
      );
    });
  });

  group('dailyActivity — a set per day, never a counter', () {
    test('two devices each playing one game that day combine to two', () {
      // A counter cannot express this: max gives 1, and sum double-counts on
      // redelivery. The union of events is exactly right.
      final mine = activityEntry(
        type: ActivityType.miniGame,
        token: 'phone-1',
        subject: 'g-match',
      );
      final theirs = activityEntry(
        type: ActivityType.miniGame,
        token: 'tablet-1',
        subject: 'g-quiz',
      );
      final phone = _snap(
        progress: ClearedByReset(
          dailyActivity: {
            4: {mine},
          },
        ),
      );
      final tablet = _snap(
        deviceId: 'tablet',
        progress: ClearedByReset(
          dailyActivity: {
            4: {theirs},
          },
        ),
      );

      final merged = mergeSnapshot(phone, tablet);

      expect(merged.clearedByReset.dailyActivity[4], {mine, theirs});
      expect(
        distinctMiniGameIds(merged.clearedByReset.dailyActivity[4]!),
        {'g-match', 'g-quiz'},
        reason: 'the streak rule survives the move off miniGamePlays',
      );
    });

    // Two runs of one game: two against the allowance, one for the streak.
    test('repeat runs of one game merge to two events but one game id', () {
      final first = activityEntry(
        type: ActivityType.miniGame,
        token: 'phone-1',
        subject: 'g-quiz',
      );
      final second = activityEntry(
        type: ActivityType.miniGame,
        token: 'tablet-1',
        subject: 'g-quiz',
      );
      final phone = _snap(
        progress: ClearedByReset(
          dailyActivity: {
            4: {first},
          },
        ),
      );
      final tablet = _snap(
        deviceId: 'tablet',
        progress: ClearedByReset(
          dailyActivity: {
            4: {second},
          },
        ),
      );

      final merged = mergeSnapshot(phone, tablet);

      expect(merged.clearedByReset.dailyActivity[4], hasLength(2));
      expect(distinctMiniGameIds(merged.clearedByReset.dailyActivity[4]!), {
        'g-quiz',
      });
    });
  });

  group('reset generation dominates progress — and only progress', () {
    final resetOnPhone = _snap(
      deviceId: 'phone',
      resetGeneration: 1,
      account: const ClearedByDeleteOnly(
        grove: Timestamped(
          value: Grove.initial,
          updatedAt: 1000,
          writerId: 'phone',
        ),
      ),
    );
    final tabletStillHasProgress = _snap(
      deviceId: 'tablet',
      progress: const ClearedByReset(
        completedLessons: {'m1l1': 2},
        ownedCollectibles: {'c1'},
        treeStage: 4,
      ),
      account: const ClearedByDeleteOnly(
        grove: Timestamped(
          value: Grove(variety: 'liberica', light: 'moonlit'),
          updatedAt: 5000, // a NEWER grove change
          writerId: 'tablet',
        ),
      ),
    );

    test('the higher generation clears progress wholesale', () {
      final merged = mergeSnapshot(tabletStillHasProgress, resetOnPhone);

      expect(merged.resetGeneration, 1);
      expect(merged.clearedByReset, ClearedByReset.empty);
    });

    test('but leaves a newer account-scoped change intact', () {
      // Scoping dominance to progress is the whole point: an unscoped reset
      // would stomp a personalisation made more recently on the other device.
      final merged = mergeSnapshot(tabletStillHasProgress, resetOnPhone);

      expect(merged.clearedByDeleteOnly.grove.value.variety, 'liberica');
    });
  });

  group('unknown keys — the silent data destroyer', () {
    test('a field this build has never heard of survives a merge', () {
      final fromNewerBuild = _snap(unknown: {'futureField': 42});
      final fromOlderBuild = _snap(deviceId: 'old');

      expect(
        mergeSnapshot(fromOlderBuild, fromNewerBuild).unknown['futureField'],
        42,
      );
    });

    test('and survives a decode/encode round trip', () {
      // Without this an old build decodes what it knows, drops the rest,
      // re-publishes, and the newer build's field is gone from the store with
      // no error anywhere.
      final raw = {
        ...ProgressSnapshot.empty.toJson(),
        'futureField': {'nested': true},
      };

      final round = ProgressSnapshot.fromJson(raw).toJson();

      expect(round['futureField'], {'nested': true});
    });

    test('survives INSIDE a scope, which is where every real field lives', () {
      // Envelope-only passthrough preserves nothing that matters: the snapshot
      // has no top-level progress fields at all, so a newer build's new field
      // necessarily lands inside `clearedByReset` or `clearedByDeleteOnly`.
      final raw = ProgressSnapshot.empty.toJson();
      (raw['clearedByReset']! as Map)['futureProgress'] = 7;
      (raw['clearedByDeleteOnly']! as Map)['futureChoice'] = 'teal';

      final round = ProgressSnapshot.fromJson(raw).toJson();

      expect((round['clearedByReset']! as Map)['futureProgress'], 7);
      expect((round['clearedByDeleteOnly']! as Map)['futureChoice'], 'teal');
    });

    test('a scoped unknown key is cleared by a reset, like its neighbours', () {
      // Scoping the passthrough is what stops a newer build's *progress* field
      // being re-attached after a wipe: "the tombstone holds only the envelope
      // — nothing personal."
      final beforeReset = _snap(
        progress: const ClearedByReset(unknown: {'futureProgress': 7}),
        account: const ClearedByDeleteOnly(unknown: {'futureChoice': 'teal'}),
      );
      final tombstone = _snap(deviceId: 'phone', resetGeneration: 1);

      final merged = mergeSnapshot(beforeReset, tombstone);

      expect(merged.clearedByReset.unknown, isEmpty);
      // …while an account-scoped one survives, exactly as the grove does.
      expect(merged.clearedByDeleteOnly.unknown['futureChoice'], 'teal');
    });

    test('an unknown object converges regardless of its key order', () {
      // Two devices holding the same object, written with the keys in a
      // different order. A `'$value'` comparison stringifies in insertion
      // order, so it would pick different winners on each device.
      final oneOrder = _snap(
        progress: const ClearedByReset(
          unknown: {
            'futureObject': {'a': 1, 'b': 2},
          },
        ),
      );
      final otherOrder = _snap(
        deviceId: 'phone',
        progress: const ClearedByReset(
          unknown: {
            'futureObject': {'b': 2, 'a': 1},
          },
        ),
      );

      expect(
        mergeSnapshot(oneOrder, otherOrder).clearedByReset.unknown,
        mergeSnapshot(otherOrder, oneOrder).clearedByReset.unknown,
      );
    });
  });

  group('version', () {
    test('is never written lower than the highest read', () {
      final newer = _snap(version: 7);
      final older = _snap(deviceId: 'old');

      expect(mergeSnapshot(older, newer).version, 7);
    });
  });

  group('the same-millisecond tie-break', () {
    test('converges instead of each device keeping its own answer', () {
      final a = _snap(
        progress: const ClearedByReset(
          favourites: Timestamped(
            value: {'l:a'},
            updatedAt: 5000,
            writerId: 'device-a',
          ),
        ),
      );
      final b = _snap(
        deviceId: 'device-b',
        progress: const ClearedByReset(
          favourites: Timestamped(
            value: {'l:b'},
            updatedAt: 5000, // identical instant
            writerId: 'device-b',
          ),
        ),
      );

      expect(
        mergeSnapshot(a, b).clearedByReset.favourites.value,
        mergeSnapshot(b, a).clearedByReset.favourites.value,
      );
    });

    test('resolves even when the same device wrote both', () {
      // Same instant AND same writer: the comparator still has to be total, or
      // the field never converges.
      final a = _snap(
        progress: const ClearedByReset(
          favourites: Timestamped(
            value: {'l:a'},
            updatedAt: 5000,
            writerId: 'solo',
          ),
        ),
      );
      final b = _snap(
        progress: const ClearedByReset(
          favourites: Timestamped(
            value: {'l:b'},
            updatedAt: 5000,
            writerId: 'solo',
          ),
        ),
      );

      expect(mergeSnapshot(a, b), mergeSnapshot(b, a));
    });
  });

  group('challengeReactions', () {
    test('a replay replaces the older answer through the merge rule', () {
      final older = _snap(
        progress: const ClearedByReset(
          challengeReactions: {
            'bc-m1': ChallengeReaction(reaction: 'No change', at: 2),
          },
        ),
      );
      final newer = _snap(
        deviceId: 'phone',
        progress: const ClearedByReset(
          challengeReactions: {
            'bc-m1': ChallengeReaction(reaction: 'Sharper', at: 6),
          },
        ),
      );

      expect(
        mergeSnapshot(older, newer).clearedByReset.challengeReactions['bc-m1'],
        const ChallengeReaction(reaction: 'Sharper', at: 6),
      );
    });
  });

  group('missedTerms — the Misses deck, in either order', () {
    // The acceptance case: two devices that miss and clear the same term, in
    // either order, land on whichever event was actually later.
    ProgressSnapshot missedOn(String device, int at) => _snap(
      deviceId: device,
      progress: ClearedByReset(
        missedTerms: {'crema': TermMiss(lastMissedAt: at)},
      ),
    );
    ProgressSnapshot clearedOn(String device, int at) => _snap(
      deviceId: device,
      progress: ClearedByReset(
        missedTerms: {'crema': TermMiss(lastCorrectAt: at)},
      ),
    );

    test(
      'a clear after a miss empties the deck, whichever side it came from',
      () {
        final phone = missedOn('phone', 1000);
        final tablet = clearedOn('tablet', 2000);

        for (final merged in [
          mergeSnapshot(phone, tablet),
          mergeSnapshot(tablet, phone),
        ]) {
          expect(merged.clearedByReset.missedTerms['crema']!.isMissed, isFalse);
        }
      },
    );

    test('a miss after a clear fills it, whichever side it came from', () {
      final phone = missedOn('phone', 2000);
      final tablet = clearedOn('tablet', 1000);

      for (final merged in [
        mergeSnapshot(phone, tablet),
        mergeSnapshot(tablet, phone),
      ]) {
        expect(merged.clearedByReset.missedTerms['crema']!.isMissed, isTrue);
      }
    });

    test(
      'a clear cannot be resurrected by the device that still holds the miss',
      () {
        // The failure a stored *set* of missed ids would ship: the tablet still
        // remembers the miss, so a union merge puts the term back forever.
        final tabletStillHoldsTheMiss = missedOn('tablet', 1000);
        final phoneCleared = _snap(
          deviceId: 'phone',
          progress: const ClearedByReset(
            missedTerms: {
              'crema': TermMiss(lastMissedAt: 1000, lastCorrectAt: 2000),
            },
          ),
        );

        final merged = mergeSnapshot(tabletStillHoldsTheMiss, phoneCleared);

        expect(merged.clearedByReset.missedTerms['crema']!.isMissed, isFalse);
      },
    );

    test('terms only one device knows about are kept', () {
      final phone = missedOn('phone', 1000);
      final tablet = clearedOn('tablet', 1000).copyWith(
        clearedByReset: const ClearedByReset(
          missedTerms: {'tamp': TermMiss(lastMissedAt: 1000)},
        ),
      );

      final merged = mergeSnapshot(phone, tablet).clearedByReset.missedTerms;

      expect(merged.keys, containsAll(['crema', 'tamp']));
    });
  });

  group('monotonic progress fields', () {
    test('activeDays unions rather than taking a side', () {
      // Two devices offline at five days each do not make five. A counter
      // cannot merge; the union of days is the set of days the learner was
      // active, on whichever device.
      final phone = _snap(
        progress: const ClearedByReset(activeDays: {1, 2, 3}),
      );
      final tablet = _snap(
        deviceId: 'tablet',
        progress: const ClearedByReset(activeDays: {3, 4, 5}),
      );

      expect(mergeSnapshot(phone, tablet).clearedByReset.activeDays, {
        1,
        2,
        3,
        4,
        5,
      });
    });

    test('treeStage takes the higher and never regrows downward', () {
      final grown = _snap(progress: const ClearedByReset(treeStage: 9));
      final behind = _snap(
        deviceId: 'tablet',
        progress: const ClearedByReset(treeStage: 4),
      );

      expect(mergeSnapshot(behind, grown).clearedByReset.treeStage, 9);
    });
  });
}
