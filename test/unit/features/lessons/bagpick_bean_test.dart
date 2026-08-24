import 'dart:math' as math;

import 'package:brew_path/features/lessons/presentation/cards/bagpick_bean.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// The two things about a green bean that no widget test can see.
///
/// A colour is not something a widget test asserts well, and patch placement
/// seeded per bean is invisible to any assertion about rendered text. Both are
/// pure functions precisely so they can be asked here — and in a game whose
/// mechanic is *judging the process from the look of the seed*, being wrong
/// about either produces a bean that draws perfectly and lies.
void main() {
  group('a bean colour', () {
    test('resolves a design-source token to the palette', () {
      // Two of the five authored bags carry their colours this way rather than
      // as hex, because that is what the author wrote.
      expect(beanColour('var(--art-cherry-seed)'), ArtColors.cherrySeed);
      expect(beanColour('var(--art-cherry-gel)'), ArtColors.cherryGel);
    });

    test('parses a hex literal', () {
      expect(beanColour('#9E7C45'), const Color(0xFF9E7C45));
      expect(beanColour('#f0e9d9'), const Color(0xFFF0E9D9));
    });

    test('tolerates surrounding space and inner space in var()', () {
      expect(beanColour('  #9E7C45  '), const Color(0xFF9E7C45));
      expect(beanColour('var( --art-cherry-seed )'), ArtColors.cherrySeed);
    });

    test('throws on a token the palette does not carry', () {
      // The whole reason this is a function. A fallback would draw a plausible
      // bean of the wrong process, and nobody reviewing a screenshot of five
      // green beans would catch it.
      expect(
        () => beanColour('var(--art-not-a-colour)'),
        throwsArgumentError,
      );
    });

    test('throws on anything that is neither form', () {
      for (final bad in ['', 'green', '#ABC', '#GGGGGG', 'rgb(1,2,3)']) {
        expect(
          () => beanColour(bad),
          throwsArgumentError,
          reason: '"$bad" was accepted as a bean colour',
        );
      }
    });
  });

  group('the mottling', () {
    test('a clean bean has none', () {
      expect(beanPatches(mottle: 0, seed: 0), isEmpty);
    });

    test('each mottle step adds three patches', () {
      expect(beanPatches(mottle: 1, seed: 0), hasLength(3));
      expect(beanPatches(mottle: 2, seed: 0), hasLength(6));
    });

    test('the same bean draws the same patches every time', () {
      final first = beanPatches(mottle: 2, seed: 1);
      final second = beanPatches(mottle: 2, seed: 1);

      for (var index = 0; index < first.length; index++) {
        expect(first[index].centre, second[index].centre);
        expect(first[index].radius, second[index].radius);
        expect(first[index].opacity, second[index].opacity);
      }
    });

    test('the three beans of a sample differ from one another', () {
      // Otherwise the sample reads as one bean drawn three times, which is not
      // a sample at all.
      final centres = [
        for (var seed = 0; seed < 3; seed++)
          beanPatches(mottle: 2, seed: seed).first.centre,
      ];

      expect(centres.toSet(), hasLength(3));
    });

    test('every patch lands inside the bean', () {
      // The reason placement is polar rather than a pair of independent
      // offsets: patches that fell outside would need clipping to hide, and
      // clipping hides the bug rather than the patch.
      final body = beanBody;
      for (var seed = 0; seed < 6; seed++) {
        for (final patch in beanPatches(mottle: 3, seed: seed)) {
          final normalisedX =
              (patch.centre.dx - body.center.dx) / (body.width / 2);
          final normalisedY =
              (patch.centre.dy - body.center.dy) / (body.height / 2);
          final distance = math.sqrt(
            normalisedX * normalisedX + normalisedY * normalisedY,
          );

          expect(
            distance,
            lessThan(1),
            reason: 'a patch escaped the bean at seed $seed',
          );
        }
      }
    });

    test('every patch is faint enough to read as mottling', () {
      for (final patch in beanPatches(mottle: 3, seed: 2)) {
        expect(patch.opacity, greaterThan(0));
        expect(
          patch.opacity,
          lessThan(0.31),
          reason: 'a patch this strong reads as a hole, not as mottling',
        );
      }
    });
  });

  group('the chaff', () {
    test('appears only when the round says the sample has any', () {
      expect(beanChaff(chaff: false), isEmpty);
      expect(beanChaff(chaff: true), isNotEmpty);
    });

    test('sits in the crease rather than out on the face', () {
      // It is silverskin left in the fold, so it has to read as being in the
      // fold — off to one side it looks like a defect in the seed instead.
      for (final fleck in beanChaff(chaff: true)) {
        expect((fleck.centre.dx - beanBody.center.dx).abs(), lessThan(1.5));
      }
    });
  });
}
