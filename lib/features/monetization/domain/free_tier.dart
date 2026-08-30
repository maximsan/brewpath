/// What a learner gets without buying, stated once.
///
/// ADR-0007 fixes the free tier as a **named lesson list**, and rules that
/// everything downstream re-derives from it — free games, the practice vocab
/// pool, every tier-dependent count. Growing the free tier later is a change
/// to this list and nothing else.
///
/// Pure, so the whole rule can be asserted against the shipped banks without a
/// database or a widget.
library;

/// The three lessons a learner keeps for good, in course order.
///
/// The opening arc — *what coffee is → the two species → what origin means* —
/// and the smallest free set that makes the shipped catalog true: each free
/// game sits on a lesson in this list.
const List<String> freeLessonIds = ['m1l1', 'm1l2', 'm1l3'];

/// Whether [lessonId] is free for everyone.
bool isLessonFree(String lessonId) => freeLessonIds.contains(lessonId);
