import 'dart:async';

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
/// **Every sheet opens through here.** The chrome below is identical across all
/// nine sheet types the design specifies, which is why one function can serve
/// them all — callers supply only what is inside. A guard test fails the build
/// on a `showModalBottomSheet` written anywhere else, because the first sheet
/// carried a comment inviting the second to generalise it and the second was
/// written raw anyway.
///
/// The barrier is [OverlayColors.dimModal], whose own doc names this as the
/// app's one blocking overlay, and the corners are [AppRadii.chrome], which
/// names bottom sheets among the surfaces it is for.
///
/// [title] is required and is the sheet's *only* name: it is rendered as the
/// heading every sheet opens on, and it is the accessible name of the sheet as
/// a region. One string feeds both so they cannot drift — which is what a
/// second, separate label parameter had already allowed.
///
/// Two rules the design states are **not** implemented here, because Flutter
/// satisfies both for free and porting them would be re-solving a DOM problem:
///
/// - *Sheets stack.* The design lifts its gate sheet onto a higher z-index pair
///   because the web has no navigator stack. Here the navigator stack **is**
///   the z-order, so a sheet from inside a sheet already renders above it.
/// - *Root-level sheets are dismissed on navigation.* Flutter does this in all
///   three navigation shapes this app performs — a route change, a shell branch
///   switch, and a push inside a branch.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  final mood = context.mood;
  final settleAtOnce = _restingControllerForReducedMotion(context);

  final closed = showModalBottomSheet<T>(
    context: context,
    backgroundColor: mood.bg,
    barrierColor: OverlayColors.dimModal,
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
        child: Builder(builder: builder),
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
/// `showModalBottomSheet` does not consult [MediaQueryData.disableAnimations] —
/// measured, not assumed: the slide is identical either way. Handing it a
/// zero-duration controller is the only supported hook, and it lands the sheet
/// at rest on the first frame. It needs a [TickerProvider], which a top-level
/// function does not have and the navigator does.
AnimationController? _restingControllerForReducedMotion(BuildContext context) {
  if (!MediaQuery.disableAnimationsOf(context)) return null;

  return AnimationController(
    vsync: Navigator.of(context),
    duration: Duration.zero,
  );
}

/// The chrome every sheet wears: handle, title, insets and a scrolling cap.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
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
