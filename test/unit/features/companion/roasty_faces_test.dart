import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty_faces.dart';
import 'package:brew_path/features/companion/presentation/roasty_particles.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// One mark the painter drew: the shape's bounds and the colour it asked for.
///
/// Bounds rather than the shape itself, because every mark under test here is
/// an oval or a path the design gives as coordinates — where it sits and how
/// big it is *is* the parity question.
typedef _Mark = ({Rect bounds, Color colour, PaintingStyle style});

/// Records what each drawing call asked for, and ignores the rest.
///
/// `Paint.color` reads back float32-rounded, so the recorded colour never
/// equals the `Color` the painter set. [_Face] compares channels instead.
class _RecordingCanvas implements Canvas {
  final marks = <_Mark>[];

  /// The alpha of each `saveLayer` — how the design's group opacities arrive.
  final layerOpacities = <double>[];

  void _record(Rect bounds, Paint paint) =>
      marks.add((bounds: bounds, colour: paint.color, style: paint.style));

  @override
  void drawOval(Rect rect, Paint paint) => _record(rect, paint);

  @override
  void drawRect(Rect rect, Paint paint) => _record(rect, paint);

  @override
  void drawRRect(RRect rrect, Paint paint) => _record(rrect.outerRect, paint);

  @override
  void drawPath(Path path, Paint paint) => _record(path.getBounds(), paint);

  @override
  void drawCircle(Offset c, double radius, Paint paint) =>
      _record(Rect.fromCircle(center: c, radius: radius), paint);

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) =>
      _record(Rect.fromPoints(p1, p2), paint);

  @override
  void saveLayer(Rect? bounds, Paint paint) =>
      layerOpacities.add(paint.color.a);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// The marks one face painted, with the questions this parity check asks of
/// them.
extension type _Face(_RecordingCanvas _canvas) {
  /// Paints [state]'s face and captures every mark.
  factory _Face.of(RoastyState state, {MoodColors? mood}) {
    final canvas = _RecordingCanvas();
    paintRoastyFace(canvas, state, mood ?? MoodColors.darkRoast);
    return _Face(canvas);
  }

  List<_Mark> get marks => _canvas.marks;

  /// The marks drawn in [colour] at [opacity].
  ///
  /// Every channel is compared with a tolerance well under one 8-bit step
  /// (1/255), because `Paint.color` reads back float32-rounded and so never
  /// equals the `Color` the painter set.
  Iterable<_Mark> drawnIn(Color colour, {required double opacity}) =>
      marks.where(
        (mark) =>
            _sameChannel(mark.colour.r, colour.r) &&
            _sameChannel(mark.colour.g, colour.g) &&
            _sameChannel(mark.colour.b, colour.b) &&
            _sameChannel(mark.colour.a, opacity),
      );

  /// Whether a **filled** mark in [colour] at [opacity] starts at [left] and
  /// runs [width] wide, with its top edge at [top].
  ///
  /// The curves' *height* is deliberately not asserted: `Path.getBounds`
  /// bounds a quadratic by its control points rather than the curve, so the
  /// bottom edge it reports is not a fact about the drawing. Every value
  /// checked here is an on-curve endpoint, which is exact.
  bool hasFilledCurve(
    Color colour, {
    required double left,
    required double top,
    required double width,
    required double opacity,
  }) => drawnIn(colour, opacity: opacity).any(
    (mark) =>
        mark.style == PaintingStyle.fill &&
        (mark.bounds.left - left).abs() < 0.51 &&
        (mark.bounds.top - top).abs() < 0.51 &&
        (mark.bounds.width - width).abs() < 0.51,
  );

  /// Whether a mark of [width] x [height] sits centred on ([cx], [cy]), drawn
  /// in [colour] at [opacity].
  bool has(
    Color colour, {
    required double cx,
    required double cy,
    required double width,
    required double height,
    required double opacity,
  }) => drawnIn(colour, opacity: opacity).any(
    (mark) =>
        (mark.bounds.center.dx - cx).abs() < 0.51 &&
        (mark.bounds.center.dy - cy).abs() < 0.51 &&
        (mark.bounds.width - width).abs() < 0.51 &&
        (mark.bounds.height - height).abs() < 0.51,
  );
}

/// Whether two colour channels agree to within half an 8-bit step.
bool _sameChannel(double drawn, double wanted) =>
    (drawn - wanted).abs() < 0.002;

