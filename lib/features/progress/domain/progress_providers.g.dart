// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The learner's points total — **derived, never stored**.
///
/// Two payouts exist and both leave a record: a finished lesson is worth the
/// flat ten it authors, and a challenge's five is implied by its id sitting in
/// the completed set. Summing them here means the total cannot drift from what
/// was actually earned, and Reset Progress needs no rule of its own — clearing
/// the completions clears the total by construction.
///
/// **The payout is read off the course, not off a copy of it.** The old
/// completions table banked the points on the row; the snapshot stores which
/// lessons are finished and nothing about what they paid, because what a
/// lesson is worth is a fact about the lesson. A finished lesson the content
/// no longer carries therefore pays nothing, which is the same answer a
/// dropped row would have given.

@ProviderFor(totalPoints)
final totalPointsProvider = TotalPointsProvider._();

/// The learner's points total — **derived, never stored**.
///
/// Two payouts exist and both leave a record: a finished lesson is worth the
/// flat ten it authors, and a challenge's five is implied by its id sitting in
/// the completed set. Summing them here means the total cannot drift from what
/// was actually earned, and Reset Progress needs no rule of its own — clearing
/// the completions clears the total by construction.
///
/// **The payout is read off the course, not off a copy of it.** The old
/// completions table banked the points on the row; the snapshot stores which
/// lessons are finished and nothing about what they paid, because what a
/// lesson is worth is a fact about the lesson. A finished lesson the content
/// no longer carries therefore pays nothing, which is the same answer a
/// dropped row would have given.

final class TotalPointsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// The learner's points total — **derived, never stored**.
  ///
  /// Two payouts exist and both leave a record: a finished lesson is worth the
  /// flat ten it authors, and a challenge's five is implied by its id sitting in
  /// the completed set. Summing them here means the total cannot drift from what
  /// was actually earned, and Reset Progress needs no rule of its own — clearing
  /// the completions clears the total by construction.
  ///
  /// **The payout is read off the course, not off a copy of it.** The old
  /// completions table banked the points on the row; the snapshot stores which
  /// lessons are finished and nothing about what they paid, because what a
  /// lesson is worth is a fact about the lesson. A finished lesson the content
  /// no longer carries therefore pays nothing, which is the same answer a
  /// dropped row would have given.
  TotalPointsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalPointsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalPointsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalPoints(ref);
  }
}

String _$totalPointsHash() => r'cf138c6951ffe7e42a3e3bcb0631324804feae2d';

/// The streak, the freeze and the covered days, derived from the snapshot.
///
/// Read against `DateTime.now()`, so it is only as fresh as the last time it
/// was built — which is why `DayRolloverWatcher` invalidates this on a resume
/// that crossed midnight, rather than letting a value computed before it stand.
///
/// The day set it folds is assembled by [streakDaySet], which also backfills
/// a learner whose completions predate the day set — see it for why the three
/// sources are unioned rather than ranked.
/// The qualifying-day set every streak surface folds over — one derivation,
/// so the engine, the save notice and the week strip can never disagree on
/// which days count.

@ProviderFor(activeDaySet)
final activeDaySetProvider = ActiveDaySetProvider._();

/// The streak, the freeze and the covered days, derived from the snapshot.
///
/// Read against `DateTime.now()`, so it is only as fresh as the last time it
/// was built — which is why `DayRolloverWatcher` invalidates this on a resume
/// that crossed midnight, rather than letting a value computed before it stand.
///
/// The day set it folds is assembled by [streakDaySet], which also backfills
/// a learner whose completions predate the day set — see it for why the three
/// sources are unioned rather than ranked.
/// The qualifying-day set every streak surface folds over — one derivation,
/// so the engine, the save notice and the week strip can never disagree on
/// which days count.

