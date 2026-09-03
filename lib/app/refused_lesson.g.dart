// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refused_lesson.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app-lifetime [RefusedLesson].
///
/// Function-style despite holding mutable state, because the mutation is the
/// object's own and must not rebuild the router — see [RefusedLesson].

@ProviderFor(refusedLesson)
final refusedLessonProvider = RefusedLessonProvider._();

/// Provides the app-lifetime [RefusedLesson].
///
/// Function-style despite holding mutable state, because the mutation is the
/// object's own and must not rebuild the router — see [RefusedLesson].

final class RefusedLessonProvider
    extends $FunctionalProvider<RefusedLesson, RefusedLesson, RefusedLesson>
    with $Provider<RefusedLesson> {
  /// Provides the app-lifetime [RefusedLesson].
  ///
  /// Function-style despite holding mutable state, because the mutation is the
  /// object's own and must not rebuild the router — see [RefusedLesson].
  RefusedLessonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refusedLessonProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refusedLessonHash();

  @$internal
  @override
  $ProviderElement<RefusedLesson> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RefusedLesson create(Ref ref) {
    return refusedLesson(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefusedLesson value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefusedLesson>(value),
    );
  }
}

String _$refusedLessonHash() => r'248c2d78642d89af2688f375a4dd65ef4585a762';