/// The blush the design gives each face, as `cy`, radii and opacity.
///
/// Every face in `prototype/roasty.jsx` blushes, and no two states agree on
/// how much: the alpha carries the mood of the state. Written as the source
/// writes them — SVG radii, doubled below into the diameters Flutter draws.
const _cheeks = <RoastyState, ({double cy, double rx, double ry, double at})>{
  RoastyState.idle: (cy: 172, rx: 6, ry: 3, at: 0.45),
  RoastyState.correct: (cy: 170, rx: 7, ry: 3.5, at: 0.55),
  RoastyState.lesson: (cy: 170, rx: 7, ry: 3.5, at: 0.55),
  RoastyState.wrong: (cy: 174, rx: 5, ry: 2.5, at: 0.3),
  RoastyState.module: (cy: 172, rx: 7, ry: 3.5, at: 0.55),
  RoastyState.card: (cy: 172, rx: 7, ry: 3.5, at: 0.5),
  RoastyState.sleep: (cy: 172, rx: 6, ry: 3, at: 0.35),
  RoastyState.awake: (cy: 172, rx: 6, ry: 3, at: 0.4),
};

/// The design draws both cheeks at the same height, mirrored about the face.
const _cheekLeft = 68.0;
const _cheekRight = 132.0;

void main() {
  group('every face blushes, as the design draws it', () {
    // The app drew cheeks on three faces of eight. The other five were bare —
    // and the alphas are per-state, so a single shared cheek cannot be right
    // for more than one of them.
    for (final state in RoastyState.values) {
      final cheek = _cheeks[state]!;

      test('${state.name}: a pair at ${cheek.at} opacity', () {
        final face = _Face.of(state);

        for (final cx in const [_cheekLeft, _cheekRight]) {
          expect(
            face.has(
              RoastyColors.blush,
              cx: cx,
              cy: cheek.cy,
              width: cheek.rx * 2,
              height: cheek.ry * 2,
              opacity: cheek.at,
            ),
            isTrue,
            reason:
                'the ${state.name} face draws no blush at ($cx, ${cheek.cy}) '
                'sized ${cheek.rx * 2}x${cheek.ry * 2} at ${cheek.at}',
          );
        }
      });
    }
  });

  group('the mouths the design opens', () {
    test('the lesson face opens its mouth, and shows a tongue', () {
      // It had been reusing the correct face's stroked smile, so finishing a
      // lesson and getting an answer right looked identical.
      final face = _Face.of(RoastyState.lesson);

      expect(
        face.hasFilledCurve(
          RoastyColors.mouth,
          left: 84,
          top: 178,
          width: 32,
          opacity: 1,
        ),
        isTrue,
        reason:
            'the lesson face draws no filled open mouth spanning 84 to 116 '
            'from y 178 — a stroked smile is the correct face, not this one',
      );
      expect(
        face.hasFilledCurve(
          RoastyColors.blush,
          left: 92,
          top: 186,
          width: 16,
          opacity: 0.7,
        ),
        isTrue,
        reason: 'no tongue inside the lesson face\'s open mouth',
      );
    });

    test('the lesson face is no longer the correct face', () {
      final lesson = _Face.of(RoastyState.lesson);
      final correct = _Face.of(RoastyState.correct);

      expect(
        lesson.marks.map((mark) => mark.bounds),
        isNot(correct.marks.map((mark) => mark.bounds)),
      );
    });

    test('the module face shows a tongue under its open mouth', () {
      final face = _Face.of(RoastyState.module);

      expect(
        face.has(
          RoastyColors.mouth,
          cx: 100,
          cy: 185,
          width: 16,
          height: 18,
          opacity: 1,
        ),
        isTrue,
        reason: 'no open mouth on the module face',
      );
      expect(
        face.has(
          RoastyColors.blush,
          cx: 100,
          cy: 188,
          width: 10,
          height: 8,
          opacity: 0.7,
        ),
        isTrue,
        reason: 'no tongue on the module face',
      );
    });
  });

  test('the wrong badge fades as one group, not mark by mark', () {
    // The design sets `opacity="0.85"` on the badge's group. Fading each mark
    // instead would show the white disc through the berry stroke and the
    // exclamation drawn on top of it.
    final canvas = _RecordingCanvas();
    paintRoastyParticlesFront(
      canvas,
      RoastyState.wrong,
      0,
      MoodColors.darkRoast,
    );

    expect(canvas.layerOpacities, hasLength(1));
    expect(canvas.layerOpacities.single, closeTo(0.85, 0.005));
    expect(
      canvas.marks.map((mark) => mark.colour.a),
      everyElement(closeTo(1, 0.005)),
      reason: 'a mark carries its own fade as well as the group\'s',
    );
  });
}
