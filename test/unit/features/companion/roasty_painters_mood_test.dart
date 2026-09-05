import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty_faces.dart';
import 'package:brew_path/features/companion/presentation/roasty_particles.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the colour of every paint handed to it, and ignores the rest.
///
/// The painters draw onto a real canvas in the app; here the question is only
/// *which colour* each mark asked for, and a recorded picture cannot answer
/// that. Every other canvas call is a no-op.
class _RecordingCanvas implements Canvas {
  final colours = <Color>[];

  void _record(Paint paint) => colours.add(paint.color);

  @override
  void drawPath(Path path, Paint paint) => _record(paint);

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) => _record(paint);

  @override
  void drawCircle(Offset c, double radius, Paint paint) => _record(paint);

  @override
  void drawOval(Rect rect, Paint paint) => _record(paint);

  @override
  void drawRect(Rect rect, Paint paint) => _record(paint);

  @override
  void drawRRect(RRect rrect, Paint paint) => _record(paint);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// The RGB bits of a colour, without its alpha.
const _rgbMask = 0x00FFFFFF;

/// Whether any recorded mark is [colour] at any opacity — the design sets its
/// alphas per mark, and only the hue is under test here. Compared as 8-bit
/// channels because `Paint.color` reads back float32-rounded components that
/// no longer equal the `Color` the painter set.
bool _uses(List<Color> colours, Color colour) => colours.any(
  (recorded) => recorded.toARGB32() & _rgbMask == colour.toARGB32() & _rgbMask,
);

const _moods = <(String, MoodColors)>[
  ('cupping', MoodColors.cupping),
  ('darkRoast', MoodColors.darkRoast),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The mascot component gives these marks to the mood: the module stars and
  /// rays and two sparkles are `--warn`, the wrong badge `--berry`, the
  /// sleeping `z`s `--ink-mute`. The other mood's value must be absent too, or
  /// a painter pinned to Cupping would pass under Cupping.
  for (final (name, mood) in _moods) {
    final other = mood == MoodColors.cupping
        ? MoodColors.darkRoast
        : MoodColors.cupping;

    group('under $name', () {
      test("the module face stars are the mood's warn", () {
        final canvas = _RecordingCanvas();
        paintRoastyFace(canvas, RoastyState.module, mood);
        expect(_uses(canvas.colours, mood.warn), isTrue);
        expect(_uses(canvas.colours, other.warn), isFalse);
      });

      test("the module rays are the mood's warn", () {
        final canvas = _RecordingCanvas();
        paintRoastyParticlesBack(canvas, RoastyState.module, 0, mood);
        expect(_uses(canvas.colours, mood.warn), isTrue);
        expect(_uses(canvas.colours, other.warn), isFalse);
      });

      test("the wrong badge is the mood's berry on the eye white", () {
        final canvas = _RecordingCanvas();
        paintRoastyParticlesFront(canvas, RoastyState.wrong, 0, mood);
        expect(_uses(canvas.colours, mood.berry), isTrue);
        expect(_uses(canvas.colours, other.berry), isFalse);
        expect(_uses(canvas.colours, RoastyColors.eyeWhite), isTrue);
      });

      test("the sparkles are the mood's warn beside two fixed confetti", () {
        final canvas = _RecordingCanvas();
        paintRoastyParticlesFront(canvas, RoastyState.correct, 0, mood);
        expect(_uses(canvas.colours, mood.warn), isTrue);
        expect(_uses(canvas.colours, other.warn), isFalse);
        expect(_uses(canvas.colours, RoastyColors.confettiMoss), isTrue);
        expect(_uses(canvas.colours, RoastyColors.confettiEmber), isTrue);
      });

      test("the sleeping z is the mood's muted ink", () {
        final style = roastySleepZStyle(mood: mood, size: 18, opacity: 0.5);
        expect(style.color, mood.inkMute.withValues(alpha: 0.5));
      });
    });
  }

  test('the confetti is fixed in both moods', () {
    for (final (_, mood) in _moods) {
      final canvas = _RecordingCanvas();
      paintRoastyParticlesFront(canvas, RoastyState.lesson, 0, mood);
      expect(_uses(canvas.colours, RoastyColors.confettiEmber), isTrue);
      expect(_uses(canvas.colours, RoastyColors.confettiMoss), isTrue);
      expect(_uses(canvas.colours, RoastyColors.confettiGold), isTrue);
    }
  });
}
