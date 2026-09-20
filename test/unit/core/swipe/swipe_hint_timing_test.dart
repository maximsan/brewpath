import 'package:brew_path/core/swipe/swipe_hint_timing.dart';
import 'package:brew_path/core/swipe/swipe_surface.dart';
import 'package:brew_path/shared/storage/id_set.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the nudge', () {
    test('it goes out and back, twice', () {
      final steps = swipeNudgeSteps(-34);

      expect(steps, hasLength(4));
      expect(steps.map((step) => step.offset), [-34, 0, -22, 0]);
    });

    test('the second nudge is shorter than the first', () {
      final steps = swipeNudgeSteps(40);

      expect(steps[2].offset.abs(), lessThan(steps.first.offset.abs()));
    });

    test('every step lands after the one before it', () {
      final steps = swipeNudgeSteps(-34);

      for (var index = 1; index < steps.length; index++) {
        expect(steps[index].at, greaterThan(steps[index - 1].at));
      }
    });

    test('the caption outlasts the movement', () {
      expect(swipeNudgeSteps(-34).last.at, lessThan(swipeHintDuration));
      expect(swipeHintReducedDuration, greaterThan(swipeHintDuration));
    });
  });

  group('the used list', () {
    test('a surface joins the list without disturbing the rest', () {
      final stored = IdSet.plus('rewards', SwipeSurface.flashcards.id);

      expect(IdSet.decode(stored), {'flashcards', 'rewards'});
    });

    test('an unchanged set writes an unchanged string', () {
      const surfaces = {'rewards', 'challenge', 'dictionary'};

      expect(
        IdSet.encode(surfaces),
        IdSet.encode(surfaces.toList().reversed.toSet()),
      );
    });

    test('an empty column is nobody, not one blank surface', () {
      expect(IdSet.decode(''), isEmpty);
      expect(IdSet.decode(' , '), isEmpty);
    });

    test('an id an older build does not know is kept as read', () {
      final stored = IdSet.plus(
        'a-surface-from-later',
        SwipeSurface.dictionary.id,
      );

      expect(IdSet.decode(stored), contains('a-surface-from-later'));
    });
  });
}
