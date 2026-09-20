/// The first-run hint's schedule, as data.
///
/// Nudge twice, then let the caption go. Pure and beside the widget, so the
/// timings are one table rather than four copies of four timers.
library;

/// One step of the nudge: where the element sits, and when it gets there.
typedef SwipeNudgeStep = ({Duration at, double offset});

/// How long the caption stays once the nudge is over.
const Duration swipeHintDuration = Duration(milliseconds: 4500);

/// How long it stays under reduced motion, which has no nudge to watch.
const Duration swipeHintReducedDuration = Duration(milliseconds: 5600);

/// How far the first nudge travels, signed like the drag it imitates. A
/// surface whose gesture goes the other way passes its own.
const double swipeDefaultNudge = -34;

/// How far the second nudge goes, as a share of the first.
const double swipeSecondNudgeShare = 0.65;

/// The two nudges of [nudge] px, out and back, as the hint plays them.
List<SwipeNudgeStep> swipeNudgeSteps(double nudge) => [
  (at: const Duration(milliseconds: 900), offset: nudge),
  (at: const Duration(milliseconds: 1650), offset: 0),
  (
    at: const Duration(milliseconds: 2050),
    offset: (nudge * swipeSecondNudgeShare).roundToDouble(),
  ),
  (at: const Duration(milliseconds: 2650), offset: 0),
];
