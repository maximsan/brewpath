import 'dart:async';

import 'package:brew_path/core/widgets/overlay_barrier.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/theme/app_overlay.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';

const double _handleWidth = 36;
const double _handleHeight = 4;

/// How much of the screen a sheet may take before its content scrolls.
const double _maxHeightFraction = 0.78;

/// Presents [builder] as a bottom sheet, wearing the app's one sheet dressing.
///
/// **Every sheet opens through here**, and a guard test fails the build on one
/// opened anywhere else. [title] is the sheet's *only* name — the heading and
/// the accessible name both — and [eyebrow] is the kicker the design sets over
/// it. The chrome and what it deliberately omits: `docs/02-architecture.md`.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  String? eyebrow,
}) {
  final mood = context.mood;
  final settleAtOnce = _restingControllerForReducedMotion(context);

  final navigator = Navigator.of(context);
  final localizations = MaterialLocalizations.of(context);

  final closed = navigator.push<T>(
    _AppSheetRoute<T>(
      overlay: OverlayColors.dimModal,
      backgroundColor: mood.bg,
      // Without these the sheet loses the mood: a route is built from the
      // navigator's context, not the caller's, so the theme has to travel.
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      barrierLabel: localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(
        localizations.bottomSheetLabel,
      ),
      // Sheets carry a lot of copy; on a short screen they scroll rather than
      // clipping the action the learner came for.
      isScrollControlled: true,
      transitionAnimationController: settleAtOnce,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.chrome),
        ),
      ),
      builder: (context) => Semantics(
        container: true,
        label: title,
        child: _SheetFrame(
          title: title,
          eyebrow: eyebrow,
          child: Builder(builder: builder),
        ),
      ),
    ),
  );

  // Supplying the controller means owning it: the sheet drives it and never
  // disposes it, so it has to be released once the route is gone.
  if (settleAtOnce != null) {
    unawaited(closed.whenComplete(settleAtOnce.dispose));
  }

  return closed;
}

/// An already-elapsed controller when the platform asks for reduced motion,
/// or null to let the default transition run.
///
/// `ModalBottomSheetRoute` does not consult [MediaQueryData.disableAnimations]
/// — measured, not assumed. A zero-duration controller is the only supported
/// hook, and it needs the [TickerProvider] the navigator has.
AnimationController? _restingControllerForReducedMotion(BuildContext context) {
  if (!MediaQuery.disableAnimationsOf(context)) return null;

  return AnimationController(
    vsync: Navigator.of(context),
    duration: Duration.zero,
  );
}

/// The chrome every sheet wears: handle, title, insets and a scrolling cap.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.child,
    this.eyebrow,
  });

  final String title;
  final String? eyebrow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final maxHeight = MediaQuery.sizeOf(context).height * _maxHeightFraction;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: _handleWidth,
                  height: _handleHeight,
                  decoration: BoxDecoration(
                    color: mood.rule,
                    borderRadius: BorderRadius.circular(_handleHeight),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (eyebrow != null) ...[
                SmallcapsLabel(eyebrow!, color: mood.accent),
                const SizedBox(height: AppSpacing.xxs),
              ],
              // "Every sheet opens on its title, in the same display face at
              // the same size" — the design's own rule, enforceable only from
              // in here.
              Semantics(
                header: true,
                child: Text(title, style: AppText.title(mood: mood)),
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// The sheet route that wears the app's blocking overlay.
///
/// `ModalBottomSheetRoute` takes a barrier colour and inherits
/// [ModalRoute.filter] without forwarding it, so the blur is put back by
/// [OverlayBarrier] and both halves come from the one [AppOverlay].
class _AppSheetRoute<T> extends ModalBottomSheetRoute<T>
    with OverlayBarrier<T> {
  _AppSheetRoute({
    required AppOverlay overlay,
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.backgroundColor,
    super.shape,
    super.transitionAnimationController,
  }) : barrierOverlay = overlay;

  @override
  final AppOverlay barrierOverlay;
}
