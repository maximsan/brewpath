import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/snapshot_generators.dart';

/// Every writer on the progress scope, against a fully-populated scope.
///
/// These writers copy the scope field by field, so the failure mode is a
/// field silently left behind — progress a learner earned, dropped by the
/// write that recorded something else. The compiler catches a *renamed*
/// field (it did, loudly, when two branches renamed and added one in the same
/// release), but it cannot catch a forgotten one, which is what this covers.
void main() {
  final populated = SnapshotGen(11).progress();

  test('withAck changes the acks and nothing else', () {
    final after = populated.withAck('courseComplete', 20300);

    expect(after.acks['courseComplete'], 20300);
    expect(after.withAck('courseComplete', 20300), after);
    expect(
      after.toJson()..remove('acks'),
      populated.toJson()..remove('acks'),
    );
  });

  group('withActivity', () {
    const today = 20300;

    test('records the entry and marks the day when told to', () {
      final after = populated.withActivity(
        today,
        'lesson:tok:m1l1',
        marksDay: true,
      );

      expect(after.dailyActivity[today], contains('lesson:tok:m1l1'));
      expect(after.activeDays, contains(today));
    });

    test('records without marking when the day does not qualify', () {
      final after = populated.withActivity(
        today,
        'miniGame:tok:g-quiz',
        marksDay: false,
      );

      expect(after.dailyActivity[today], hasLength(1));
      expect(after.activeDays.contains(today), isFalse);
    });

    test('prunes the activity record but never the day set', () {
      final stale = populated
          .withActivity(today - 5, 'lesson:old:m1l1', marksDay: true)
          .withActivity(today, 'lesson:new:m1l2', marksDay: true);

      expect(
        stale.dailyActivity.keys,
        isNot(contains(today - 5)),
        reason: 'nothing reads back that far',
      );
      expect(
        stale.activeDays,
        containsAll([today - 5, today]),
        reason: 'the streak folds over the whole history',
      );
    });

    test('keeps a day ahead of the one being written', () {
      // Another device's clock may be ahead; dropping it deletes real work.
      final ahead = populated
          .withActivity(today + 1, 'lesson:ahead:m1l1', marksDay: true)
          .withActivity(today, 'lesson:now:m1l2', marksDay: true);

      expect(ahead.dailyActivity.keys, containsAll([today, today + 1]));
    });
  });

  test('withTreeStageAtLeast changes the stage and nothing else', () {
    final after = populated.withTreeStageAtLeast(treeStageCount);

    expect(after.treeStage, treeStageCount);
    expect(
      after.toJson()..remove('treeStage'),
      populated.toJson()..remove('treeStage'),
    );
  });

  test('withTreeStageAtLeast never lowers a stage already reached', () {
    final grown = populated.withTreeStageAtLeast(treeStageCount);

    expect(grown.withTreeStageAtLeast(1).treeStage, treeStageCount);
  });

  group('withActiveChallenge', () {
    const at = 1700000000000;

    test('puts a challenge in play and changes nothing else', () {
      final after = populated.withActiveChallenge(
        const ActiveChallenge(id: 'bc-m2', startedAt: at),
        at: at,
        writerId: 'device-a',
      );

      expect(after.activeChallenge.value?.id, 'bc-m2');
      expect(
        after.toJson()..remove('activeChallenge'),
        populated.toJson()..remove('activeChallenge'),
      );
    });

    test('carries the stamp and the writer onto the field', () {
      final after = populated.withActiveChallenge(
        const ActiveChallenge(id: 'bc-m2', startedAt: at),
        at: at,
        writerId: 'device-a',
      );

      expect(after.activeChallenge.updatedAt, at);
      expect(after.activeChallenge.writerId, 'device-a');
    });

    test('clearing is a write, not an absence', () {
      // A challenge that has run out of time has to be able to say so to the
      // other device; an unstamped null would lose the merge to a stale pair.
      final after = populated.withActiveChallenge(
        null,
        at: at,
        writerId: 'device-a',
      );

      expect(after.activeChallenge.value, isNull);
      expect(after.activeChallenge.updatedAt, at);
      expect(
        after.toJson()..remove('activeChallenge'),
        populated.toJson()..remove('activeChallenge'),
      );
    });

    test('leaves the completed set and the saved queue alone', () {
      final after = populated.withActiveChallenge(
        const ActiveChallenge(id: 'bc-m2', startedAt: at),
        at: at,
        writerId: 'device-a',
      );

      expect(after.challengesCompleted, populated.challengesCompleted);
      expect(after.challengesSaved, populated.challengesSaved);
      expect(after.challengeReactions, populated.challengeReactions);
    });
  });

  group('withChallengesSaved', () {
    const at = 1700000000000;

    test('replaces the queue and changes nothing else', () {
      final after = populated.withChallengesSaved(
        const {'bc-m4'},
        at: at,
        writerId: 'device-a',
      );

      expect(after.challengesSaved.value, {'bc-m4'});
      expect(after.challengesSaved.updatedAt, at);
      expect(
        after.toJson()..remove('challengesSaved'),
        populated.toJson()..remove('challengesSaved'),
      );
    });

    test('an empty queue is a value, not an absence', () {
      // Removal is first-class here, which is why the field is
      // last-writer-wins: a union would resurrect every dismissal.
      final after = populated.withChallengesSaved(
        const {},
        at: at,
        writerId: 'device-a',
      );

      expect(after.challengesSaved.value, isEmpty);
      expect(after.challengesSaved.updatedAt, at);
    });
  });

  group('withFavourites', () {
    const at = 1700000000000;

    test('replaces the shelf and changes nothing else', () {
      final after = populated.withFavourites(
        const {'t:arabica'},
        at: at,
        writerId: 'device-a',
      );

      expect(after.favourites.value, {'t:arabica'});
      expect(after.favourites.updatedAt, at);
      expect(after.favourites.writerId, 'device-a');
      expect(
        after.toJson()..remove('favourites'),
        populated.toJson()..remove('favourites'),
      );
    });

    test('replaces rather than unions, so a removal stays removed', () {
      // Last-writer-wins for the same reason the parked queue is: unioning
      // the shelf would resurrect every bookmark the learner ever took off,
      // from any device that still remembered it.
      final after = populated.withFavourites(
        const {},
        at: at,
        writerId: 'device-a',
      );

      expect(after.favourites.value, isEmpty);
      expect(after.favourites.updatedAt, at);
    });
  });

  test('withChallengeLogged records the brew and its outcome', () {
    final after = populated.withChallengeLogged(
      'bc-m4',
      reaction: 'Preferred 1:15',
      day: 20300,
    );

    expect(after.challengesCompleted, contains('bc-m4'));
    expect(after.challengeReactions['bc-m4']?.reaction, 'Preferred 1:15');
    expect(after.challengeReactions['bc-m4']?.at, 20300);
    expect(
      after.toJson()
        ..remove('challengesCompleted')
        ..remove('challengeReactions'),
      populated.toJson()
        ..remove('challengesCompleted')
        ..remove('challengeReactions'),
    );
  });

  test('withChallengeLogged replaces an earlier outcome for the same id', () {
    final first = populated.withChallengeLogged(
      'bc-m4',
      reaction: 'Preferred 1:15',
      day: 20300,
    );
    final second = first.withChallengeLogged(
      'bc-m4',
      reaction: 'Hard to tell',
      day: 20301,
    );

    expect(second.challengeReactions['bc-m4']?.reaction, 'Hard to tell');
    expect(second.challengesCompleted.where((id) => id == 'bc-m4').length, 1);
  });
}
