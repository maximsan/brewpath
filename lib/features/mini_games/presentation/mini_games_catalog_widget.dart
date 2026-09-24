import 'dart:async';

import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/learn/presentation/practice/practice_sub_group.dart';
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
import 'package:flutter/material.dart';

/// The mini-game catalog under Today → Practice → Games: one collapsible
/// sub-group per kind, in the fixed order [miniGameKinds] declares.
///
/// **Every row opens its intro.** Whether a game can actually be played is
/// disclosed on the intro's own action, never here: a row dimmed for a missing
/// renderer looks exactly like one behind the paywall.
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

  @override
  Widget build(BuildContext context) {
    if (formats.isEmpty) return const _EmptyCatalog();

    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groupCatalogByKind(formats))
          PracticeSubGroup(
            label: group.label,
            count: group.games.length,
            // A sub-group is locked when every game in it fails the app's own
            // open test — the tier rule, never "its module is m1" (ADR-0007).
            locked: group.games.every(
              (format) => !isMiniGameOpen(format, hasCourse: hasCourse),
            ),
            mark: group.mark == null
                ? null
                : IconMark(
                    group.mark!,
                    size: PracticeSubGroup.markSize,
                    color: mood.inkMute,
                  ),
            children: [
              for (final format in group.games)
                _FormatRow(format: format, hasCourse: hasCourse),
            ],
          ),
      ],
    );
  }
}

/// One game as a row that starts something: its name over the topic it
/// drills, ending in a chevron — or a lock.
///
/// A lock is an offer, not a dead end: the tap that cannot start a run opens
/// the pitch for the module that teaches this game's topic.
class _FormatRow extends StatelessWidget {
  const _FormatRow({required this.format, required this.hasCourse});

  final MiniGameFormat format;
  final bool hasCourse;

  static const String _lockedHint = 'Shows the module that teaches it';

  @override
  Widget build(BuildContext context) {
    final isOpen = isMiniGameOpen(format, hasCourse: hasCourse);

    return ReplayRow(
      title: format.title,
      sub: format.topic,
      locked: !isOpen,
      starts: true,
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
