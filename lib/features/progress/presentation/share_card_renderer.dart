import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Renders [card] to PNG bytes in a detached render tree, at a fixed
/// [logicalSize] and [pixelRatio].
///
/// Off-screen composition rather than capturing an on-screen preview, so the
/// exported image never varies with device width (#26). The card is wrapped
/// with the current [mood]'s theme extension, a bare MediaQuery and LTR
/// directionality — everything a themed widget needs and nothing more.
Future<Uint8List> renderCardPng({
  required Widget card,
  required Size logicalSize,
  required double pixelRatio,
  required MoodColors mood,
}) async {
  final boundary = RenderRepaintBoundary();
  final view = WidgetsBinding.instance.platformDispatcher.implicitView!;
  final renderView = RenderView(
    view: view,
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(logicalSize),
      physicalConstraints: BoxConstraints.tight(logicalSize * pixelRatio),
      devicePixelRatio: pixelRatio,
    ),
    child: RenderPositionedBox(child: boundary),
  );
  final pipelineOwner = PipelineOwner()..rootNode = renderView;
  renderView.prepareInitialFrame();

  final buildOwner = BuildOwner(focusManager: FocusManager());
  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: boundary,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: ThemeData(extensions: [mood]),
          child: card,
        ),
      ),
    ),
  ).attachToRenderTree(buildOwner);
  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();
  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
