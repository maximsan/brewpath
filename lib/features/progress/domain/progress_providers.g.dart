// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's total XP.

@ProviderFor(totalXp)
final totalXpProvider = TotalXpProvider._();

/// The user's total XP.

final class TotalXpProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// The user's total XP.
  TotalXpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalXpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalXpHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalXp(ref);
  }
}

String _$totalXpHash() => r'9d152d22babc01660d17d3b49a7aba3eeabc930f';

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

String _$streakHash() => r'eb7a2c35c7e2f7624444b1e6ad37e22bf96500bb';

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

/// Highest tree stage ever reached, as the stored snapshot holds it.
///
/// The stored half only. `ClearedByReset.treeStage` describes itself as read
/// `max(stored, derived)`, but nothing in the app writes the field or derives
/// a stage yet, so the max would be over one operand — see #150. Deriving from
/// the completed-lesson count to fill the gap is precisely the
/// growing-the-course-shrinks-the-tree bug that field's doc warns against, so
/// this reads what is stored and nothing more.

@ProviderFor(treeStage)
final treeStageProvider = TreeStageProvider._();

/// Highest tree stage ever reached, as the stored snapshot holds it.
///
/// The stored half only. `ClearedByReset.treeStage` describes itself as read
/// `max(stored, derived)`, but nothing in the app writes the field or derives
/// a stage yet, so the max would be over one operand — see #150. Deriving from
/// the completed-lesson count to fill the gap is precisely the
/// growing-the-course-shrinks-the-tree bug that field's doc warns against, so
/// this reads what is stored and nothing more.

final class TreeStageProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Highest tree stage ever reached, as the stored snapshot holds it.
  ///
  /// The stored half only. `ClearedByReset.treeStage` describes itself as read
  /// `max(stored, derived)`, but nothing in the app writes the field or derives
  /// a stage yet, so the max would be over one operand — see #150. Deriving from
  /// the completed-lesson count to fill the gap is precisely the
  /// growing-the-course-shrinks-the-tree bug that field's doc warns against, so
  /// this reads what is stored and nothing more.
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

String _$treeStageHash() => r'9e01df709be6a8fd655606a9d036d2050a24a675';