final class ActiveDaySetProvider
    extends
        $FunctionalProvider<AsyncValue<Set<int>>, Set<int>, FutureOr<Set<int>>>
    with $FutureModifier<Set<int>>, $FutureProvider<Set<int>> {
  /// The streak, the freeze and the covered days, derived from the snapshot.
  ///
  /// Read against `DateTime.now()`, so it is only as fresh as the last time it
  /// was built — which is why `DayRolloverWatcher` invalidates this on a resume
  /// that crossed midnight, rather than letting a value computed before it stand.
  ///
  /// The day set it folds is assembled by [streakDaySet], which also backfills
  /// a learner whose completions predate the day set — see it for why the three
  /// sources are unioned rather than ranked.
  /// The qualifying-day set every streak surface folds over — one derivation,
  /// so the engine, the save notice and the week strip can never disagree on
  /// which days count.
  ActiveDaySetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeDaySetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeDaySetHash();

  @$internal
  @override
  $FutureProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Set<int>> create(Ref ref) {
    return activeDaySet(ref);
  }
}

String _$activeDaySetHash() => r'4b105af611fae87cdac82b149190852aaae5df4a';

/// The current week's seven cells, ready for any strip host — one
/// derivation, so the streak screen, the Profile tile and the share card can
/// never disagree about a day.

@ProviderFor(weekStripDays)
final weekStripDaysProvider = WeekStripDaysProvider._();

/// The current week's seven cells, ready for any strip host — one
/// derivation, so the streak screen, the Profile tile and the share card can
/// never disagree about a day.

final class WeekStripDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StreakDay>>,
          List<StreakDay>,
          FutureOr<List<StreakDay>>
        >
    with $FutureModifier<List<StreakDay>>, $FutureProvider<List<StreakDay>> {
  /// The current week's seven cells, ready for any strip host — one
  /// derivation, so the streak screen, the Profile tile and the share card can
  /// never disagree about a day.
  WeekStripDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weekStripDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weekStripDaysHash();

  @$internal
  @override
  $FutureProviderElement<List<StreakDay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StreakDay>> create(Ref ref) {
    return weekStripDays(ref);
  }
}

String _$weekStripDaysHash() => r'5e751b5da062605576b2c316ab0b9385410ead7b';

/// The derived streak state — the engine's fold over [activeDaySet].

@ProviderFor(streakStatus)
final streakStatusProvider = StreakStatusProvider._();

/// The derived streak state — the engine's fold over [activeDaySet].

final class StreakStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreakStatus>,
          StreakStatus,
          FutureOr<StreakStatus>
        >
    with $FutureModifier<StreakStatus>, $FutureProvider<StreakStatus> {
  /// The derived streak state — the engine's fold over [activeDaySet].
  StreakStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakStatusHash();

  @$internal
  @override
  $FutureProviderElement<StreakStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StreakStatus> create(Ref ref) {
    return streakStatus(ref);
  }
}

String _$streakStatusHash() => r'323891ffdb6a12228e1d8c1c2a5720dc240fddb8';

/// The user's current streak in days.

@ProviderFor(streak)
final streakProvider = StreakProvider._();

/// The user's current streak in days.

final class StreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// The user's current streak in days.
  StreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return streak(ref);
  }
}

String _$streakHash() => r'261493eb16a2e61df9df93a16935627a6b845256';

/// The lessons the learner has finished, off the progress snapshot.
///
/// **The snapshot is the record** (#115). It used to be the completions
/// table, which is now written by nothing and dropped by #116; the two fields
/// read here — the day each lesson was first finished, and the best result
/// stored for it — are what those rows carried that anything still asks for.

@ProviderFor(completedLessons)
final completedLessonsProvider = CompletedLessonsProvider._();

/// The lessons the learner has finished, off the progress snapshot.
///
/// **The snapshot is the record** (#115). It used to be the completions
/// table, which is now written by nothing and dropped by #116; the two fields
/// read here — the day each lesson was first finished, and the best result
/// stored for it — are what those rows carried that anything still asks for.

