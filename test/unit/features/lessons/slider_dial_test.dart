import 'package:brew_path/features/lessons/presentation/cards/slider_dial.dart';
import 'package:flutter_test/flutter_test.dart';

/// The five-band scale every shipped grind round is authored against.
const _grindScale = [
  'Powder — chokes the machine',
  'Fine — espresso',
  'Table salt — moka, AeroPress',
  'Sea salt — pour-over',
  'Breadcrumbs — French press',
];

void main() {
  group('sliderBands', () {
    test('a round reads back in the words it authored', () {
      expect(
        sliderBands(
          scale: _grindScale,
          leftLabel: 'FINER',
          rightLabel: 'COARSER',
        ),
        _grindScale,
      );
    });

    // Unreachable against today's banks — every shipped round carries a scale
    // — and the reason it exists is that the bands are the whole point: a
    // position on a track has to read as something concrete, and a round
    // authored without one is exactly where that would quietly stop.
    test('a round with none falls back to its own ends, never a number', () {
      final bands = sliderBands(
        scale: const [],
        leftLabel: 'COOLER',
        rightLabel: 'HOTTER',
      );

      expect(bands, [
        'Very COOLER',
        'COOLER',
        'Middle',
        'HOTTER',
        'Very HOTTER',
      ]);
      expect(
        sliderBandIndex(value: sliderTrackStart, bandCount: bands.length),
        2,
      );
    });
  });

  group('sliderBandIndex', () {
    test('reads the band a setting falls in', () {
      // The five shipped bands are 20 wide each.
      expect(sliderBandIndex(value: 0, bandCount: 5), 0);
      expect(sliderBandIndex(value: 28, bandCount: 5), 1);
      expect(sliderBandIndex(value: 50, bandCount: 5), 2);
      expect(sliderBandIndex(value: 88, bandCount: 5), 4);
    });

    test('a band owns its lower edge', () {
      expect(sliderBandIndex(value: 20, bandCount: 5), 1);
      expect(sliderBandIndex(value: 19.9, bandCount: 5), 0);
    });

    // The one that would otherwise read past the end of the scale and throw
    // mid-round, on the value a learner reaches by dragging to the far end.
    test('the top of the track belongs to the last band', () {
      expect(
        sliderBandIndex(value: sliderTrackMax, bandCount: _grindScale.length),
        _grindScale.length - 1,
      );
    });

    test('one band swallows the whole track', () {
      expect(sliderBandIndex(value: 0, bandCount: 1), 0);
      expect(sliderBandIndex(value: sliderTrackMax, bandCount: 1), 0);
    });
  });

  group('sliderWithinTarget', () {
    test('inside the band is right', () {
      expect(
        sliderWithinTarget(value: 30, target: 28, tolerance: 11),
        isTrue,
      );
    });

    test('outside it is not', () {
      expect(
        sliderWithinTarget(value: 50, target: 28, tolerance: 11),
        isFalse,
      );
    });

    // The band is drawn as well as graded, so a learner who lands exactly on
    // the edge they can see has to be right or the drawing is a lie.
    test('both edges of the band count', () {
      expect(sliderWithinTarget(value: 17, target: 28, tolerance: 11), isTrue);
      expect(sliderWithinTarget(value: 39, target: 28, tolerance: 11), isTrue);
      expect(
        sliderWithinTarget(value: 39.1, target: 28, tolerance: 11),
        isFalse,
      );
    });
  });

  group('sliderTargetZone', () {
    test('spans the tolerance either side of the target', () {
      final zone = sliderTargetZone(target: 50, tolerance: 13);

      expect(zone.start, 37);
      expect(zone.width, 26);
    });

    // A target near either end has a band that runs off the track. Unclamped,
    // the band would be painted past the rail it is measured against.
    test('a band at the low end is clipped to the track', () {
      final zone = sliderTargetZone(target: 5, tolerance: 12);

      expect(zone.start, sliderTrackMin);
      expect(zone.width, 17);
    });

    test('a band at the high end is clipped too', () {
      final zone = sliderTargetZone(target: 93, tolerance: 8);

      expect(zone.start, 85);
      expect(zone.start + zone.width, sliderTrackMax);
    });
  });

  group('sliderIsGrind', () {
    test('the grind axis draws the collar', () {
      expect(
        sliderIsGrind(leftLabel: 'FINER', rightLabel: 'COARSER'),
        isTrue,
      );
    });

    test('every other axis does not', () {
      expect(
        sliderIsGrind(leftLabel: 'COOLER', rightLabel: 'HOTTER'),
        isFalse,
      );
      expect(
        sliderIsGrind(leftLabel: 'STRONGER', rightLabel: 'WEAKER'),
        isFalse,
      );
      // One end alone is not the axis: a round that runs from FINER to
      // SLOWER is not about grind, whatever its left label says.
      expect(
        sliderIsGrind(leftLabel: 'FINER', rightLabel: 'SLOWER'),
        isFalse,
      );
    });
  });
}
