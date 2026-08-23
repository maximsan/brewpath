import 'package:brew_path/features/progress/domain/freeze_status_line.dart';
import 'package:brew_path/features/progress/domain/streak_week.dart';
import 'package:brew_path/features/progress/presentation/freeze_mark.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The strip's two rendered sizes: large on the streak screen, small where it
/// rides inside a card.
enum WeekStripSize {
  /// Streak-screen size.
  large,

  /// Card size — the Profile tile and, later, the share card.
  small,
}

/// The week strip — seven cells, Monday first, each read straight from the
/// derived day list: done, frozen, or empty, with a position cue on today.
///
/// The widget renders what it is handed and derives nothing: the cells come
/// from the landed `weekStrip` derivation, never from count arithmetic — the
/// prototype's count-based fill drops an active day whenever a freeze sits
/// inside the visible week (#26).
class WeekStrip extends StatelessWidget {
  /// Creates a [WeekStrip].
  const WeekStrip({
    required this.days,
    this.size = WeekStripSize.large,
    super.key,
  });

  /// The seven cells, Monday first, from the `weekStrip` derivation.
  final List<StreakDay> days;

  /// Rendered size.
  final WeekStripSize size;

  static const double _largeCell = 32;
  static const double _smallCell = 14;
  static const double _largeGap = 10;
  static const double _smallGap = 5;
  static const double _todayRingWidth = 2;

  double get _cell => size == WeekStripSize.large ? _largeCell : _smallCell;
  double get _gap => size == WeekStripSize.large ? _largeGap : _smallGap;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < days.length; index++) ...[
          if (index > 0) SizedBox(width: _gap),
          _cellFor(
            days[index],
            weekdayNames[index % weekdayNames.length],
            mood,
          ),
        ],
      ],
    );
  }

  Widget _cellFor(StreakDay day, String weekdayName, MoodColors mood) {
    final String stateWord;
    switch (day.mark) {
      case StreakDayMark.done:
        stateWord = 'done';
      case StreakDayMark.frozen:
        stateWord = 'covered by a freeze';
      case StreakDayMark.empty:
        stateWord = day.isToday ? 'still open' : 'empty';
    }
    return Semantics(
      label: '$weekdayName, $stateWord',
      child: Container(
        width: _cell,
        height: _cell,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: switch (day.mark) {
            StreakDayMark.done => mood.accent,
            StreakDayMark.frozen => mood.surface2,
            StreakDayMark.empty => Colors.transparent,
          },
          // Today keeps a position cue whatever its mark, so a reset streak
          // never reads as a credited day — the cue is a ring, not a fill.
          border: day.isToday
              ? Border.all(color: mood.ink, width: _todayRingWidth)
              : day.mark == StreakDayMark.empty
              ? Border.all(color: mood.rule)
              : null,
        ),
        child: day.mark == StreakDayMark.frozen
            ? Center(
                child: FreezeMark(
                  color: mood.accent,
                  size: _cell * _markFraction,
                ),
              )
            : null,
      ),
    );
  }

  /// The dash's share of its cell.
  static const double _markFraction = 0.55;
}
