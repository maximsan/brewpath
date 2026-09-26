import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/bean_gauge.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One saved thing: its mark, what it is, and the ringed bookmark that takes
/// it off the shelf.
///
/// The bookmark keeps its ring here on purpose: every row on this screen is
/// saved by definition, so a bare mark would state the obvious, and this is
/// the one screen where removal must stay reachable.
class SavedRow extends StatelessWidget {
  /// Creates a [SavedRow] for [item].
  const SavedRow({required this.item, required this.onOpen, super.key});

  /// The design's `padding: 13px 0` above and below the row.
  static const double _rowPad = 13;

  /// The design's grid: a `24px` column for the mark, then `gap: 14`.
  static const double _markColumn = 24;
  static const double _markGap = 14;

  /// The design's `SavedIcon size={22}`.
  static const double _markSize = 22;

  /// The design's `marginTop: 2` between the eyebrow and the title.
  static const double _titleGap = 2;

  /// The row's content.
  final SavedItem item;

  /// Opens what the row names.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    // The bookmark sits beside the tap surface, not inside it: a control
    // inside a control is pruned from the accessibility tree.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: mood.rule)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _rowPad),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onOpen,
                child: Row(
                  children: [
                    SizedBox(
                      width: _markColumn,
                      child: Center(
                        child: _Mark(item: item, size: _markSize),
                      ),
                    ),
                    const SizedBox(width: _markGap),
                    Expanded(child: _Words(item: item)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SavedBookmarkButton(
              savedKey: item.key,
              label: item.title,
              ringed: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// The eyebrow in mono micro, then the title at body weight 500 on one line.
class _Words extends StatelessWidget {
  const _Words({required this.item});

  final SavedItem item;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Uppercase is the type rule, not the name: announced as written.
        Semantics(
          label: savedRowSubtitle(context.strings, item),
          excludeSemantics: true,
          child: Text(
            savedRowSubtitle(context.strings, item).toUpperCase(),
            style: AppText.micro(mood: mood, tracking: AppTracking.smallcaps),
          ),
        ),
        const SizedBox(height: SavedRow._titleGap),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.body(mood: mood, face: AppFace.control),
        ),
      ],
    );
  }
}

/// What kind of thing the row is, drawn outline-only in muted ink.
///
/// A lesson is the empty bean: fill is reserved for the mastery gauge. A guide
/// takes the mark the Reference shelf already gives one — the design draws its
/// own `TuneMark` there, which the app has no glyph for.
class _Mark extends StatelessWidget {
  const _Mark({required this.item, required this.size});

  final SavedItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return switch (item.kind) {
      SavedKind.term => IconMark(
        moduleMark(item.glyph ?? ''),
        size: size,
        color: mood.inkMute,
      ),
      SavedKind.lesson => BeanGauge(
        fill: 0,
        color: mood.accent,
        muted: mood.inkMute,
        ink: mood.ink,
        size: size,
      ),
      SavedKind.guide => IconMark(
        AppIcon.module,
        size: size,
        color: mood.inkMute,
      ),
    };
  }
}
