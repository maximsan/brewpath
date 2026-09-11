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
    this.headerAlign = CrossAxisAlignment.center,
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

  /// Whether the panel is showing. Authoritative even where the header cannot
  /// toggle it: Path's active module is a fixed heading over an open panel,
  /// and a locked one a fixed heading over a shut panel.
  final bool isOpen;

  /// What the panel holds. Built only while the panel is open or closing.
  final Widget child;

  /// The header, when it is a plain line of body text.
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

  /// How the header's row lines its parts up.
  final CrossAxisAlignment headerAlign;

  /// The room inside the header row.
  final EdgeInsets headerPadding;

  /// The least the header row may be, padding included — a tap target.
  final double? headerMinHeight;

  /// The room inside the panel, which a shut panel does not contribute.
  final EdgeInsets panelPadding;

  /// The gap between [trailing] and the glyph.
  final double trailingGap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(
          label: label,
          header: header,
          below: below,
          trailing: trailing,
          isOpen: isOpen,
          onToggle: onToggle,
          glyph: collapsible ? glyph : DisclosureGlyph.none,
          glyphSize: glyphSize,
          collapsible: collapsible,
          semanticsLabel: semanticsLabel,
          headerAlign: headerAlign,
          padding: headerPadding,
          minHeight: headerMinHeight,
          trailingGap: trailingGap,
        ),
        DisclosurePanel(
          isOpen: isOpen,
          padding: panelPadding,
          child: child,
        ),
        if (divider)
          Padding(
            // The rule lines up with the header it closes off, not with the
            // rows between, which are free to bleed past both.
            padding: EdgeInsets.only(
              left: headerPadding.left,
              right: headerPadding.right,
            ),
            child: Divider(height: 1, thickness: 1, color: mood.rule),
          ),
      ],
    );
  }
}

/// The header row: what it says, what trails it, and whether it is a button.
class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.header,
    required this.below,
    required this.trailing,
    required this.isOpen,
    required this.onToggle,
    required this.glyph,
    required this.glyphSize,
    required this.collapsible,
    required this.semanticsLabel,
    required this.headerAlign,
    required this.padding,
    required this.minHeight,
    required this.trailingGap,
  });

  final String? label;
  final Widget? header;
  final Widget? below;
  final Widget? trailing;
  final bool isOpen;
  final VoidCallback? onToggle;
  final DisclosureGlyph glyph;
  final double? glyphSize;
  final bool collapsible;
  final String? semanticsLabel;
  final CrossAxisAlignment headerAlign;
  final EdgeInsets padding;
  final double? minHeight;
  final double trailingGap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final hasGlyph = glyph != DisclosureGlyph.none;

    Widget row = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: headerAlign,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: header ?? Text(label!, style: AppText.body(mood: mood)),
            ),
            if (trailing != null || hasGlyph) ...[
              const SizedBox(width: Disclosure._headerGap),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailing case final mark?) ...[
                    mark,
                    if (hasGlyph) SizedBox(width: trailingGap),
                  ],
                  if (hasGlyph)
                    DisclosureMark(
                      glyph: glyph,
                      open: isOpen,
                      size: glyphSize,
                    ),
                ],
              ),
            ],
          ],
        ),
        ?below,
      ],
    );

    row = Padding(padding: padding, child: row);
    if (minHeight case final height?) {
      row = ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: row,
      );
    }

    // A header with nothing to do is a heading, and wrapping it in a button
    // would announce an action that does not exist.
    if (onToggle == null) return row;

    return Semantics(
      button: true,
      expanded: collapsible ? isOpen : null,
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: InkWell(onTap: onToggle, child: row),
    );
  }
}
