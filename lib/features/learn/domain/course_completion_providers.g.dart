// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_completion_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the completion moment has already been acknowledged — one key in
/// the snapshot's `acks` map, cleared only by Reset Progress.

@ProviderFor(courseCompletionAcked)
final courseCompletionAckedProvider = CourseCompletionAckedProvider._();

/// Whether the completion moment has already been acknowledged — one key in
/// the snapshot's `acks` map, cleared only by Reset Progress.

final class CourseCompletionAckedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the completion moment has already been acknowledged — one key in
  /// the snapshot's `acks` map, cleared only by Reset Progress.
  CourseCompletionAckedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseCompletionAckedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseCompletionAckedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return courseCompletionAcked(ref);
  }
}

String _$courseCompletionAckedHash() =>
    r'1d83be471fb26732d6c50733283cb19980897390';

/// Whether the router should present the completion moment now: the course
/// derives as complete (no lesson anywhere is current), something was
/// actually completed, and the moment has not been acknowledged.

@ProviderFor(courseCompletionDue)
final courseCompletionDueProvider = CourseCompletionDueProvider._();

/// Whether the router should present the completion moment now: the course
/// derives as complete (no lesson anywhere is current), something was
/// actually completed, and the moment has not been acknowledged.

final class CourseCompletionDueProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the router should present the completion moment now: the course
  /// derives as complete (no lesson anywhere is current), something was
  /// actually completed, and the moment has not been acknowledged.
  CourseCompletionDueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseCompletionDueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseCompletionDueHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return courseCompletionDue(ref);
  }
}

String _$courseCompletionDueHash() =>
    r'5559492813d3202393917a0fefef9376c33291c9';
