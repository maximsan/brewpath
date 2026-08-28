import 'package:brew_path/features/lessons/presentation/cards/sequence_order.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The badge's drawn size, from the design source's own `.seq-item .num`.
const double _size = 24;

/// The place a step has been given in the run, or an empty well before it has
/// one.
///
/// Filled rather than outlined once a position is assigned, because the fill is
/// what makes the run readable at a glance: the learner is reading a column of
/// numbers, not a column of steps, by the time they check their answer.
class SequenceStepNumber extends StatelessWidget {
  /// Creates a [SequenceStepNumber].
  const SequenceStepNumber({
    required this.position,
    required this.mark,
    super.key,
  });

  /// The one-based place this step was given, or null while it has none.
  final int? position;

  /// What the badge is saying at this moment.
  final SequenceStepMark mark;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final fill = _fill(mood);

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: fill ?? mood.rule),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        position == null ? '' : '$position',
        style: AppText.label(mood: mood, color: _ink(mood)),
      ),
    );
  }

  Color? _fill(MoodColors mood) => switch (mark) {
    SequenceStepMark.unplaced => null,
    SequenceStepMark.placed => mood.accent,
    SequenceStepMark.right => mood.sage,
    SequenceStepMark.wrong => mood.berry,
  };

  /// Ink on the badge. A marked badge is read on a solid mood colour, so it
  /// takes the surface rather than the accent's own ink — sage and berry have
  /// no paired ink token, and the surface is what the design puts on them.
  Color _ink(MoodColors mood) => switch (mark) {
    SequenceStepMark.unplaced => mood.inkMute,
    SequenceStepMark.placed => mood.accentInk,
    SequenceStepMark.right || SequenceStepMark.wrong => mood.surface,
  };
}
