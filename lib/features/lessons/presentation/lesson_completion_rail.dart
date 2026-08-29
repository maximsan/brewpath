import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/progress/presentation/freeze_mark.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What a completion paid out, as the design's single divided card.
///
/// **One surface, not a stack of cards.** The design draws a bordered
/// `surface` panel whose rows are separated by hairlines
/// (`prototype/rewards.jsx:87-137`); the app used to float the points number
/// and hang loose Material cards under it, which reads as three unrelated
/// things rather than one receipt.
///
/// Renders nothing when a run paid nothing — a replay earns no points, no
/// freeze and no card, and an empty bordered box would announce that it should
/// have.
class LessonCompletionRail extends StatelessWidget {
  /// Creates a [LessonCompletionRail].
  const LessonCompletionRail({
    required this.pointsEarned,
    required this.freezeEarned,
    this.lessonCard,
    this.moduleCard,
    super.key,
  });

  /// Points this run paid. Zero on a replay, which draws no row.
  final int pointsEarned;

  /// Whether this run is the one that earned the streak freeze.
  final bool freezeEarned;

  /// The card the lesson handed over, if it did.
  final CoffeeCardModel? lessonCard;

  /// The Module Reward card, when this run closed its module.
  final CoffeeCardModel? moduleCard;

  /// The reassurance under [freezeKicker], in the design's words.
  static const String freezeSupport = "You're covered for one missed day.";

  /// The kicker over the freeze row — the first time most learners meet the
  /// word, which is the whole reason the row lives here.
  ///
  /// Written as it is spoken. `SmallcapsLabel` letters it uppercase, because
  /// that is the type rule rather than part of what the thing is called — and
  /// a screen reader is given the original casing instead of shouting it.
  static const String freezeKicker = 'Freeze earned';

  /// The kicker over a collected card.
  static const String cardKicker = 'New card unlocked';

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final rows = <Widget>[
      if (pointsEarned > 0) _PointsRow(points: pointsEarned),
      if (freezeEarned) const _FreezeRow(),
      for (final card in [lessonCard, moduleCard])
        if (card != null) _CardRow(card: card),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        border: Border.all(color: mood.rule),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              if (index > 0) Divider(height: 1, thickness: 1, color: mood.rule),
              rows[index],
            ],
          ],
        ),
      ),
    );
  }
}

/// What the run paid, centred and alone on its row — the design gives the
/// number its own line rather than a well and a kicker.
class _PointsRow extends StatelessWidget {
  const _PointsRow({required this.points});

  final int points;

  static const double _beanSize = 18;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Semantics(
      label: '$points points earned',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.base,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconMark(AppIcon.bean, size: _beanSize, color: mood.accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '+$points PTS',
              style: AppText.support(
                mood: mood,
                color: mood.ink,
                face: AppFace.mono,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The freeze introduction. Its position is the point: the design puts it at
/// the moment the freeze is *earned*, *"before they ever need one, not at the
/// moment they're told they lost a day"* — and the app's only other freeze
/// surface is exactly that later notice.
class _FreezeRow extends StatelessWidget {
  const _FreezeRow();

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return _RailRow(
      kicker: LessonCompletionRail.freezeKicker,
      support: LessonCompletionRail.freezeSupport,
      // The design's own mark, already shipped for the week strip's covered
      // cells: one dash, one meaning.
      well: FreezeMark(color: mood.accent, size: _RailRow.markSize),
    );
  }
}

/// A collectible the run handed over.
class _CardRow extends StatelessWidget {
  const _CardRow({required this.card});

  final CoffeeCardModel card;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return _RailRow(
      kicker: LessonCompletionRail.cardKicker,
      support: card.title,
      well: IconMark(
        moduleMark(card.iconName),
        size: _RailRow.markSize,
        color: mood.accent,
      ),
    );
  }
}

/// One payout row: a tinted well, an accent kicker, and the sentence under
/// it. The shape every row below the points line shares.
class _RailRow extends StatelessWidget {
  const _RailRow({
    required this.kicker,
    required this.support,
    required this.well,
  });

  /// The smallcaps label over the line — the design's accent kicker.
  final String kicker;

  /// What the row actually says.
  final String support;

  /// The mark inside the tinted well.
  final Widget well;

  /// Edge of the well the mark sits in.
  static const double _wellSize = 34;

  /// The mark's own size inside that well.
  static const double markSize = 18;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Semantics(
      label: '$kicker. $support',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: _wellSize,
              height: _wellSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: mood.accentWash,
                borderRadius: BorderRadius.circular(AppRadii.chrome),
              ),
              child: well,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // `accentText`, not raw accent: this is the accent picked
                  // as a small label, which is the sentence that token owns.
                  SmallcapsLabel(kicker, color: mood.accentText),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    support,
                    style: AppText.support(
                      mood: mood,
                      color: mood.ink,
                      face: AppFace.control,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
