import 'dart:io';

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty_faces.dart';
import 'package:brew_path/features/companion/presentation/roasty_particles.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/roasty_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The mascot component the app's drawings are ported from.
///
/// Read rather than transcribed. A table of numbers typed out of the design
/// only proves the app still draws what it drew yesterday; parsing the source
/// makes this a parity test, so a nudge or a retone in the design fails here
/// instead of passing unnoticed.
final String _jsx = File('prototype/roasty.jsx').readAsStringSync();

/// The `className` the design files each state's face under. The app's names
/// and the design's disagree in one place — `idle` is drawn as `face-default`
/// — so the mapping is written out rather than derived.
const _designGroup = <RoastyState, String>{
  RoastyState.idle: 'face-default',
  RoastyState.correct: 'face-correct',
  RoastyState.wrong: 'face-wrong',
  RoastyState.lesson: 'face-lesson',
  RoastyState.module: 'face-module',
  RoastyState.points: 'face-points',
  RoastyState.card: 'face-card',
  RoastyState.sleep: 'face-sleep',
  RoastyState.awake: 'face-awake',
};

/// One mark the painter drew: its bounds, its colour, and whether it was
/// filled or stroked.
typedef _Mark = ({Rect bounds, Color colour, PaintingStyle style});

/// An ellipse as the design writes one — SVG radii, not Flutter's diameters.
typedef _Ellipse = ({double cx, double cy, double rx, double ry, double at});

/// Half an 8-bit colour step, under the smallest difference the design could
/// have meant.
const _channel = 0.002;

/// Half a canvas unit, the finest the design places anything on.
const _unit = 0.51;

bool _near(double drawn, double wanted, double tolerance) =>
    (drawn - wanted).abs() < tolerance;

/// Records what each drawing call asked for, and ignores the rest.
class _RecordingCanvas implements Canvas {
  final marks = <_Mark>[];

  /// The alpha of each `saveLayer` — how a design group's opacity arrives.
  final layerOpacities = <double>[];

  void _record(Rect bounds, Paint paint) =>
      marks.add((bounds: bounds, colour: paint.color, style: paint.style));

  /// The marks filled — not stroked — in [colour] at [opacity].
  ///
  /// Every channel is compared with a tolerance under one 8-bit step, because
  /// `Paint.color` reads back float32-rounded and so never equals the `Color`
  /// the painter set.
  Iterable<_Mark> filledIn(Color colour, {required double opacity}) =>
      marks.where(
        (mark) =>
            mark.style == PaintingStyle.fill &&
            _near(mark.colour.r, colour.r, _channel) &&
            _near(mark.colour.g, colour.g, _channel) &&
            _near(mark.colour.b, colour.b, _channel) &&
            _near(mark.colour.a, opacity, _channel),
      );

  /// Whether a filled [colour] ellipse matches [wanted], its radii doubled
  /// into the diameters Flutter draws.
  bool hasEllipse(Color colour, _Ellipse wanted) =>
      filledIn(colour, opacity: wanted.at).any(
        (mark) =>
            _near(mark.bounds.center.dx, wanted.cx, _unit) &&
            _near(mark.bounds.center.dy, wanted.cy, _unit) &&
            _near(mark.bounds.width, wanted.rx * 2, _unit) &&
            _near(mark.bounds.height, wanted.ry * 2, _unit),
      );

  /// Whether a filled [colour] curve starts at [left], tops out at [top] and
  /// runs [width] across.
  ///
  /// A curve's *height* is deliberately not asked for: `Path.getBounds` bounds
  /// a quadratic by its control points rather than by the curve, so the bottom
  /// edge it reports is not a fact about the drawing. Every value checked here
  /// is an on-curve extreme, which is exact.
  bool hasCurve(
    Color colour, {
    required double left,
    required double top,
    required double width,
    required double opacity,
  }) => filledIn(colour, opacity: opacity).any(
    (mark) =>
        _near(mark.bounds.left, left, _unit) &&
        _near(mark.bounds.top, top, _unit) &&
        _near(mark.bounds.width, width, _unit),
  );

