import 'dart:async';

import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/learn/presentation/practice/replay_row.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_destination.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_kinds.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/features/mini_games/presentation/mini_game_gate_sheet.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The mini-game catalog under Learn → Practice → Games.
///
/// Games are grouped by **kind**, in the fixed order [miniGameKinds] declares,
/// each group keeping catalog order internally. A learner arrives wanting a
/// mechanic rather than a topic, and a flat list of thirteen made them read all
/// thirteen to find the two that match. The order does not derive from the
/// catalog, so adding a game never reshuffles the shelf.
///
/// The kind's glyph and name are on the group's heading and never on a row;
/// the row leads with the game's own name and carries the topic it drills as
/// the eyebrow. Rows sit indented under their heading (`paddingLeft: 30`), so
/// the shelf reads as kinds with games inside rather than as one long
/// alternation of headings and rows.
///
/// **Every row opens its intro.** Whether a game can actually be played is a
/// fact about which renderers this build carries, and it is disclosed on the
/// intro's own action rather than here — the design puts the row's tap on tier
/// alone. A row that dimmed itself for a missing renderer looked exactly like
/// a row behind a paywall, so the catalog said "unfinished" where it meant
/// "unbuilt" and would later mean "unbought".
class MiniGamesCatalogWidget extends StatelessWidget {
  /// Creates a [MiniGamesCatalogWidget].
  const MiniGamesCatalogWidget({
    required this.formats,
    required this.hasCourse,
    super.key,
  });

  /// The catalog, in bank order.
  final List<MiniGameFormat> formats;

  /// Whether the learner owns the course. Everything opens when they do.
  final bool hasCourse;

  /// The design's `paddingLeft: 30` under a kind heading.
  static const double _kindIndent = 30;

  @override
  Widget build(BuildContext context) {
    if (formats.isEmpty) return const _EmptyCatalog();

    final groups = groupCatalogByKind(formats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups) ...[
          _KindHeading(group: group),
          Padding(
            padding: const EdgeInsets.only(left: _kindIndent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final format in group.games)
                  _FormatRow(format: format, hasCourse: hasCourse),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One game as a replay row: its name, its topic, and either what it costs or
/// how long it takes.
///
/// The meta line is the design's: nothing on a locked row, `FREE` on an open
/// row while the course is not owned, and the game's time once it is. A lock
/// is an offer, not a dead end — the tap that cannot start a run opens the
/// pitch for the module that teaches this game's topic.
class _FormatRow extends StatelessWidget {
  const _FormatRow({required this.format, required this.hasCourse});

  final MiniGameFormat format;
  final bool hasCourse;

  static const String _freeMeta = 'Free';
  static const String _lockedHint = 'Shows the module that teaches it';

  @override
  Widget build(BuildContext context) {
    final isOpen = isMiniGameOpen(format, hasCourse: hasCourse);

    return ReplayRow(
      title: format.title,
      sub: format.topic,
      meta: !isOpen
          ? null
          : hasCourse
          ? format.duration
          : _freeMeta,
      locked: !isOpen,
      // A lock a screen reader cannot act on is the dead end this catalog set
      // out to remove: sighted learners tap a lock speculatively, but being
      // told only that a row is locked gives no reason to try.
      hint: isOpen ? null : _lockedHint,
      onTap: isOpen
          ? () => unawaited(context.goToActivity(miniGameRun(format.id)))
          : () => showMiniGameGateSheet(context: context, format: format),
    );
  }
}

/// A kind's heading: its glyph, then its name.
///
/// The glyph is what lets a learner find a mechanic by shape rather than by
/// reading seven headings. A group with no mark — a game whose kind is not in
/// `miniGameKinds` — heads with the name alone rather than a gap where a mark
/// should be.
class _KindHeading extends StatelessWidget {
  const _KindHeading({required this.group});

  final MiniGameGroup group;

  /// The design draws the glyph at 18 inside a 20-wide column.
  static const double _markSize = 18;
  static const double _markColumn = 20;

  /// The design's `padding: 16px 0 2px`, at the shelf's row bleed.
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.xs,
    AppSpacing.md,
    AppSpacing.xs,
    2,
  );

  @override
  Widget build(BuildContext context) {
    final mark = group.mark;

    return Padding(
      padding: _padding,
      child: Row(
        children: [
          if (mark != null) ...[
            SizedBox(
              width: _markColumn,
              child: Center(
                child: IconMark(
                  mark,
                  size: _markSize,
                  color: context.mood.inkMute,
                ),
              ),
            ),
            SizedBox(width: OffTokens.practiceInlineGap.value),
          ],
          SectionHeader(group.label),
        ],
      ),
    );
  }
}

/// The quiet state for a build whose catalog is empty — a line, not a card.
class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog();

  static const String _copy = 'No mini-games available yet.';

  @override
  Widget build(BuildContext context) => Semantics(
    label: _copy,
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Text(_copy, style: AppText.support(mood: context.mood)),
    ),
  );
}
