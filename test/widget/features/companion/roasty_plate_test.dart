import 'dart:typed_data';

import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/companion/presentation/roasty_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered at the design's own canvas width, so a pixel is a canvas unit.
const double _canvasWidth = 200;

/// Inside the plate's circle but clear of everything Roasty draws at rest:
/// above the sprout, below the plate's top edge. Bare ground without a plate,
/// paper with one.
const Offset _aboveTheSprout = Offset(100, 42);

/// On the bean's left flank, away from the face and the highlight — brown
/// whether or not there is a plate, because the plate goes under him.
const Offset _onTheBean = Offset(60, 150);

const int _bytesPerPixel = 4;
const double _opaque = 1;

Future<Color> _sampleAt(WidgetTester tester, Roasty roasty, Offset at) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: roasty),
    ),
  );
  await tester.pump();

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.descendant(
      of: find.byType(Roasty),
      matching: find.byType(RepaintBoundary),
    ),
  );
  late final ByteData bytes;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    bytes = (await image.toByteData())!;
  });
  final offset =
      (at.dy.toInt() * _canvasWidth.toInt() + at.dx.toInt()) * _bytesPerPixel;
  return Color.fromARGB(
    bytes.getUint8(offset + 3),
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
  );
}

const _bare = Roasty(
  state: RoastyState.idle,
  size: _canvasWidth,
  animate: false,
);

const _plated = Roasty(
  state: RoastyState.idle,
  size: _canvasWidth,
  animate: false,
  plate: true,
);

void main() {
  testWidgets('without a plate the ground shows through around him', (
    tester,
  ) async {
    final colour = await _sampleAt(tester, _bare, _aboveTheSprout);

    expect(colour.a, 0);
  });

  testWidgets('with a plate he sits on pinned paper', (tester) async {
    final colour = await _sampleAt(tester, _plated, _aboveTheSprout);

    expect(colour, roastyPlate);
  });

  testWidgets('the plate goes under the bean, not over it', (tester) async {
    final colour = await _sampleAt(tester, _plated, _onTheBean);

    expect(colour.a, _opaque);
    expect(colour, isNot(roastyPlate));
  });
}
