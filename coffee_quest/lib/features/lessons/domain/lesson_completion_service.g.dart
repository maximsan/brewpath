// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_completion_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [LessonCompletionService] with its dependencies wired in.

@ProviderFor(lessonCompletionService)
final lessonCompletionServiceProvider = LessonCompletionServiceProvider._();

/// Provides the [LessonCompletionService] with its dependencies wired in.

final class LessonCompletionServiceProvider
    extends
        $FunctionalProvider<
          LessonCompletionService,
          LessonCompletionService,
          LessonCompletionService
        >
    with $Provider<LessonCompletionService> {
  /// Provides the [LessonCompletionService] with its dependencies wired in.
  LessonCompletionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lessonCompletionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lessonCompletionServiceHash();

  @$internal
  @override
  $ProviderElement<LessonCompletionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LessonCompletionService create(Ref ref) {
    return lessonCompletionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LessonCompletionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LessonCompletionService>(value),
    );
  }
}

String _$lessonCompletionServiceHash() =>
    r'eef47426bc9bc5f97d4e619634ff227c312a6879';
