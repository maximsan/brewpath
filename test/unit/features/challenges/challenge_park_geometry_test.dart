import 'package:brew_path/features/challenges/presentation/challenge_park_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the track behind the card', () {
    test('is invisible at rest', () {
      expect(challengeTrackReveal(0), 0);
    });

    test('is fully uncovered well before the card commits', () {
      expect(challengeTrackReveal(challengeTrackRevealAt), 1);
      expect(challengeTrackRevealAt, lessThan(challengeParkAt));
    });

    test('rises with the card between the two', () {
      expect(challengeTrackReveal(challengeTrackRevealAt / 2), 0.5);
    });

    test('stays hidden for a wrong-way drag, which parks nothing', () {
      expect(challengeTrackReveal(-90), 0);
    });

    test('never passes one, however far the card is dragged', () {
      expect(challengeTrackReveal(challengeParkMaxDrag), 1);
    });
  });

  group('the chevron', () {
    test('is brightest while the hint is teaching the gesture', () {
      expect(challengeChevronOpacity(hinting: true, used: false), 1);
      expect(challengeChevronOpacity(hinting: true, used: true), 1);
    });

    test('steps back once the gesture has been used, and never to nothing', () {
      final quiet = challengeChevronOpacity(hinting: false, used: true);
      final standing = challengeChevronOpacity(hinting: false, used: false);

      expect(quiet, lessThan(standing));
      expect(quiet, greaterThan(0));
    });
  });
}
