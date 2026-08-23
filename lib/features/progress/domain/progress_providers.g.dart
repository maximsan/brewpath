// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The learner's points total — **derived, never stored**.
///
/// Two payouts exist and both already leave a record: a lesson's flat ten is
/// written onto its completion row, and a challenge's five is implied by its id
/// sitting in the completed set. Summing them here means the total cannot drift
/// from what was actually earned, and Reset Progress needs no rule of its own —
/// clearing the completions clears the total by construction.
///
/// It used to be a counter on the settings row that every payout incremented.
/// A counter is a second copy of a derivable fact, and the fact it copied was
/// computed under rules the app no longer plays (#16).

@ProviderFor(totalPoints)
final totalPointsProvider = TotalPointsProvider._();

/// The learner's points total — **derived, never stored**.
///
/// Two payouts exist and both already leave a record: a lesson's flat ten is
/// written onto its completion row, and a challenge's five is implied by its id
/// sitting in the completed set. Summing them here means the total cannot drift
/// from what was actually earned, and Reset Progress needs no rule of its own —
/// clearing the completions clears the total by construction.
///
/// It used to be a counter on the settings row that every payout incremented.
/// A counter is a second copy of a derivable fact, and the fact it copied was
/// computed under rules the app no longer plays (#16).

final class TotalPointsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// The learner's points total — **derived, never stored**.
  ///
  /// Two payouts exist and both already leave a record: a lesson's flat ten is
  /// written onto its completion row, and a challenge's five is implied by its id
  /// sitting in the completed set. Summing them here means the total cannot drift
  /// from what was actually earned, and Reset Progress needs no rule of its own —
  /// clearing the completions clears the total by construction.
  ///
  /// It used to be a counter on the settings row that every payout incremented.
  /// A counter is a second copy of a derivable fact, and the fact it copied was
  /// computed under rules the app no longer plays (#16).
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

String _$totalPointsHash() => r'23c4d5de9b6d4b471eeec26efd78d5fc7adf278a';

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

String _$activeDaySetHash() => r'8dc582484d95ced70210f85fe37c80552e124dd8';

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

String _$weekStripDaysHash() => r'3a214a34f33565306490049caddf4e4bcf264195';

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

String _$streakStatusHash() => r'7ecb80964f632e911995c2d8b3c58beca869a9a4';

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

/// All of the user's completed-lesson records.

@ProviderFor(completedLessons)
final completedLessonsProvider = CompletedLessonsProvider._();

/// All of the user's completed-lesson records.

final class CompletedLessonsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProgressRecord>>,
          List<ProgressRecord>,
          FutureOr<List<ProgressRecord>>
        >
    with
        $FutureModifier<List<ProgressRecord>>,
        $FutureProvider<List<ProgressRecord>> {
  /// All of the user's completed-lesson records.
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
  $FutureProviderElement<List<ProgressRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProgressRecord>> create(Ref ref) {
    return completedLessons(ref);
  }
}

String _$completedLessonsHash() => r'c29c67109f5f475a6482b2f49c6e10eb5a32e746';

/// The ids of all cards the user has collected.

@ProviderFor(collectedCards)
final collectedCardsProvider = CollectedCardsProvider._();

/// The ids of all cards the user has collected.

final class CollectedCardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// The ids of all cards the user has collected.
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

String _$collectedCardsHash() => r'3af5e2e1b76e38bda84b804b5a114b3cd9874c13';

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

String _$treeStageHash() => r'b0c44f97033fd2ac052c14d89e26465c313f17f8';

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
