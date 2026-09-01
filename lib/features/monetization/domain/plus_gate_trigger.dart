/// What the learner just hit, and what the sheet says about it.
///
/// **The trigger is data, not a widget.** One sheet serves every gated
/// surface; a new gate adds a case here rather than a second sheet that can
/// drift from the first. The header is what makes the pitch answer the
/// question the learner actually asked — a locked game names the module that
/// teaches it, which ADR-0005 calls *"a targeted course pitch at peak intent,
/// not a generic lock."*
///
/// Pure, so every header can be asserted without opening a sheet.
library;

import 'package:flutter/foundation.dart';

/// The gate a learner ran into.
@immutable
sealed class PlusGateTrigger {
  const PlusGateTrigger();

  /// The line above the pitch — what was just hit, in the learner's terms.
  String get header;
}

/// The free shelf refused another item.
class SavedShelfFull extends PlusGateTrigger {
  /// Creates a [SavedShelfFull] for a shelf holding [cap] items.
  const SavedShelfFull({required this.cap});

  /// The free cap the shelf stopped at.
  final int cap;

  @override
  String get header => 'Your free shelf is full at $cap.';
}

/// The Studio, which the free tier does not open.
///
/// Named as the thing it *is* rather than as a refusal: the grove is the one
/// gated surface a learner can already see the result of, on their own Profile,
/// so the header says what the door leads to rather than that it is shut.
class LockedStudio extends PlusGateTrigger {
  /// Creates a [LockedStudio].
  const LockedStudio();

  @override
  String get header => 'The Studio comes with the full course.';
}

/// A lesson the free tier does not carry.
class LockedLesson extends PlusGateTrigger {
  /// Creates a [LockedLesson] for the lesson called [title].
  const LockedLesson({required this.title});

  /// The lesson's own name, so the sheet names the thing that was tapped.
  final String title;

  @override
  String get header => '"$title" is part of the full course.';
}

/// A module the free tier does not carry.
///
/// Unquoted, unlike [LockedLesson]: a module's name is a section of the course
/// (*Processing*, *Roasting*), and quoting it would read as a title being
/// cited rather than a part being named.
class LockedModule extends PlusGateTrigger {
  /// Creates a [LockedModule] for the module called [title].
  const LockedModule({required this.title});

  /// The module's own name.
  final String title;

  @override
  String get header => '$title is part of the full course.';
}

/// The visual guides, which no free lesson reaches.
///
/// The free set is the first three lessons (ADR-0007) and the earliest guide
/// is taught by the sixth, so this shelf is not *not yet* for a free learner —
/// it is never. The header says so without saying it unkindly.
class LockedGuides extends PlusGateTrigger {
  /// Creates a [LockedGuides].
  const LockedGuides();

  @override
  String get header => 'The visual guides come with the full course.';
}

/// A game whose teaching lesson the free tier does not carry.
class LockedGame extends PlusGateTrigger {
  /// Creates a [LockedGame] taught by [moduleTitle].
  const LockedGame({required this.moduleTitle});

  /// The module that teaches the topic this game drills.
  final String moduleTitle;

  @override
  String get header => 'Taught in $moduleTitle.';
}
