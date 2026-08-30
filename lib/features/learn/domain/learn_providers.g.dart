// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learn_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All modules paired with their derived completion/lock state.

@ProviderFor(modulesWithProgress)
final modulesWithProgressProvider = ModulesWithProgressProvider._();

/// All modules paired with their derived completion/lock state.

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
  /// All modules paired with their derived completion/lock state.
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
    r'45160b369ab85aeae0c66800ddabbe5556c04d4a';

/// The next uncompleted lesson in order, or null if all are complete.

@ProviderFor(todayLesson)
final todayLessonProvider = TodayLessonProvider._();

/// The next uncompleted lesson in order, or null if all are complete.

final class TodayLessonProvider
    extends
        $FunctionalProvider<
          AsyncValue<LessonModel?>,
          LessonModel?,
          FutureOr<LessonModel?>
        >
    with $FutureModifier<LessonModel?>, $FutureProvider<LessonModel?> {
  /// The next uncompleted lesson in order, or null if all are complete.
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

String _$todayLessonHash() => r'774ffc3540c940bd7a15b792d141cacbecd430cb';

/// The lessons the learner has **finished**, in course order, each joined with
/// its module so the Learn screen can group them without re-querying.
///
/// Finished only, which the design has always said: the prototype titles this
/// section *"Completed work to revisit"* and builds it from the completed set
/// (`screens.jsx:864`), and ADR-0004 calls the group `Lessons` inside the
/// practice section. Listing every lesson — the app's previous behaviour — put
/// modules the learner has not unlocked one tap from being played.

@ProviderFor(completedLessonsWithModule)
final completedLessonsWithModuleProvider =
    CompletedLessonsWithModuleProvider._();

/// The lessons the learner has **finished**, in course order, each joined with
/// its module so the Learn screen can group them without re-querying.
///
/// Finished only, which the design has always said: the prototype titles this
/// section *"Completed work to revisit"* and builds it from the completed set
/// (`screens.jsx:864`), and ADR-0004 calls the group `Lessons` inside the
/// practice section. Listing every lesson — the app's previous behaviour — put
/// modules the learner has not unlocked one tap from being played.

final class CompletedLessonsWithModuleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LessonWithModule>>,
          List<LessonWithModule>,
          FutureOr<List<LessonWithModule>>
        >
    with
        $FutureModifier<List<LessonWithModule>>,
        $FutureProvider<List<LessonWithModule>> {
  /// The lessons the learner has **finished**, in course order, each joined with
  /// its module so the Learn screen can group them without re-querying.
  ///
  /// Finished only, which the design has always said: the prototype titles this
  /// section *"Completed work to revisit"* and builds it from the completed set
  /// (`screens.jsx:864`), and ADR-0004 calls the group `Lessons` inside the
  /// practice section. Listing every lesson — the app's previous behaviour — put
  /// modules the learner has not unlocked one tap from being played.
  CompletedLessonsWithModuleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedLessonsWithModuleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedLessonsWithModuleHash();

  @$internal
  @override
  $FutureProviderElement<List<LessonWithModule>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LessonWithModule>> create(Ref ref) {
    return completedLessonsWithModule(ref);
  }
}

String _$completedLessonsWithModuleHash() =>
    r'3393110394f9a8db8e6844e5e6fa57bb67c57257';
