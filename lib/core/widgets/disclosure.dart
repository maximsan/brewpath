import 'package:brew_path/core/icons/disclosure_mark.dart';
import 'package:brew_path/core/widgets/disclosure_panel.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The one expandable section: a header, and a panel that opens under it.
///
/// Every expandable in the app is this one — the practice groups, Path's
/// modules, Reference, For later and the FAQ — so the glyph, the timing and
/// the rule that a shut panel is not there at all are settled in one place.
class Disclosure extends StatelessWidget {
  /// Creates a disclosure whose panel is [isOpen], holding [child].
  const Disclosure({
    required this.isOpen,
    required this.child,
    this.label,
    this.header,
    this.below,
    this.trailing,
    this.onToggle,
    this.glyph = DisclosureGlyph.caret,
    this.glyphSize,
    this.collapsible = true,
    this.divider = false,
    this.semanticsLabel,
    this.headerPadding = defaultHeaderPadding,
    this.headerMinHeight,
    this.panelPadding = EdgeInsets.zero,
    this.trailingGap = defaultTrailingGap,
    super.key,
  }) : assert(
         (label == null) != (header == null),
         'a header is a label or a widget of its own, never both or neither',
       );

  /// The design's `padding: 16px 0` on the header button.
  static const EdgeInsets defaultHeaderPadding = EdgeInsets.symmetric(
    vertical: AppSpacing.md,
  );

  /// The design's `trailingGap = 9` between the trailing slot and the glyph.
  static const double defaultTrailingGap = 9;

  /// The design's `gap: 12` between the header and its trailing cluster.
  static const double _headerGap = AppSpacing.sm;

  /// Whether the panel is showing, which the header cannot overrule.
  ///
  /// The design infers this from `collapsible`, and that misfires at its own
  /// Reference site: it passes shut-while-locked and the component forces it
  /// open onto a promise the caption above already makes. Stated, not
  /// inferred, so a site cannot be overruled about its own panel.
  final bool isOpen;

  /// What the panel holds. Mounted only while the panel is open or closing.
  final Widget child;

  /// The header, when it is a plain line of body text. Excludes [header].
  final String? label;

  /// The header, when it is a widget of its own. Excludes [label].
  final Widget? header;

  /// A line under the header, inside the tappable row — a lock's reason, or a
  /// section's caption.
  final Widget? below;

  /// What sits before the glyph: a count, a lock.
  final Widget? trailing;

  /// What a tap on the header does. Null leaves it untappable; with
  /// [collapsible] false it is still a tap, but not one that opens the panel —
  /// Reference's purchase lock opens the offer instead.
  final VoidCallback? onToggle;

  /// Which mark the header carries. Ignored while [collapsible] is false,
  /// which draws none.
  final DisclosureGlyph glyph;

  /// The glyph's drawn size. Null takes the size the design draws it at.
  final double? glyphSize;

  /// Whether the header opens and shuts the panel. False renders it as a plain
  /// heading with no glyph and no expanded state.
  final bool collapsible;

  /// Whether a hairline closes the section off, under the panel.
  final bool divider;

  /// Read out in place of the header's own contents. Null lets them through.
  final String? semanticsLabel;

  /// The room inside the header row.
  final EdgeInsets headerPadding;

  /// The least the header row may be, padding included — a tap target.
  final double? headerMinHeight;

  /// The room inside the panel, which a shut panel does not contribute.
  final EdgeInsets panelPadding;

  /// The gap between [trailing] and the glyph.
  final double trailingGap;

  /// The mark this header actually draws — none at all when it cannot toggle.
  DisclosureGlyph get _shownGlyph => collapsible ? glyph : DisclosureGlyph.none;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(context),
        DisclosurePanel(isOpen: isOpen, padding: panelPadding, child: child),
        if (divider) _rule(context),
      ],
    );
  }

  /// The header: a button while it has something to do, a heading otherwise —
  /// a heading in a button would announce an action that does not exist.
  Widget _header(BuildContext context) {
    Widget row = Padding(padding: headerPadding, child: _headerRow(context));
    if (headerMinHeight case final height?) {
      row = ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: row,
      );
    }
    if (onToggle == null) return row;

    return Semantics(
      button: true,
      expanded: collapsible ? isOpen : null,
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: InkWell(onTap: onToggle, child: row),
    );
  }

  Widget _headerRow(BuildContext context) {
    final cluster = _trailingCluster();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Centred, never `CrossAxisAlignment.baseline`. The design aligns the
        // header on a baseline, but a mark reports none, and Flutter pins a
        // child with no baseline to the top of the row.
        Row(
          children: [
            Expanded(
              child:
                  header ??
                  Text(label!, style: AppText.body(mood: context.mood)),
            ),
            ?cluster,
          ],
        ),
        ?below,
      ],
    );
  }

  /// The trailing slot and the glyph, or null when the header has neither.
  Widget? _trailingCluster() {
    final mark = _shownGlyph;
    final hasGlyph = mark != DisclosureGlyph.none;
    if (trailing == null && !hasGlyph) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: _headerGap),
        ?trailing,
        if (trailing != null && hasGlyph) SizedBox(width: trailingGap),
        if (hasGlyph)
          DisclosureMark(glyph: mark, open: isOpen, size: glyphSize),
      ],
    );
  }

  /// The hairline that closes the section off, lined up with the header it
  /// belongs to rather than with rows that are free to bleed past both.
  Widget _rule(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: headerPadding.left,
      right: headerPadding.right,
    ),
    child: Divider(height: 1, thickness: 1, color: context.mood.rule),
  );
}
