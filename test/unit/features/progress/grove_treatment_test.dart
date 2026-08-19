import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/shared/models/content/grove_light.dart';
import 'package:brew_path/shared/models/content/grove_variety.dart';
import 'package:flutter_test/flutter_test.dart';

/// A stand-in bank, so the pure layer is tested without loading an asset.
const _arabica = GroveVariety(
  id: 'arabica',
  name: 'Arabica',
  latin: 'Coffea arabica',
  share: '~60%',
  use: 'Filter',
  origin: 'Ethiopia',
  grows: 'High and cool',
  cup: 'Sweet',
  tell: 'Tall and slim.',
  shape: 'none',
  leaf: '',
  drop: 'launch',
);

const _robusta = GroveVariety(
  id: 'robusta',
  name: 'Robusta',
  latin: 'Coffea canephora',
  share: '~35%',
  use: 'Espresso',
  origin: 'West Africa',
  grows: 'Low and warm',
  cup: 'Bold',
  tell: 'Broader and bushier.',
  shape: 'scale(1.2, 0.9)',
  leaf: 'saturate(1.2) hue-rotate(-8deg) brightness(0.94)',
  drop: 'launch',
);

const _daylight = GroveLight(
  id: 'daylight',
  name: 'Daylight',
  note: 'No filter',
  swatch: '#6B7F5A',
  filter: '',
);

const _moonlit = GroveLight(
  id: 'moonlit',
  name: 'Moonlit',
  note: 'Cool night',
  swatch: '#7E93A8',
  filter: 'saturate(0.6) hue-rotate(150deg) brightness(0.96) contrast(1.06)',
);

const List<GroveVariety> _varieties = [_arabica, _robusta];
const List<GroveLight> _lights = [_daylight, _moonlit];

/// Flutter's colour matrices are 4 rows of 5.
const _matrixLength = 20;

