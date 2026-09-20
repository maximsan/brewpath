import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// What an empty shelf says.
///
/// It teaches the bookmark rather than reporting a count of zero: the learner
/// most likely to open an empty shelf is the one who has not found the control
/// yet.
class SavedEmptyView extends StatelessWidget {
  /// Creates a [SavedEmptyView].
  const SavedEmptyView({super.key});

  /// The copy, named so a test can assert it without re-spelling it.
  static const message =
      'Nothing saved yet. Tap the bookmark on any lesson, term or visual '
      'guide and it lands here for quick review.';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: 'Your saved shelf is empty',
      // The shelf's own gutter is the screen's; only the design's opening
      // room belongs to the block.
      child: Padding(
        padding: EdgeInsets.only(top: OffTokens.savedEmptyTop.value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: OffTokens.savedEmptyMarkOpacity.value,
              child: IconMark(
                AppIcon.bookmark,
                size: OffTokens.savedEmptyMark.value,
                color: mood.inkMute,
              ),
            ),
            SizedBox(height: OffTokens.savedEmptyMarkGap.value),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: OffTokens.savedEmptyLineWidth.value,
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.body(
                  mood: mood,
                  color: mood.inkMute,
                ).copyWith(height: OffTokens.emptyStateLeading.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
