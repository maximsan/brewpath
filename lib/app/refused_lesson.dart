import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'refused_lesson.g.dart';

/// The lesson the gate turned away, held until the offer can be raised.
///
/// The redirect's job is to refuse; it cannot open a sheet, because it runs
/// while go_router is still resolving a location. So it leaves the lesson
/// here, and the router raises the offer once the frame it bounced to is up.
/// Without that the learner is moved somewhere they did not ask for with no
/// word about why — the one thing a wall must never do.
///
/// **Deliberately a plain object, not notifier state**, for the same reason
/// `PendingLink` is: the redirect writes it, and provider state mutated there
/// would tick `refreshListenable` and re-enter the redirect it was called
/// from.
class RefusedLesson {
  String? _lessonId;

  /// Records that the route to [lessonId] was refused.
  ///
  /// **The last refusal wins**, unlike a held deep link. This is a report of
  /// what just happened rather than an arrival to resume, so a stale one is
  /// worth less than the current one.
  // ignore: use_setters_to_change_properties
  void refuse(String lessonId) => _lessonId = lessonId;

  /// Returns the refused lesson and forgets it, or null when none is held.
  ///
  /// One-shot, so a single refusal raises a single offer.
  String? take() {
    final lessonId = _lessonId;
    _lessonId = null;
    return lessonId;
  }
}

/// Provides the app-lifetime [RefusedLesson].
///
/// Function-style despite holding mutable state, because the mutation is the
/// object's own and must not rebuild the router — see [RefusedLesson].
@Riverpod(keepAlive: true)
RefusedLesson refusedLesson(Ref ref) => RefusedLesson();
