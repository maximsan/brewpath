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
    r'64682fd622b234541aa059a4ae7885aa303cf002';

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