void main() {
  group('colorMatrixFromFilters', () {
    test('an empty chain is the identity', () {
      expect(colorMatrixFromFilters(''), identityColorMatrix);
      expect(colorMatrixFromFilters('   '), identityColorMatrix);
    });

    test('the matrix is always four rows of five', () {
      expect(colorMatrixFromFilters(_moonlit.filter), hasLength(_matrixLength));
      expect(identityColorMatrix, hasLength(_matrixLength));
    });

    test('brightness scales the colour channels and leaves alpha alone', () {
      final matrix = colorMatrixFromFilters('brightness(0.5)');

      expect(matrix[0], closeTo(0.5, 1e-9)); // red ← red
      expect(matrix[6], closeTo(0.5, 1e-9)); // green ← green
      expect(matrix[12], closeTo(0.5, 1e-9)); // blue ← blue
      expect(matrix[18], closeTo(1, 1e-9)); // alpha ← alpha
      // No channel bleed and no offset.
      expect(matrix[1], closeTo(0, 1e-9));
      expect(matrix[4], closeTo(0, 1e-9));
    });

    test('contrast offsets in Flutter units, not fractions', () {
      // A slope of c pivots around mid-grey, so the intercept is
      // (1 - c) / 2 — expressed against the 0–255 range the matrix's fifth
      // column carries, which is the convention a fraction here would break.
      final matrix = colorMatrixFromFilters('contrast(0.5)');

      expect(matrix[0], closeTo(0.5, 1e-9));
      expect(matrix[4], closeTo(0.25 * 255, 1e-6));
    });

    test('a saturate of one changes nothing', () {
      expect(
        colorMatrixFromFilters('saturate(1)'),
        pairwiseCloseTo(identityColorMatrix),
      );
    });

    test('a hue rotation of zero changes nothing', () {
      expect(
        colorMatrixFromFilters('hue-rotate(0deg)'),
        pairwiseCloseTo(identityColorMatrix),
      );
    });

    test('a fully desaturating chain maps the channels to one luminance', () {
      final matrix = colorMatrixFromFilters('saturate(0)');

      // Every output row becomes the same luminance weights, so the three
      // channels collapse to one grey.
      for (final row in [0, 1, 2]) {
        expect(matrix[row * 5 + 0], closeTo(0.213, 1e-3));
        expect(matrix[row * 5 + 1], closeTo(0.715, 1e-3));
        expect(matrix[row * 5 + 2], closeTo(0.072, 1e-3));
      }
    });

    test('is deterministic for the same chain', () {
      expect(
        colorMatrixFromFilters(_moonlit.filter),
        colorMatrixFromFilters(_moonlit.filter),
      );
    });

    test('composes in the order the chain lists', () {
      // brightness then contrast is not contrast then brightness: the
      // contrast offset is scaled by whichever brightness follows it.
      expect(
        colorMatrixFromFilters('brightness(0.5) contrast(2)'),
        isNot(
          pairwiseCloseTo(
            colorMatrixFromFilters('contrast(2) brightness(0.5)'),
          ),
        ),
      );
    });

    test('an unreadable term is skipped rather than throwing', () {
      // The extractor refuses these, so reaching here means a bank written by
      // a newer build. Degrading to the identity beats crashing the Profile.
      expect(colorMatrixFromFilters('blur(2px)'), identityColorMatrix);
    });
  });

  group('silhouetteFromShape', () {
    test('none and empty are the unscaled plant', () {
      expect(silhouetteFromShape('none'), GroveSilhouette.unscaled);
      expect(silhouetteFromShape(''), GroveSilhouette.unscaled);
    });

    test('reads the decided anisotropic scale', () {
      expect(
        silhouetteFromShape(_robusta.shape),
        const GroveSilhouette(1.2, 0.9),
      );
      expect(
        silhouetteFromShape('scale(1.1, 1.12)'),
        const GroveSilhouette(1.1, 1.12),
      );
    });

    test('a single argument scales both axes', () {
      expect(
        silhouetteFromShape('scale(1.5)'),
        const GroveSilhouette(1.5, 1.5),
      );
    });

    test('an unreadable shape is the unscaled plant', () {
      expect(silhouetteFromShape('rotate(4deg)'), GroveSilhouette.unscaled);
    });
  });

  group('groveTreatmentFor', () {
    test('Arabica in Daylight is the identity on both channels', () {
      final treatment = groveTreatmentFor(
        varieties: _varieties,
        lights: _lights,
        variety: 'arabica',
        light: 'daylight',
      );

      expect(treatment.colorMatrix, identityColorMatrix);
      expect(treatment.silhouette, GroveSilhouette.unscaled);
      expect(treatment.isIdentity, isTrue);
    });

    test('Robusta carries its scale, and Moonlit tints it', () {
      final treatment = groveTreatmentFor(
        varieties: _varieties,
        lights: _lights,
        variety: 'robusta',
        light: 'moonlit',
      );

      expect(treatment.silhouette, const GroveSilhouette(1.2, 0.9));
      expect(treatment.colorMatrix, isNot(identityColorMatrix));
      expect(treatment.isIdentity, isFalse);
    });

    test('a light changes the tint without touching the silhouette', () {
      final day = groveTreatmentFor(
        varieties: _varieties,
        lights: _lights,
        variety: 'robusta',
        light: 'daylight',
      );
      final night = groveTreatmentFor(
        varieties: _varieties,
        lights: _lights,
        variety: 'robusta',
        light: 'moonlit',
      );

      expect(day.silhouette, night.silhouette);
      expect(day.colorMatrix, isNot(night.colorMatrix));
    });

    test('an unknown id falls back to the default axis value', () {
      final unknown = groveTreatmentFor(
        varieties: _varieties,
        lights: _lights,
        variety: 'excelsa',
        light: 'eclipse',
      );
      final fallback = groveTreatmentFor(
        varieties: _varieties,
        lights: _lights,
        variety: 'arabica',
        light: 'daylight',
      );

      expect(unknown.colorMatrix, fallback.colorMatrix);
      expect(unknown.silhouette, fallback.silhouette);
    });

    test('the fallback is the named default, not whatever sorts first', () {
      // Robusta first, so a fallback that took the bank's first entry would
      // quietly hand back a scaled silhouette for an unknown plant.
      final treatment = groveTreatmentFor(
        varieties: const [_robusta, _arabica],
        lights: const [_moonlit, _daylight],
        variety: 'excelsa',
        light: 'eclipse',
      );

      expect(treatment.silhouette, GroveSilhouette.unscaled);
      expect(treatment.colorMatrix, identityColorMatrix);
    });

    test('an empty bank still yields a renderable treatment', () {
      // A bank that failed to load must not take the Profile down with it.
      final treatment = groveTreatmentFor(
        varieties: const [],
        lights: const [],
        variety: 'arabica',
        light: 'daylight',
      );

      expect(treatment.isIdentity, isTrue);
    });
  });
}

/// Element-wise closeness, since matrix products accumulate float error.
Matcher pairwiseCloseTo(List<double> expected) => predicate<List<double>>((
  actual,
) {
  if (actual.length != expected.length) return false;
  for (var index = 0; index < actual.length; index++) {
    if ((actual[index] - expected[index]).abs() > 1e-6) return false;
  }
  return true;
}, 'matches $expected element-wise');
