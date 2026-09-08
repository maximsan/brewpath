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
/// Unquoted, unlike [LockedLesson]: a module name is a section of the course,
/// not a title.
class LockedModule extends PlusGateTrigger {
  /// Creates a [LockedModule] for the module called [title].
  const LockedModule({required this.title});

  /// The module's own name.
  final String title;

  @override
  String get header => '$title is part of the full course.';
}

/// The visual guides, which no free lesson reaches: free is the first three
/// lessons (ADR-0007) and the earliest guide is taught by the sixth.
class LockedGuides extends PlusGateTrigger {
  /// Creates a [LockedGuides].
  const LockedGuides();

  @override
  String get header => 'The visual guides come with the full course.';
}

/// The full entry behind a term the free tier reads only in short.
///
/// Term of the Day's one action promises the *full* entry, so for a learner
/// without the course it has to raise this rather than deliver the short
/// explanation they are already looking at, which the design says in as many
/// words.
class LockedFullEntry extends PlusGateTrigger {
  /// Creates a [LockedFullEntry] for the term called [term].
  const LockedFullEntry({required this.term});

  /// The word itself, so the sheet names what was tapped.
  final String term;

  @override
  String get header => 'The full entry for "$term" comes with the course.';
}

/// The free day's ration of activities, already spent.
///
/// The only trigger raised by *how much* a learner has done rather than by
/// what they reached for, so the header counts rather than names. Removing the
/// cap is what the pitch's *Practice without limits* sells, which is why the
/// cap-hit opens this sheet instead of a dead "come back tomorrow" (#29, #216).
class DailyAllowanceSpent extends PlusGateTrigger {
  /// Creates a [DailyAllowanceSpent] for a day that holds [cap] activities.
  const DailyAllowanceSpent({required this.cap});

  /// How many a free day holds. Carried rather than written into the sentence
  /// so the copy cannot outlive the rule.
  final int cap;

  @override
  String get header => "You've done today's $cap free activities.";
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
