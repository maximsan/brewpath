import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_kinds.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_tier.dart';
import 'package:brew_path/features/mini_games/presentation/mini_game_gate_sheet.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Mini-games group under Learn → Practice again.
///
/// Games are grouped by **kind**, in the fixed order [miniGameKinds] declares,
/// each group keeping catalog order internally. A learner arrives wanting a
/// mechanic rather than a topic, and a flat list of thirteen made them read all
/// thirteen to find the two that match. The order does not derive from the
/// catalog, so adding a game never reshuffles the shelf.
///
/// The row leads with the game's own name and carries the topic it drills as
/// the eyebrow — the design reference had these inverted, corrected alongside
/// this build.
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

  static const SizedBox _headingGap = SizedBox(height: AppSpacing.xs);
  static const SizedBox _groupGap = SizedBox(height: AppSpacing.md);

  /// The design's `padding-left: 30` under a kind heading.
  static const double _kindIndent = 30;

  @override
  Widget build(BuildContext context) {
    if (formats.isEmpty) {
      return Semantics(
        label: 'No mini-games available yet.',
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'No mini-games available yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final groups = groupCatalogByKind(formats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          if (index > 0) _groupGap,
          _KindHeading(group: groups[index]),
          _headingGap,
          // The design indents a kind's games under its heading, so the shelf
          // reads as kinds with games inside rather than as one long
          // alternation of headings and cards.
          Padding(
            padding: const EdgeInsets.only(left: _kindIndent),
            child: _GroupCard(games: groups[index].games, hasCourse: hasCourse),
          ),
        ],
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.games, required this.hasCourse});

  final List<MiniGameFormat> games;
  final bool hasCourse;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < games.length; index++) ...[
            if (index > 0) Divider(height: 1, color: mood.rule),
            _FormatRow(format: games[index], hasCourse: hasCourse),
          ],
        ],
      ),
    );
  }
}

class _FormatRow extends StatelessWidget {
  const _FormatRow({required this.format, required this.hasCourse});

  final MiniGameFormat format;
  final bool hasCourse;

  static const double _eyebrowLetterSpacing = 0.8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final isOpen = isMiniGameOpen(format, hasCourse: hasCourse);

    return Semantics(
      button: true,
      label: isOpen
          ? '${format.title}. ${format.topic}. ${format.duration}.'
          : '${format.title}. ${format.topic}. Locked.',
      // A lock a screen reader cannot act on is the dead end this catalog set
      // out to remove: sighted learners tap a lock speculatively, but being
      // told only that a row is locked gives no reason to try. The hint slot
      // is where the action belongs — the label carries state, and the reader
      // announces the button role itself.
      hint: isOpen ? null : 'Shows the module that teaches it',
      child: InkWell(
        // A lock is an offer, not a dead end: the tap that cannot start a run
        // opens the pitch for the module that teaches this game's topic.
        onTap: isOpen
            ? () => context.goNamed(
                AppRoutes.miniGameIntro.name,
                pathParameters: {'gameId': format.id},
              )
            : () => showMiniGameGateSheet(context: context, format: format),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      format.topic,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: mood.inkMute,
                        letterSpacing: _eyebrowLetterSpacing,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      format.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: mood.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isOpen)
                Text(
                  format.duration,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: mood.inkMute,
                  ),
                ),
              IconMark(
                isOpen ? AppIcon.chevron : AppIcon.lock,
                color: mood.inkMute,
              ),
            ],
          ),
        ),
      ),
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

  static const double _markSize = 18;
  static const double _markGap = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final mark = group.mark;
    if (mark == null) return SectionHeader(group.label);

    return Row(
      children: [
        IconMark(mark, size: _markSize, color: context.mood.inkMute),
        const SizedBox(width: _markGap),
        SectionHeader(group.label),
      ],
    );
  }
}
