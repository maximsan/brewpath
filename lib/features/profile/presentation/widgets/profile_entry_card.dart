import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/monetization/presentation/plus_pill.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_card.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One of the doors Profile closes on — art well, accent kicker, title, support
/// line, chevron.
///
/// **One widget for every entry, because the design draws one row pattern**
/// (`prototype/screens.jsx:2691-2767`): the Studio's card and Saved's differ
/// only in what sits in the well and where the tap goes. A second copy of the
/// row is how the two quietly stop matching.
///
/// The well is **64** here, against the tree hero's 96. The Studio door was
/// built at 76 from the Studio hub's own door (`customize.jsx:280-295`), which
/// is a different screen's pattern; on Profile the design draws this one.
///
/// **Locked marks the card, never the chevron.** A gated entry wears a Plus
/// pill beside its kicker and still goes somewhere — it just asks first, which
/// is [onTap]'s business rather than this card's.
class ProfileEntryCard extends StatelessWidget {
  /// Creates a [ProfileEntryCard].
  const ProfileEntryCard({
    required this.art,
    required this.kicker,
    required this.title,
    required this.support,
    required this.onTap,
    this.locked = false,
    super.key,
  });

  /// The design's art well on these cards, and the size the caller draws [art]
  /// against.
  static const double wellSize = 64;

  /// Gap between the well and the text column.
  static const double _columnGap = AppSpacing.base;

  /// What the well holds: the planted grove, a mark. Sized by the caller,
  /// because what reads as a thumbnail differs between a plant and a glyph.
  final Widget art;

  /// The smallcaps eyebrow — `GROVE`, `SAVED`. Written in sentence case;
  /// [SmallcapsLabel] applies the case, as the type rule rather than the copy.
  final String kicker;

  /// What the card opens, at the heading step.
  final String title;

  /// The line under it. May be empty while what it names is still loading —
  /// the row keeps its height either way, so the card does not jump.
  final String support;

  /// Whether the learner is outside the entitlement this entry needs.
  final bool locked;

  /// Opens the destination, or raises the gate.
  final VoidCallback onTap;

  /// What a screen reader hears instead of the card's parts.
  ///
  /// The kicker is left out: it names the section rather than the destination,
  /// and a short one like `SAVED` invites being spelled out. Empty parts are
  /// dropped rather than announced as a pause, which is what a still-loading
  /// support line would otherwise be.
  String get _label => [
    title,
    if (support.isNotEmpty) support,
    if (locked) 'BrewPath Plus',
  ].join('. ');

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return ProfileCard(
      radius: ProfileCard.cardRadius,
      onTap: onTap,
      semanticLabel: _label,
      child: Row(
        children: [
          _ArtWell(child: art),
          const SizedBox(width: _columnGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SmallcapsLabel(kicker, color: mood.accentText),
                    if (locked) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const PlusPill(),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(title, style: AppText.heading(mood: mood)),
                const SizedBox(height: AppSpacing.xxs),
                Text(support, style: AppText.support(mood: mood)),
              ],
            ),
          ),
          const IconMark(AppIcon.chevron),
        ],
      ),
    );
  }
}

/// The square the art sits in — `bg` behind its own hairline, so a plant or a
/// mark reads as mounted rather than floating on the card.
class _ArtWell extends StatelessWidget {
  const _ArtWell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Container(
      width: ProfileEntryCard.wellSize,
      height: ProfileEntryCard.wellSize,
      decoration: BoxDecoration(
        color: mood.bg,
        border: Border.all(color: mood.rule),
        borderRadius: BorderRadius.circular(AppRadii.chrome),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: child),
    );
  }
}
