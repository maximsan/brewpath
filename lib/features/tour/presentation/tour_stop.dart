import 'package:brew_path/features/tour/presentation/tour_runner.dart';
import 'package:brew_path/features/tour/presentation/tour_stop_actions.dart';
import 'package:brew_path/features/tour/presentation/tour_stops.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

/// One spotlight stop, dressed in the app's tokens.
///
/// `showcaseview` defaults to `Colors.black45` behind a white tooltip with
/// black text — three hardcoded colours that would read as a different app in
/// Cupping and as a bug in Dark Roast. Everything visual is therefore restated
/// here from tokens: the dim is [OverlayColors.dimModal] (deliberately
/// mood-independent), and the tooltip surface and ink come from `context.mood`,
/// so the card flips with the theme the way every other surface does.
///
/// **Why the blocking dim and not the scrim.** The design draws this very
/// overlay as `boxShadow: '0 0 0 1400px var(--dim-modal)'`
/// (`prototype/guide.jsx:61`) — a spotlight punched out of the blocking dim.
/// The scrim is *"the only one of the four that is not full-screen"*
/// (`ds-content.js:1087`) and belongs behind a control sitting on media, so the
/// full-screen coach mark was wearing the wrong token (#379).
///
/// **And why it is the one dim without its 5px blur.** The package takes a
/// colour and paints a hole in it. A backdrop blur behind that overlay would
/// blur the cut-out too — the widget the stop exists to point at, and the one
/// thing on screen that has to stay sharp. The design draws no blur here
/// either, for the same reason.
///
/// Wrapping rather than configuring at each call site is the point: four stops
/// configured separately are four chances for one of them to keep a default.
class TourStop extends StatelessWidget {
  /// Creates a [TourStop] around [child].
  const TourStop({
    required this.stopKey,
    required this.title,
    required this.description,
    required this.child,
    super.key,
  });

  /// Breathing room between the highlight and the widget it cuts out.
  static const _targetPadding = EdgeInsets.all(AppSpacing.xs);

  /// The tooltip card's own padding.
  static const _tooltipPadding = EdgeInsets.all(AppSpacing.md);

  /// The stop's identity in [TourStops], which is also its place in the order.
  final GlobalKey stopKey;

  /// The stop's heading — locked copy from `TourCopy`.
  final String title;

  /// The stop's body — locked copy from `TourCopy`.
  final String description;

  /// The widget the stop spotlights.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A stop outside a `TourHost` is not an error, it is simply a screen with
    // no Tour — a widget test that pumps one tab, or a future surface that
    // reuses the card. `Showcase` would throw on the unregistered scope, so
    // the check happens here rather than at every call site.
    if (!TourHost.isHosted(context)) return child;

    final mood = context.mood;
    return Showcase(
      key: stopKey,
      scope: TourStops.scope,
      title: title,
      description: description,
      // Both come from the one token, so the highlight sits under the same dim
      // as every other blocking overlay in the app rather than near it. The
      // package multiplies nothing: it replaces the colour's alpha with this
      // opacity, and the constant is where that alpha came from.
      overlayColor: OverlayColors.dimModal.color,
      overlayOpacity: OverlayColors.dimModalOpacity,
      tooltipBackgroundColor: mood.surface,
      textColor: mood.ink,
      titleTextStyle: AppText.heading(mood: mood),
      descTextStyle: AppText.body(mood: mood),
      tooltipPadding: _tooltipPadding,
      tooltipBorderRadius: BorderRadius.circular(AppRadii.chrome),
      targetPadding: _targetPadding,
      targetBorderRadius: BorderRadius.circular(AppRadii.chrome),
      // The Tour is read, not operated: tapping the highlighted widget should
      // advance the Tour, never fire the button underneath it.
      disableDefaultTargetGestures: true,
      // Every card carries its own pair rather than the engine's global one,
      // because the right-hand button is not the same word on every stop.
      tooltipActions: tourStopActions(
        mood: mood,
        isLast: TourStops.isLast(stopKey),
      ),
      tooltipActionConfig: tourStopActionConfig,
      child: child,
    );
  }
}
