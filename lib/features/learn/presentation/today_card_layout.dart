import 'package:brew_path/features/learn/presentation/module_art_banner.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The one shape Today's lesson card takes in both of its lesson states —
/// eyebrow, title, the module's picture, one meta line, a full-width action —
/// so the wall reads as the same card saying something else, not as a second
/// surface.
///
/// Stacked, with every element on the card's left rail: the design's
/// `.card` at `padding: 24px`, its title at the title step, the art banner
/// `marginTop: 16`, the meta line `marginTop: 14` and the CTA `marginTop: 18`.
///
/// The whole card taps as well as its button. The design wires only the
/// button; a card this size whose body did nothing on a tap would read as
/// broken on a phone, and the locked Path row already sets the precedent.
class TodayCardLayout extends StatelessWidget {
  /// Creates a [TodayCardLayout].
  const TodayCardLayout({
    required this.eyebrow,
    required this.title,
    required this.action,
    required this.onTap,
    this.module,
    this.meta,
    super.key,
  });

  /// The smallcaps line over the title — the module, or the wall.
  final Widget eyebrow;

  /// The lesson's title.
  final String title;

  /// The module whose picture the card carries, or null for none.
  final ModuleModel? module;

  /// The one mono line under the picture, or null while it is unknown.
  final Widget? meta;

  /// The full-width CTA.
  final Widget action;

  /// What tapping the card's body does.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final module = this.module;
    final meta = this.meta;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chrome),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // A node of its own, so the eyebrow is announced as its own
            // element rather than as the first words of the card's one long
            // merged label.
            Semantics(container: true, child: eyebrow),
            const SizedBox(height: AppSpacing.base),
            Text(title, style: AppText.title(mood: context.mood)),
            if (module?.art != null) ...[
              const SizedBox(height: AppSpacing.md),
              ModuleArtBanner(module: module!),
            ],
            if (meta != null) ...[
              const SizedBox(height: AppSpacing.base),
              meta,
            ],
            SizedBox(height: OffTokens.todayCtaGap.value),
            action,
          ],
        ),
      ),
    );
  }
}
