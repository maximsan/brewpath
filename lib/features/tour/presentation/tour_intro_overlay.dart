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
  static Future<bool?> show(BuildContext context) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: OverlayColors.dimModal,
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
