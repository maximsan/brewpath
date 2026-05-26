// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learn_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(modulesWithProgress)
final modulesWithProgressProvider = ModulesWithProgressProvider._();

final class ModulesWithProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ModuleWithProgress>>,
          List<ModuleWithProgress>,
          FutureOr<List<ModuleWithProgress>>
        >
    with
        $FutureModifier<List<ModuleWithProgress>>,
        $FutureProvider<List<ModuleWithProgress>> {
  ModulesWithProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modulesWithProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modulesWithProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<ModuleWithProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ModuleWithProgress>> create(Ref ref) {
    return modulesWithProgress(ref);
  }
}

String _$modulesWithProgressHash() =>
    r'4edce864510a70fd09058fc8405de592533acde4';

@ProviderFor(todayLesson)
final todayLessonProvider = TodayLessonProvider._();

final class TodayLessonProvider
    extends
        $FunctionalProvider<
          AsyncValue<LessonModel?>,
          LessonModel?,
          FutureOr<LessonModel?>
        >
    with $FutureModifier<LessonModel?>, $FutureProvider<LessonModel?> {
  TodayLessonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayLessonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayLessonHash();

  @$internal
  @override
  $FutureProviderElement<LessonModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LessonModel?> create(Ref ref) {
    return todayLesson(ref);
  }
}

String _$todayLessonHash() => r'874e4a4903c7e12c16470cd2b56c2772a6d24b81';

/// Flat ordered list of every lesson, joined with its module so the Learn
/// screen can group them without re-querying.

@ProviderFor(allLessonsWithModule)
final allLessonsWithModuleProvider = AllLessonsWithModuleProvider._();

/// Flat ordered list of every lesson, joined with its module so the Learn
/// screen can group them without re-querying.

final class AllLessonsWithModuleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LessonWithModule>>,
          List<LessonWithModule>,
          FutureOr<List<LessonWithModule>>
        >
    with
        $FutureModifier<List<LessonWithModule>>,
        $FutureProvider<List<LessonWithModule>> {
  /// Flat ordered list of every lesson, joined with its module so the Learn
  /// screen can group them without re-querying.
  AllLessonsWithModuleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allLessonsWithModuleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allLessonsWithModuleHash();

  @$internal
  @override
  $FutureProviderElement<List<LessonWithModule>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LessonWithModule>> create(Ref ref) {
    return allLessonsWithModule(ref);
  }
}

String _$allLessonsWithModuleHash() =>
    r'139550831d84efbe1ace4a758117f9db8e52c788';

/// How many practiceable steps the user currently has for each game type,
/// counting only steps that live in lessons the user has completed. Drives
/// the enabled state of the "Practice by Game Type" chips on the Learn screen.

@ProviderFor(gameTypePracticeCounts)
final gameTypePracticeCountsProvider = GameTypePracticeCountsProvider._();

/// How many practiceable steps the user currently has for each game type,
/// counting only steps that live in lessons the user has completed. Drives
/// the enabled state of the "Practice by Game Type" chips on the Learn screen.

final class GameTypePracticeCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          FutureOr<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  /// How many practiceable steps the user currently has for each game type,
  /// counting only steps that live in lessons the user has completed. Drives
  /// the enabled state of the "Practice by Game Type" chips on the Learn screen.
  GameTypePracticeCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameTypePracticeCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameTypePracticeCountsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    return gameTypePracticeCounts(ref);
  }
}

String _$gameTypePracticeCountsHash() =>
    r'2741e131a3fb320d78606fd3380d4d6df0a92b7f';