final class CompletedLessonsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CompletedLessons>,
          CompletedLessons,
          FutureOr<CompletedLessons>
        >
    with $FutureModifier<CompletedLessons>, $FutureProvider<CompletedLessons> {
  /// The lessons the learner has finished, off the progress snapshot.
  ///
  /// **The snapshot is the record** (#115). It used to be the completions
  /// table, which is now written by nothing and dropped by #116; the two fields
  /// read here — the day each lesson was first finished, and the best result
  /// stored for it — are what those rows carried that anything still asks for.
  CompletedLessonsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedLessonsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedLessonsHash();

  @$internal
  @override
  $FutureProviderElement<CompletedLessons> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CompletedLessons> create(Ref ref) {
    return completedLessons(ref);
  }
}

String _$completedLessonsHash() => r'0e4e21bf097fdda5d742ff4cfaea3c38940f68a7';

/// The ids of the lessons the learner has finished.
///
/// Named once because the answer is asked for by things that have no use for
/// the records themselves — the router's course wall, and the count of lessons
/// still ahead — and re-deriving a set at each of them is a second place for
/// the question to be answered differently.

@ProviderFor(completedLessonIds)
final completedLessonIdsProvider = CompletedLessonIdsProvider._();

/// The ids of the lessons the learner has finished.
///
/// Named once because the answer is asked for by things that have no use for
/// the records themselves — the router's course wall, and the count of lessons
/// still ahead — and re-deriving a set at each of them is a second place for
/// the question to be answered differently.

final class CompletedLessonIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// The ids of the lessons the learner has finished.
  ///
  /// Named once because the answer is asked for by things that have no use for
  /// the records themselves — the router's course wall, and the count of lessons
  /// still ahead — and re-deriving a set at each of them is a second place for
  /// the question to be answered differently.
  CompletedLessonIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedLessonIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedLessonIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return completedLessonIds(ref);
  }
}

String _$completedLessonIdsHash() =>
    r'fb927706b8da83b2b28525d2ed2d345baa2acc64';

/// The ids of all cards the user has collected, off the progress snapshot.
///
/// Stored in full rather than derived from the finished lessons: the lesson id
/// space has been rewritten once already on this project, and a derived set
/// would have silently revoked every card the rename touched.

@ProviderFor(collectedCards)
final collectedCardsProvider = CollectedCardsProvider._();

/// The ids of all cards the user has collected, off the progress snapshot.
///
/// Stored in full rather than derived from the finished lessons: the lesson id
/// space has been rewritten once already on this project, and a derived set
/// would have silently revoked every card the rename touched.

final class CollectedCardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// The ids of all cards the user has collected, off the progress snapshot.
  ///
  /// Stored in full rather than derived from the finished lessons: the lesson id
  /// space has been rewritten once already on this project, and a derived set
  /// would have silently revoked every card the rename touched.
  CollectedCardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectedCardsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectedCardsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return collectedCards(ref);
  }
}

String _$collectedCardsHash() => r'442ce2ea146aaad92a581ece9811b9ca444481d6';

/// Highest tree stage ever reached: `max(stored, derived)`, as the field has
/// always described itself.
///
/// The stored half is written by first-time lesson completion and never goes
/// down. The derived half is what the *current* course size implies, and it
/// is here to heal a learner whose stored stage predates the writer — taking
/// the max is what stops it doing harm, because a grown course derives lower
/// for the same learner and the stored floor wins.

@ProviderFor(treeStage)
final treeStageProvider = TreeStageProvider._();

/// Highest tree stage ever reached: `max(stored, derived)`, as the field has
/// always described itself.
///
/// The stored half is written by first-time lesson completion and never goes
/// down. The derived half is what the *current* course size implies, and it
/// is here to heal a learner whose stored stage predates the writer — taking
/// the max is what stops it doing harm, because a grown course derives lower
/// for the same learner and the stored floor wins.

final class TreeStageProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Highest tree stage ever reached: `max(stored, derived)`, as the field has
  /// always described itself.
  ///
  /// The stored half is written by first-time lesson completion and never goes
  /// down. The derived half is what the *current* course size implies, and it
  /// is here to heal a learner whose stored stage predates the writer — taking
  /// the max is what stops it doing harm, because a grown course derives lower
  /// for the same learner and the stored floor wins.
  TreeStageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'treeStageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$treeStageHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return treeStage(ref);
  }
}

