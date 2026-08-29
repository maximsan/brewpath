import 'package:brew_path/core/widgets/overlay_barrier.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';

/// The Tour's front door: "Quick tour?", with Show me and Skip.
///
/// Returns `true` when the learner accepted, `false` when they skipped, and
/// `null` only if the route was dismissed without an answer — which is why the
/// barrier is not dismissible. *Both* answers write `tourSeen`, so an
/// unanswered overlay has to stay distinguishable from a declined one; a
/// tap-outside that silently counted as Skip would spend the learner's one
/// offer on a mis-tap.
class TourIntroOverlay extends StatelessWidget {
  /// Creates a [TourIntroOverlay].
  const TourIntroOverlay({super.key});

  /// Keeps the card off the screen edges on the narrowest phone.
  static const _insets = EdgeInsets.symmetric(horizontal: AppSpacing.lg);

  /// Shows the overlay and resolves to the learner's answer.
  ///
  /// It opens through [showOverlayDialog] rather than `showDialog` for the same
  /// reason `showAppSheet` pushes its own route: `barrierColor` would take the
  /// dim's colour and leave its 5px blur behind (#379).
  static Future<bool?> show(BuildContext context) => showOverlayDialog<bool>(
    context: context,
    overlay: OverlayColors.dimModal,
    barrierDismissible: false,
    builder: (_) => const TourIntroOverlay(),
  );

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Semantics(
      container: true,
      label: TourCopy.introSemanticLabel,
      child: AlertDialog(
        backgroundColor: mood.surface,
        insetPadding: _insets,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chrome),
        ),
        title: Text(TourCopy.introTitle, style: AppText.title(mood: mood)),
        content: Text(TourCopy.introBody, style: AppText.body(mood: mood)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              TourCopy.introDecline,
              style: AppText.label(mood: mood),
            ),
          ),
          // Not `PrimaryButton`: it sits in a row beside a decline, so a
          // full-width CTA would push its pair off the line.
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              TourCopy.introAccept,
              style: AppText.label(color: mood.accentInk),
            ),
          ),
        ],
      ),
    );
  }
}
