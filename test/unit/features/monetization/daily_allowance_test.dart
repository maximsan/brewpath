import 'package:brew_path/features/monetization/domain/daily_allowance.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter_test/flutter_test.dart';

/// The cap is the **cardinality of today's entry set** (#65), so these assert
/// against real entries rather than a count: what the record holds and what
/// the rule reads must not be able to drift apart.
void main() {
  var minted = 0;
  String entry(ActivityType type, [String subject = '']) => activityEntry(
    type: type,
    // Deterministic, so a run is reproducible — the real token is minted from
    // a clock, and nothing here depends on which token it was.
    token: 'token${minted++}',
    subject: subject,
  );

  group('the free day', () {
    test('starts with room', () {
      expect(
        mayStartActivity(hasCourse: false, entriesToday: const {}),
        isTrue,
      );
    });

    test('still has room after one', () {
      expect(
        mayStartActivity(
          hasCourse: false,
          entriesToday: {entry(ActivityType.lesson, 'm1l1')},
        ),
        isTrue,
      );
    });

    test('is spent at the cap', () {
      expect(
        mayStartActivity(
          hasCourse: false,
          entriesToday: {
            entry(ActivityType.lesson, 'm1l1'),
            entry(ActivityType.vocab),
          },
        ),
        isFalse,
      );
    });

    test('counts two replays of one lesson as two', () {
      // §2 of #65's ruling: "permanently for replay" means never-expiring, not
      // cap-exempt — and a set keyed on type would have collapsed these.
      expect(
        mayStartActivity(
          hasCourse: false,
          entriesToday: {
            entry(ActivityType.replay, 'm1l1'),
            entry(ActivityType.replay, 'm1l1'),
          },
        ),
        isFalse,
      );
    });

    test('counts two runs of one mini-game as two', () {
      // The same entries read as *one* game by the streak's two-different
      // rule. The two readings of one record are deliberate.
      final today = {
        entry(ActivityType.miniGame, 'g-match'),
        entry(ActivityType.miniGame, 'g-match'),
      };
      expect(mayStartActivity(hasCourse: false, entriesToday: today), isFalse);
      expect(miniGamesMarkTheDay(today), isFalse);
    });

    test('counts an entry whose type this build does not know', () {
      // A newer build's activity type is carried, not understood. It is still
      // something the learner completed, so it still spends the allowance —
      // the alternative is a downgrade handing back free activities.
      expect(
        mayStartActivity(
          hasCourse: false,
          entriesToday: {'somethingNew:token:', entry(ActivityType.vocab)},
        ),
        isFalse,
      );
    });
  });

  test('Plus has no cap at any count', () {
    expect(mayStartActivity(hasCourse: true, entriesToday: const {}), isTrue);
    expect(
      mayStartActivity(
        hasCourse: true,
        entriesToday: {
          for (var i = 0; i < freeDailyActivities * 3; i++)
            entry(ActivityType.vocab),
        },
      ),
      isTrue,
    );
  });
}
