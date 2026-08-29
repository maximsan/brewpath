import 'dart:ui' show ImageFilter;

import 'package:brew_path/shared/theme/app_overlay.dart';
import 'package:flutter/material.dart';

/// Renders an [AppOverlay] behind a modal route: its tint on the barrier, and
/// its blur on everything the barrier covers.
///
/// The blur half of an overlay has nowhere else to go. A `BottomSheetThemeData`
/// or a `DialogTheme` can carry a barrier *colour* and nothing more, so a
/// screen that opens a sheet through the theme alone would separate the pair
/// that [AppOverlay] exists to keep together — which is why every sheet opens
/// through `showAppSheet` and every dialog through [showOverlayDialog], each
/// with a guard test that fails the build on a modal opened any other way.
///
/// Flutter's own hook is [ModalRoute.filter], which wraps the barrier in a
/// `BackdropFilter`. Both routes the app opens inherit that field and neither
/// the Material sheet route nor [DialogRoute] forwards it to their
/// constructors, so it is supplied here by overriding the getter instead.
///
/// **The blur does not animate.** It is constant for the life of the barrier
/// while the tint fades in with the route — the framework's own behaviour for
/// [ModalRoute.filter], and the cheaper of the two: a sigma driven by the
/// transition rebuilds the filter and re-blurs the whole screen behind it on
/// every frame of every open, which is the work a low-end device has least to
/// spare. Reduced motion never reaches the question — `showAppSheet` lands its
/// transition at rest on the first frame, and the barrier is simply there.
mixin OverlayBarrier<T> on ModalRoute<T> {
  /// The overlay this route's barrier wears.
  AppOverlay get barrierOverlay;

  /// Narrower than [ModalRoute.barrierColor], which is nullable: a route that
  /// mixes this in always has an overlay, and a barrier is what it is for.
  ///
  /// Both halves are read off the one token here rather than passed separately
  /// to a superclass, so a route cannot be built that dims with one overlay and
  /// blurs with another.
  @override
  Color get barrierColor => barrierOverlay.color;

  @override
  ImageFilter? get filter => barrierOverlay.backdropFilter;
}

/// A dialog route whose barrier wears [barrierOverlay] — tint and blur.
class OverlayDialogRoute<T> extends DialogRoute<T> with OverlayBarrier<T> {
  /// Creates a dialog route dimmed by [overlay].
  OverlayDialogRoute({
    required AppOverlay overlay,
    required super.context,
    required super.builder,
    super.themes,
    super.barrierDismissible,
    super.settings,
  }) : barrierOverlay = overlay;

  @override
  final AppOverlay barrierOverlay;
}

/// Shows [builder] as a dialog behind [overlay], and resolves to whatever the
/// dialog pops with.
///
/// This is `showDialog` with one difference that matters: the route it pushes
/// carries the overlay's blur as well as its colour. Everything else — the
/// captured themes, the root navigator, the safe area — is what `showDialog`
/// does, because a dialog that inherited no theme would lose the mood.
Future<T?> showOverlayDialog<T>({
  required BuildContext context,
  required AppOverlay overlay,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);

  return navigator.push<T>(
    OverlayDialogRoute<T>(
      overlay: overlay,
      context: context,
      builder: builder,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      barrierDismissible: barrierDismissible,
    ),
  );
}
