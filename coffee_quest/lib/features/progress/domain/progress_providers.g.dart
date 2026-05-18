// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(totalXp)
final totalXpProvider = TotalXpProvider._();

final class TotalXpProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
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

@ProviderFor(streak)
final streakProvider = StreakProvider._();

final class StreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
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

@ProviderFor(completedLessons)
final completedLessonsProvider = CompletedLessonsProvider._();

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

@ProviderFor(collectedCards)
final collectedCardsProvider = CollectedCardsProvider._();

final class CollectedCardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
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
