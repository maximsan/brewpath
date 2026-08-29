import 'package:brew_path/features/lessons/presentation/cards/grinder_dial.dart';
import 'package:brew_path/features/lessons/presentation/cards/slider_dial.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether [point] is on or inside the dial's top face, allowing for the
/// rounding a trigonometric coordinate carries.
bool _onTheFace(Offset point) {
  final face = grinderFace;
  final normalisedX = (point.dx - grinderCentre.dx) / (face.width / 2);
  final normalisedY = (point.dy - grinderCentre.dy) / (face.height / 2);
  return normalisedX * normalisedX + normalisedY * normalisedY <= 1.001;
}

void main() {
  group('grinderClicks', () {
    test('reads the collar end to end', () {
      expect(grinderClicks(sliderTrackMin), 0);
      expect(grinderClicks(sliderTrackMax), grinderClickSpan);
    });

    test('the centre of the track is the middle of the collar', () {
      expect(grinderClicks(sliderTrackStart), grinderClickSpan ~/ 2);
    });
  });

  group('grinderMarker', () {
    test('rides the face rather than wandering off it', () {
      for (var value = sliderTrackMin; value <= sliderTrackMax; value += 5) {
        expect(
          _onTheFace(grinderMarker(value)),
          isTrue,
          reason: 'the marker left the dial at $value',
        );
      }
    });

    test('sweeps as the setting rises', () {
      // Fine sits at upper-left and coarse at upper-right, so the marker
      // travels rightward across the near edge.
      expect(
        grinderMarker(sliderTrackMax).dx,
        greaterThan(grinderMarker(sliderTrackMin).dx),
      );
    });
  });

  group('grinderTicks', () {
    test('every tick sits on the face, inner end nearer the centre', () {
      for (final tick in grinderTicks(sliderTrackStart)) {
        expect(_onTheFace(tick.outer), isTrue);
        expect(
          (tick.inner - grinderCentre).distance,
          lessThan((tick.outer - grinderCentre).distance),
        );
      }
    });

    test('none are lit at the low end and all are at the high end', () {
      final low = grinderTicks(sliderTrackMin);
      final high = grinderTicks(sliderTrackMax);

      // The first tick is where the marker starts, so it is lit from the off.
      expect(low.where((tick) => tick.passed), hasLength(1));
      expect(high.every((tick) => tick.passed), isTrue);
    });

    test('the lit count only ever grows with the setting', () {
      var previous = 0;
      for (var value = sliderTrackMin; value <= sliderTrackMax; value += 5) {
        final lit = grinderTicks(value).where((tick) => tick.passed).length;
        expect(lit, greaterThanOrEqualTo(previous));
        previous = lit;
      }
    });
  });

  group('grinderRim', () {
    test('is drawn under the face, within the canvas', () {
      expect(grinderRim().getBounds().top, grinderCentre.dy);
      expect(
        grinderRim().getBounds().bottom,
        lessThanOrEqualTo(grinderCanvas.height),
      );
    });
  });
}
