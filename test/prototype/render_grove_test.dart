// PROTOTYPE — throwaway render harness for issue #83.
//
// Not a test. It asserts nothing; it is a one-command way to get PNGs out of a
// CustomPainter without booting a device, because `flutter test` is the only
// thing in this repo that can rasterise Flutter drawing commands headlessly.
//
// Run:  flutter test test/prototype/render_grove_test.dart
// Out:  .prototype-out/grove-*.png   (gitignored, wipe freely)
//
// ignore_for_file: avoid_print
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'coffee_plant_prototype_painter.dart';

/// Matches the reference art in `brew-path/assets/trees/*.png`, so output can
/// be laid beside it at 1:1 without scaling flattering either side.
const _canvas = Size(512, 512);

Future<void> _render(String name, CustomPainter painter) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // The reference PNGs are transparent, so nothing is painted behind.
  painter.paint(canvas, _canvas);

  final image = await recorder.endRecording().toImage(
    _canvas.width.toInt(),
    _canvas.height.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  final out = Directory('.prototype-out')..createSync(recursive: true);
  File('${out.path}/$name.png').writeAsBytesSync(
    bytes!.buffer.asUint8List(),
  );
  print('wrote ${out.path}/$name.png');
}

void main() {
  test('render the grove spike', () async {
    // The stage the decision turns on — this is what sits beside 10.png.
    await _render(
      'grove-s10-arabica',
      CoffeePlantPrototypePainter(stage: 10),
    );

    // Does one painter really cover the range, or only the showcase stage?
    for (final stage in const [1, 4, 7]) {
      await _render(
        'grove-s$stage-arabica',
        CoffeePlantPrototypePainter(stage: stage),
      );
    }

    // The species axis — the claim being tested is that this is a parameter
    // change, not twenty new drawings.
    for (final species in const [Species.robusta, Species.liberica]) {
      await _render(
        'grove-s10-${species.name}',
        CoffeePlantPrototypePainter(stage: 10, species: species),
      );
    }
  });
}
