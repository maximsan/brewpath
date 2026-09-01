/// The two switches a drill's results copy turns on.
///
/// The design states them once, for every drill in the app: *"the results
/// screen scores n / N and switches copy at 80% and 50%"* (`ds-content.js`,
/// **Round length**). The **words** at each band belong to the drill — a
/// mini-game and a vocab round should not read as though one wrote the other —
/// but the marks themselves are one rule, and a second copy of `0.8` is a
/// second rule waiting to disagree.
library;

/// The four-in-five mark the companion celebrates at.
const double drillCelebrationMark = 0.8;

/// The halfway mark, below which the copy stops congratulating.
const double drillMiddlingMark = 0.5;

/// Whether [score] of [total] is at or above [drillCelebrationMark].
///
/// A run with no rounds never celebrates, which also keeps the ratio from
/// dividing by zero.
bool isCelebratoryScore({required int score, required int total}) =>
    total > 0 && score / total >= drillCelebrationMark;

/// Whether [score] of [total] is at or above [drillMiddlingMark].
bool isMiddlingScore({required int score, required int total}) =>
    total > 0 && score / total >= drillMiddlingMark;