  /// The bounds of every filled [colour] polygon drawn — exact, for a shape
  /// whose edges are all straight.
  Iterable<Rect> polygonsIn(Color colour, {required double opacity}) =>
      filledIn(colour, opacity: opacity).map((mark) => mark.bounds);

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

/// Paints [state]'s face and returns everything it drew.
_RecordingCanvas _paint(RoastyState state) {
  final canvas = _RecordingCanvas();
  paintRoastyFace(canvas, state, MoodColors.darkRoast);
  return canvas;
}

/// [colour] the way the design spells it.
String _hex(Color colour) =>
    '#${colour.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

/// The markup of the design's `className="…"` group, up to the comment that
/// opens the next section.
String _group(String className) {
  final start = _jsx.indexOf('className="$className"');
  expect(start, isNot(-1), reason: 'roasty.jsx has no $className group');
  final end = _jsx.indexOf('{/*', start);
  return _jsx.substring(start, end == -1 ? _jsx.length : end);
}

/// Every [colour] ellipse in [markup]. One with no `opacity` is opaque.
List<_Ellipse> _ellipsesIn(String markup, Color colour) => RegExp(
  r'<ellipse cx="([-0-9.]+)"\s+cy="([-0-9.]+)"\s+rx="([-0-9.]+)"\s+'
  'ry="([-0-9.]+)"\\s+fill="${_hex(colour)}"(?:\\s+opacity="([0-9.]+)")?\\s*/>',
).allMatches(markup).map(_ellipseFrom).toList();

_Ellipse _ellipseFrom(RegExpMatch match) => (
  cx: double.parse(match.group(1)!),
  cy: double.parse(match.group(2)!),
  rx: double.parse(match.group(3)!),
  ry: double.parse(match.group(4)!),
  at: double.tryParse(match.group(5) ?? '') ?? 1,
);

/// The extremes of a path's `d`.
///
/// For a polygon this is the whole truth, since every point is on the curve.
/// For a quadratic the height is not: `Path.getBounds` bounds one by its
/// control points, so only `left`, `top` and `width` can be held against a
/// painter's reported bounds.
({double left, double top, double width, double height}) _extentOf(
  String pathData,
) {
  final numbers = RegExp(
    '-?[0-9.]+',
  ).allMatches(pathData).map((match) => double.parse(match.group(0)!)).toList();
  final xs = <double>[for (var i = 0; i < numbers.length; i += 2) numbers[i]];
  final ys = <double>[for (var i = 1; i < numbers.length; i += 2) numbers[i]];
  final left = xs.reduce((a, b) => a < b ? a : b);
  final top = ys.reduce((a, b) => a < b ? a : b);
  return (
    left: left,
    top: top,
    width: xs.reduce((a, b) => a > b ? a : b) - left,
    height: ys.reduce((a, b) => a > b ? a : b) - top,
  );
}

void main() {
  group('every face blushes, as the design draws it', () {
    // The app blushed three faces of eight. The alphas are per-state — 0.3
    // caught out, 0.55 delighted, 0.35 asleep — so one shared cheek could not
    // have been right for more than one of them anyway.
    for (final state in RoastyState.values) {
      test('${state.name}: the pair the design gives it', () {
        final cheeks = _ellipsesIn(
          _group(_designGroup[state]!),
          RoastyColors.blush,
        ).where((mark) => mark.cx != 100).toList();
        expect(
          cheeks,
          hasLength(2),
          reason:
              'the design draws ${cheeks.length} off-centre blush marks on '
              '${_designGroup[state]}, not a pair',
        );

        final painted = _paint(state);
        for (final cheek in cheeks) {
          expect(
            painted.hasEllipse(RoastyColors.blush, cheek),
            isTrue,
            reason:
                'the ${state.name} face draws no blush at '
                '(${cheek.cx}, ${cheek.cy}) with radii ${cheek.rx}x${cheek.ry} '
                'at ${cheek.at} opacity',
          );
        }
      });
    }
  });

  group('the mouths the design opens', () {
    test('the lesson face opens its mouth, and shows a tongue', () {
      // It had been reusing the correct face's stroked smile, so finishing a
      // lesson and getting one answer right looked identical.
      final markup = _group('face-lesson');
      final mouthPath = RegExp(
        '<path d="([^"]+)"\\s+fill="${_hex(RoastyColors.mouth)}"',
      ).firstMatch(markup);
      final tonguePath = RegExp(
        '<path d="([^"]+)" fill="${_hex(RoastyColors.blush)}" '
        'opacity="([0-9.]+)"',
      ).firstMatch(markup);
      expect(mouthPath, isNotNull, reason: 'the design closed the mouth');
      expect(tonguePath, isNotNull, reason: 'the design drew no tongue');
      final mouth = _extentOf(mouthPath!.group(1)!);
      final tongue = _extentOf(tonguePath!.group(1)!);

      final painted = _paint(RoastyState.lesson);
      expect(
        painted.hasCurve(
          RoastyColors.mouth,
          left: mouth.left,
          top: mouth.top,
          width: mouth.width,
          opacity: 1,
        ),
        isTrue,
        reason:
            'no filled open mouth ${mouth.width} across from '
            '(${mouth.left}, ${mouth.top}) — a stroked smile is the correct '
            'face, not this one',
      );
      expect(
        painted.hasCurve(
          RoastyColors.blush,
          left: tongue.left,
          top: tongue.top,
          width: tongue.width,
          opacity: double.parse(tonguePath.group(2)!),
        ),
        isTrue,
        reason: "no tongue inside the lesson face's open mouth",
      );
    });

    test('the module face shows a tongue under its open mouth', () {
      final markup = _group('face-module');
      final mouth = _ellipsesIn(markup, RoastyColors.mouth).single;
      final tongue = _ellipsesIn(
        markup,
        RoastyColors.blush,
      ).firstWhere((mark) => mark.cx == 100);

      final painted = _paint(RoastyState.module);
      expect(
        painted.hasEllipse(RoastyColors.mouth, mouth),
        isTrue,
        reason: 'no open mouth on the module face',
      );
      expect(
        painted.hasEllipse(RoastyColors.blush, tongue),
        isTrue,
        reason: 'no tongue on the module face',
      );
    });

    test('the lesson face is not the correct face', () {
      final lesson = _paint(RoastyState.lesson);
      final correct = _paint(RoastyState.correct);

      // The specific difference is pinned above; this says the two states
      // cannot quietly collapse back into one painter.
      expect(lesson.marks, isNotEmpty);
      expect(
        lesson.filledIn(RoastyColors.mouth, opacity: 1),
        isNotEmpty,
        reason: 'the lesson face fills a mouth',
      );
      expect(
        correct.filledIn(RoastyColors.mouth, opacity: 1),
        isEmpty,
        reason: 'the correct face strokes its smile rather than filling one',
      );
    });
  });

  group('the wink the design gives a payout', () {
    test('the wink closes one eye and lifts the mouth on that side', () {
      // The ninth state. Both of its strokes are asymmetric on purpose: the
      // arch is shallower than a delighted eye's, and the mouth ends higher
      // on the winking side than it starts, which is what stops the pose
      // reading as the idle face with an eye missing.
      final markup = _group('face-points');
      final strokes = RegExp(
        '<path d="([^"]+)"',
      ).allMatches(markup).map((match) => _extentOf(match.group(1)!)).toList();
      expect(strokes, hasLength(2), reason: 'the design redrew the wink');

      final painted = _paint(RoastyState.points);

      // The eye white and its catchlight. An open pair would be four.
      expect(
        painted.filledIn(RoastyColors.eyeWhite, opacity: 1),
        hasLength(2),
        reason: 'a winking face keeps one eye open, not two',
      );
      expect(
        painted.hasEllipse(
          RoastyColors.eyeWhite,
          _ellipsesIn(markup, RoastyColors.eyeWhite).single,
        ),
        isTrue,
        reason: 'the open eye is not where the design puts it',
      );

      for (final wanted in strokes) {
        expect(
          painted.marks.any(
            (mark) =>
                mark.style == PaintingStyle.stroke &&
                _near(mark.bounds.left, wanted.left, _unit) &&
                _near(mark.bounds.top, wanted.top, _unit) &&
                _near(mark.bounds.width, wanted.width, _unit) &&
                _near(mark.bounds.height, wanted.height, _unit),
          ),
          isTrue,
          reason:
              'no stroke ${wanted.width} by ${wanted.height} from '
              '(${wanted.left}, ${wanted.top}) — the wink and its lifted '
              'mouth are the two marks that make this face',
        );
      }
    });
  });

  group('the stars the design draws by hand', () {
    test("the module face wears the design's own star, not a regular one", () {
      // A generated five-pointed star is symmetric about its centre; the
      // design's is not — it hangs lower than it reaches — so the two differ
      // in height at the same width, which is what this catches.
      final declared = RegExp(
        '<path d="([^"]+)" fill="var[(]--warn[)]"',
      ).firstMatch(_group('face-module'));
      expect(declared, isNotNull, reason: 'the design restyled its star eyes');
      final star = _extentOf(declared!.group(1)!);

      final painted = _paint(RoastyState.module);
      for (final cx in const [80.0, 120.0]) {
        expect(
          painted
              .polygonsIn(MoodColors.darkRoast.warn, opacity: 1)
              .any(
                (bounds) =>
                    _near(bounds.left, cx + star.left, _unit) &&
                    _near(bounds.top, 148 + star.top, _unit) &&
                    _near(bounds.width, star.width, _unit) &&
                    _near(bounds.height, star.height, _unit),
              ),
          isTrue,
          reason:
              "the star eye at $cx is not the design's "
              '${star.width} by ${star.height} shape',
        );
      }
    });

    test('the sparkles are the shapes and sizes the design cuts', () {
      // The app drew the module face's five-pointed star here too, at one
      // size for all four. The design draws a four-pointed twinkle, and gives
      // them three different radii.
      final design = RegExp('<path d="([^"]+)"')
          .allMatches(_group('sparkles'))
          .map((match) => _extentOf(match.group(1)!))
          .map((extent) => Size(extent.width, extent.height))
          .toList();
      expect(design, hasLength(4), reason: 'the design changed its sparkles');

      final canvas = _RecordingCanvas();
      // Half a beat in, so every one of the four has been drawn.
      paintRoastyParticlesFront(
        canvas,
        RoastyState.correct,
        0.5,
        MoodColors.darkRoast,
      );

      // Sizes only: the painter translates and scales each sparkle, and this
      // recorder sees the shape before either.
      expect(canvas.marks.map((mark) => mark.bounds.size).toList(), design);
    });
  });

  test('the wrong badge fades as one group, not mark by mark', () {
    // The design sets `opacity` on the badge's group. Fading each mark instead
    // would show the white disc through the berry stroke and the exclamation
    // drawn on top of it.
    final declared = RegExp(
      'className="wrong-x" opacity="([0-9.]+)"',
    ).firstMatch(_jsx);
    expect(declared, isNotNull, reason: 'the design no longer fades the badge');

    final canvas = _RecordingCanvas();
    paintRoastyParticlesFront(
      canvas,
      RoastyState.wrong,
      0,
      MoodColors.darkRoast,
    );

    expect(canvas.marks, isNotEmpty, reason: 'the badge drew nothing at all');
    expect(canvas.layerOpacities, hasLength(1));
    expect(
      canvas.layerOpacities.single,
      closeTo(double.parse(declared!.group(1)!), _channel),
    );
    expect(
      canvas.marks.map((mark) => mark.colour.a),
      everyElement(closeTo(1, _channel)),
      reason: "a mark carries its own fade as well as the group's",
    );
  });
}
