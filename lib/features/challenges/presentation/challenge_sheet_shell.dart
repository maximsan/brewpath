import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';

const double _handleWidth = 36;
const double _handleHeight = 4;
const double _maxHeightFraction = 0.78;

/// Presents [builder] as the app's bottom-sheet shell.
///
/// **The app's first modal sheet**, so it carries its own styling: no
/// `BottomSheetThemeData` is registered, and inheriting Material's defaults
/// would put a stock surface colour behind a moody design. Deliberately not a
/// theme entry yet — one sheet is not a system, and the second one is what
/// will show which parts are shared.
///
/// The barrier is [OverlayColors.dimModal], whose own doc names this as the
/// app's one blocking overlay, and the corners are [AppRadii.chrome], which
/// names bottom sheets among the surfaces it is for.
Future<T?> showChallengeSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required String label,
}) {
  final mood = context.mood;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: mood.bg,
    barrierColor: OverlayColors.dimModal,
    // The sheets carry a lot of copy; on a short screen they scroll rather
    // than clipping the action the learner came for.
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadii.chrome),
      ),
    ),
    builder: (context) => Semantics(
      container: true,
      label: label,
      child: _SheetFrame(child: Builder(builder: builder)),
    ),
  );
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

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
              child,
            ],
          ),
        ),
      ),
    );
  }
}
