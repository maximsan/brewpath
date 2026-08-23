import 'package:brew_path/features/lessons/presentation/cards/bagpick_bean_art.dart';
import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

BagpickBean _bean({int mottle = 0, bool chaff = false}) => BagpickBean(
  body: 'var(--art-cherry-seed)',
  crease: '#F0E9D9',
  mottle: mottle,
  chaff: chaff,
);

/// The bean drawing's arithmetic, with no canvas in sight. A seeded scatter
/// that silently drifts would still *look* like beans, so the properties worth
/// pinning are the ones an eye cannot check: that a colour resolves to the
/// palette rather than to something plausible, and that the same seed draws
/// the same bean twice.
void main() {
  group('colours the design source authored', () {
    test('a var() token resolves to the illustration palette', () {
      expect(beanColour('var(--art-cherry-seed)'), ArtColors.cherrySeed);
    });

    test('a bare token name resolves too', () {
      expect(beanColour('--art-cherry-seed'), ArtColors.cherrySeed);
    });

    test('a hex literal resolves to itself', () {
      expect(beanColour('#F0E9D9'), const Color(0xFFF0E9D9));
    });

    test('a token the palette does not carry throws', () {
      expect(() => beanColour('var(--art-nonsense)'), throwsArgumentError);
    });

    test('a colour notation we do not handle throws', () {
      expect(() => beanColour('rgb(1,2,3)'), throwsArgumentError);
    });
  });

  group('the mottling scatter', () {
    test('draws three patches per mottle step', () {
      expect(mottlePatches(_bean(), seed: 0), isEmpty);
      expect(mottlePatches(_bean(mottle: 2), seed: 0), hasLength(6));
    });

    test('the same seed draws the same bean twice', () {
      final first = mottlePatches(_bean(mottle: 3), seed: 1);
      final again = mottlePatches(_bean(mottle: 3), seed: 1);

      expect(first.map((p) => p.centre), again.map((p) => p.centre));
      expect(first.map((p) => p.radius), again.map((p) => p.radius));
    });

    test('a different seed draws a different bean', () {
      final one = mottlePatches(_bean(mottle: 3), seed: 1);
      final two = mottlePatches(_bean(mottle: 3), seed: 2);

      expect(one.map((p) => p.centre), isNot(two.map((p) => p.centre)));
    });

    test('every patch lands inside the bean', () {
      for (var seed = 0; seed < 8; seed++) {
        for (final patch in mottlePatches(_bean(mottle: 3), seed: seed)) {
          final dx = (patch.centre.dx - beanCentre.dx).abs();
          final dy = (patch.centre.dy - beanCentre.dy).abs();
          expect(
            dx <= beanRadius.width && dy <= beanRadius.height,
            isTrue,
            reason: 'patch at ${patch.centre} escaped the bean on seed $seed',
          );
        }
      }
    });

    test('opacity stays within the authored band', () {
      for (final patch in mottlePatches(_bean(mottle: 3), seed: 4)) {
        expect(patch.opacity, inInclusiveRange(0.16, 0.30));
      }
    });
  });
}
