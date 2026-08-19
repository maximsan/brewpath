import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('entries carry their type and subject', () {
    test('a mini-game entry round-trips its type and its game id', () {
      final entry = activityEntry(
        type: ActivityType.miniGame,
        token: 't1',
        subject: 'g-quiz',
      );

      expect(parseActivityEntry(entry).type, ActivityType.miniGame);
      expect(parseActivityEntry(entry).subject, 'g-quiz');
    });

    test('a subjectless type round-trips too', () {
      final entry = activityEntry(type: ActivityType.vocab, token: 't1');

      expect(parseActivityEntry(entry).type, ActivityType.vocab);
      expect(parseActivityEntry(entry).subject, isEmpty);
    });

    test(
      'an entry from a newer build reads as an unknown type, not a crash',
      () {
        expect(parseActivityEntry('podcast:t1:abc').type, isNull);
        expect(parseActivityEntry('nonsense').type, isNull);
      },
    );
  });

  // The bug this shape exists to prevent: a set keyed on type would collapse
  // these two, and the cap must see two.
  group('every completion is its own entry', () {
    test('two vocab rounds in one day are two entries', () {
      final day = {
        activityEntry(type: ActivityType.vocab, token: mintActivityToken()),
        activityEntry(type: ActivityType.vocab, token: mintActivityToken()),
      };

      expect(day, hasLength(2));
    });

    test('two replays of the same lesson are two entries', () {
      final day = {
        for (var run = 0; run < 2; run++)
          activityEntry(
            type: ActivityType.replay,
            token: mintActivityToken(),
            subject: 'm1l1',
          ),
      };

      expect(day, hasLength(2));
    });
  });

  group('distinctMiniGameIds — the streak rule, unchanged in meaning', () {
    test('two different games in a day read as two', () {
      final day = {
        activityEntry(
          type: ActivityType.miniGame,
          token: 't1',
          subject: 'g-quiz',
        ),
        activityEntry(
          type: ActivityType.miniGame,
          token: 't2',
          subject: 'g-match',
        ),
      };

      expect(distinctMiniGameIds(day), {'g-quiz', 'g-match'});
    });

    test('two runs of one game still read as one', () {
      final day = {
        activityEntry(
          type: ActivityType.miniGame,
          token: 't1',
          subject: 'g-quiz',
        ),
        activityEntry(
          type: ActivityType.miniGame,
          token: 't2',
          subject: 'g-quiz',
        ),
      };

      expect(day, hasLength(2), reason: 'the cap counts two');
      expect(distinctMiniGameIds(day), {'g-quiz'}, reason: 'the streak, one');
    });

    test('other activity types are not games', () {
      final day = {
        activityEntry(type: ActivityType.vocab, token: 't1'),
        activityEntry(type: ActivityType.lesson, token: 't2', subject: 'm1l1'),
      };

      expect(distinctMiniGameIds(day), isEmpty);
    });
  });

  group('a token and a subject cannot corrupt each other', () {
    test('a subject containing the separator survives decoding', () {
      // Prefixed ids like `l:m1l1` already exist elsewhere in the snapshot.
      final entry = activityEntry(
        type: ActivityType.lesson,
        token: 't1',
        subject: 'l:m1l1',
      );

      expect(parseActivityEntry(entry).subject, 'l:m1l1');
      expect(parseActivityEntry(entry).type, ActivityType.lesson);
    });

    test('a minted token carries no separator', () {
      expect(mintActivityToken(), isNot(contains(':')));
    });

    test('two mints never collide', () {
      final tokens = {for (var i = 0; i < 200; i++) mintActivityToken()};

      expect(tokens, hasLength(200));
    });
  });

  group('pruneDailyActivity', () {
    test('keeps today and yesterday, drops what nothing reads', () {
      final record = {
        10: {activityEntry(type: ActivityType.vocab, token: 't1')},
        11: {activityEntry(type: ActivityType.vocab, token: 't1')},
        12: {activityEntry(type: ActivityType.vocab, token: 't1')},
        5: {activityEntry(type: ActivityType.vocab, token: 't1')},
      };

      final pruned = pruneDailyActivity(record, today: 12);

      expect(pruned.keys, unorderedEquals([11, 12]));
    });

    test('a day from a peer ahead of this clock survives', () {
      // Clocks differ; dropping the future would delete a real completion.
      final record = {
        12: {activityEntry(type: ActivityType.vocab, token: 't1')},
        13: {activityEntry(type: ActivityType.vocab, token: 't1')},
      };

      expect(pruneDailyActivity(record, today: 12).keys, contains(13));
    });

    test('pruning an empty record is a no-op', () {
      expect(pruneDailyActivity(const {}, today: 12), isEmpty);
    });
  });
}
