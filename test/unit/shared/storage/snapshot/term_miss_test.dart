// The Misses deck's record, which is two stamps rather than a set of ids —
// because a set with removals cannot merge, and this one has to.
import 'package:brew_path/shared/storage/snapshot/term_miss.dart';
import 'package:flutter_test/flutter_test.dart';

/// Three moments, ordered, in the units the record stores.
const int _early = 1000;
const int _later = 2000;
const int _latest = 3000;

void main() {
  group('whether a term is owed a review', () {
    test('an unanswered term is not', () {
      expect(TermMiss.none.isMissed, isFalse);
    });

    test('a wrong answer puts it in the deck', () {
      expect(
        TermMiss.none.answered(correct: false, at: _early).isMissed,
        isTrue,
      );
    });

    test('a later correct answer takes it out again', () {
      final record = TermMiss.none
          .answered(correct: false, at: _early)
          .answered(correct: true, at: _later);

      expect(record.isMissed, isFalse);
    });

    test('a later wrong answer puts it back', () {
      final record = TermMiss.none
          .answered(correct: true, at: _early)
          .answered(correct: false, at: _later);

      expect(record.isMissed, isTrue);
    });

    test('a tie clears rather than keeps', () {
      // Only reachable across two devices. Leaving a term the learner has
      // just got right in their review deck is the worse of the two ways to
      // be wrong about a tie.
      const record = TermMiss(lastMissedAt: _early, lastCorrectAt: _early);

      expect(record.isMissed, isFalse);
    });
  });

  group('recording an answer', () {
    test('keeps the other stamp untouched', () {
      const answered = TermMiss(lastMissedAt: _early, lastCorrectAt: _later);

      expect(
        answered.answered(correct: false, at: _latest),
        const TermMiss(lastMissedAt: _latest, lastCorrectAt: _later),
      );
    });

    test('never walks a stamp backwards', () {
      // A device whose clock is behind must not undo what a later answer
      // already recorded — every field in this scope is monotonic.
      const answered = TermMiss(lastMissedAt: _latest);

      expect(answered.answered(correct: false, at: _early), answered);
    });
  });

  group('joining two devices', () {
    test('the later event wins, whichever device held it', () {
      const missedOnly = TermMiss(lastMissedAt: _later);
      const clearedOnly = TermMiss(lastCorrectAt: _latest);

      expect(TermMiss.later(missedOnly, clearedOnly).isMissed, isFalse);
      expect(TermMiss.later(clearedOnly, missedOnly).isMissed, isFalse);
    });

    test('a clear the other device has not seen does not resurrect a miss', () {
      // The phone missed the term this morning; the tablet cleared it this
      // afternoon and never saw the miss. The merge has to land on the clear.
      const phone = TermMiss(lastMissedAt: _later);
      const tablet = TermMiss(lastCorrectAt: _latest);

      expect(
        TermMiss.later(phone, tablet),
        const TermMiss(lastMissedAt: _later, lastCorrectAt: _latest),
      );
    });

    test('a miss after a clear survives the join', () {
      const phone = TermMiss(lastMissedAt: _latest);
      const tablet = TermMiss(lastCorrectAt: _later);

      expect(TermMiss.later(phone, tablet).isMissed, isTrue);
    });

    test('the join is idempotent, commutative and associative', () {
      const records = [
        TermMiss.none,
        TermMiss(lastMissedAt: _early),
        TermMiss(lastCorrectAt: _later),
        TermMiss(lastMissedAt: _later, lastCorrectAt: _early),
        TermMiss(lastMissedAt: _early, lastCorrectAt: _latest),
      ];

      for (final a in records) {
        expect(TermMiss.later(a, a), a, reason: 'idempotent over $a');
        for (final b in records) {
          expect(
            TermMiss.later(a, b),
            TermMiss.later(b, a),
            reason: 'commutative over $a and $b',
          );
          for (final c in records) {
            expect(
              TermMiss.later(TermMiss.later(a, b), c),
              TermMiss.later(a, TermMiss.later(b, c)),
              reason: 'associative over $a, $b and $c',
            );
          }
        }
      }
    });
  });
}
