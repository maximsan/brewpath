import 'package:brew_path/core/widgets/scrolled_progress.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The title that slides into the bar as the screen's large title scrolls
/// away under it.
///
/// **Absent, not merely invisible, while the page is at rest.** The design
/// fades it in from 7px below at the moment the large title has gone, so the
/// screen is titled once at every point of the scroll — and building nothing
/// at rest is what makes "once" true rather than nearly true, for a screen
/// reader and for a test as much as for the eye.
///
/// Its eyebrow is what the tab is, its title what the tab says: `TODAY` over
/// the day, `YOUR DECK` over `Collection`. The pair is the same tab heading
/// the tab's own large title reads, so the two cannot drift apart.
class HeaderCompactTitle extends StatelessWidget {
  /// Creates a [HeaderCompactTitle].
  const HeaderCompactTitle({
    required this.eyebrow,
    required this.title,
    required this.isVisible,
    super.key,
  });

  /// The smallcaps line above — `TODAY`, `YOUR PATH`.
  final String eyebrow;

  /// The line the tab is titled by.
  final String title;

  /// Whether the page beneath has scrolled far enough to need it.
  final bool isVisible;

  /// How far below its resting place it starts — the design's
  /// `translateY(7px)`.
  static const double _rise = 7;

  /// The gap between the eyebrow and the title — the design's `marginTop: 2`,
  /// which is tighter than the hairline stop because the two are one stacked
  /// label rather than two blocks.
  static const double _stackGap = 2;

  /// How long it takes to arrive when motion is allowed.
  static const Duration _duration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ScrolledProgress(
      isScrolled: isVisible,
      duration: _duration,
      // The bar mirrors a title the screen already states, so a screen reader
      // is given it once — by the screen — rather than twice by the two halves
      // of one crossfade. Pointer events pass through for the same reason the
      // rest of the bar lets them: `RenderParagraph` claims a hit it is drawn
      // over, and the tab underneath is what the drag belongs to.
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eyebrow.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.micro(
                  mood: mood,
                  tracking: AppTracking.chrome,
                ),
              ),
              const SizedBox(height: _stackGap),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.heading(mood: mood),
              ),
            ],
          ),
        ),
      ),
      builder: (context, progress, stack) => progress == 0
          ? const SizedBox.shrink()
          : Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, (1 - progress) * _rise),
                child: stack,
              ),
            ),
    );
  }
}