String _$treeStageHash() => r'7cbadb3b2897f16b1ae4deb444d49e6b8335090b';

/// The learner's progress through the core course.

@ProviderFor(coreLessonProgress)
final coreLessonProgressProvider = CoreLessonProgressProvider._();

/// The learner's progress through the core course.

final class CoreLessonProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<CoreLessonProgress>,
          CoreLessonProgress,
          FutureOr<CoreLessonProgress>
        >
    with
        $FutureModifier<CoreLessonProgress>,
        $FutureProvider<CoreLessonProgress> {
  /// The learner's progress through the core course.
  CoreLessonProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coreLessonProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coreLessonProgressHash();

  @$internal
  @override
  $FutureProviderElement<CoreLessonProgress> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CoreLessonProgress> create(Ref ref) {
    return coreLessonProgress(ref);
  }
}

String _$coreLessonProgressHash() =>
    r'f871cef902b7eb561382140b452faf6eaf4fa846';

/// The month the Profile's closing line names, or null before there is one.
///
/// The rule is [deriveJoinedDate]'s: the install stamp when the database
/// recorded one, and the earliest active day for every device created before
/// it did. The active-day set is read either way rather than only on the
/// fallback, so a stamp arriving later cannot change which providers this one
/// depends on mid-session.

@ProviderFor(joinedDate)
final joinedDateProvider = JoinedDateProvider._();

/// The month the Profile's closing line names, or null before there is one.
///
/// The rule is [deriveJoinedDate]'s: the install stamp when the database
/// recorded one, and the earliest active day for every device created before
/// it did. The active-day set is read either way rather than only on the
/// fallback, so a stamp arriving later cannot change which providers this one
/// depends on mid-session.

final class JoinedDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateTime?>,
          DateTime?,
          FutureOr<DateTime?>
        >
    with $FutureModifier<DateTime?>, $FutureProvider<DateTime?> {
  /// The month the Profile's closing line names, or null before there is one.
  ///
  /// The rule is [deriveJoinedDate]'s: the install stamp when the database
  /// recorded one, and the earliest active day for every device created before
  /// it did. The active-day set is read either way rather than only on the
  /// fallback, so a stamp arriving later cannot change which providers this one
  /// depends on mid-session.
  JoinedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'joinedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$joinedDateHash();

  @$internal
  @override
  $FutureProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime?> create(Ref ref) {
    return joinedDate(ref);
  }
}

String _$joinedDateHash() => r'c74627030e9873bdde731c55e3c522867982fe9f';

/// The planted grove, resolved against the banks into one matrix and one scale.
///
/// Joined here rather than in the widget so the tree stays ignorant of species
/// and lights: it receives a treatment, not a pair of ids to look up.

@ProviderFor(groveTreatment)
final groveTreatmentProvider = GroveTreatmentProvider._();

/// The planted grove, resolved against the banks into one matrix and one scale.
///
/// Joined here rather than in the widget so the tree stays ignorant of species
/// and lights: it receives a treatment, not a pair of ids to look up.

final class GroveTreatmentProvider
    extends
        $FunctionalProvider<
          AsyncValue<GroveTreatment>,
          GroveTreatment,
          FutureOr<GroveTreatment>
        >
    with $FutureModifier<GroveTreatment>, $FutureProvider<GroveTreatment> {
  /// The planted grove, resolved against the banks into one matrix and one scale.
  ///
  /// Joined here rather than in the widget so the tree stays ignorant of species
  /// and lights: it receives a treatment, not a pair of ids to look up.
  GroveTreatmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groveTreatmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groveTreatmentHash();

  @$internal
  @override
  $FutureProviderElement<GroveTreatment> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GroveTreatment> create(Ref ref) {
    return groveTreatment(ref);
  }
}

String _$groveTreatmentHash() => r'10d2583fea378ddaccfb0e25020882e62f7897a9';
