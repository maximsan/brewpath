import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The large title a page opened from a tab carries at the top of its scroll.
///
/// The sibling of `TabLargeTitle`, and the same pairing: the page is titled by
/// the page while the page is at the top, and by the bar over it once it has
/// scrolled. Building only one half titles the screen twice or not at all.
///
/// Unlike a tab's, this one takes its words rather than looking them up — a
/// pushed page's title is the page's own, and there is no catalogue of them to
/// read it from. The screen passes the same string to its `SubHeader`, so the
/// two sizes of one title cannot drift apart.
class PageLargeTitle extends StatelessWidget {
  /// Creates a [PageLargeTitle].
  const PageLargeTitle(
    this.title, {
    this.kicker,
    this.kickerColor,
    this.isCentred = false,
    super.key,
  });

  /// What the page is called.
  final String title;

  /// The smallcaps line above it, where the page has one — `REFERENCE · 73
  /// TERMS`, `YOUR COFFEE TREE`. Most pages open on the title alone.
  final String? kicker;

  /// The kicker's ink, for the pages the design sets it in the accent. Muted
  /// by default, as `SmallcapsLabel` is.
  final Color? kickerColor;

  /// Whether the pair is centred. The design centres exactly one page's — the
  /// coffee tree, whose heading sits over a drawing rather than over text.
  final bool isCentred;

  /// The gap the design leaves under a kicker before the title it heads.
  static const double _kickerGap = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final heading = Semantics(
      header: true,
      child: Text(
        title,
        textAlign: isCentred ? TextAlign.center : null,
        style: AppText.display(mood: context.mood),
      ),
    );

    if (kicker == null) return heading;

    return Column(
      crossAxisAlignment: isCentred
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SmallcapsLabel(kicker!, color: kickerColor),
        const SizedBox(height: _kickerGap),
        heading,
      ],
    );
  }
}
