// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the dictionary, the learner's completed lessons and their tier
/// together.
///
/// **The tier is awaited, not read as it stands.** The shelf is one value
/// that every dictionary surface — and the Saved shelf — resolves once and
/// keeps, so it waits for the answer rather than emitting a free shelf and
/// then a wider one: a paying learner would watch their reference terms
/// arrive a frame late, and a one-shot reader that finished on the first
/// emission would hold the wrong shelf for good. While it waits nothing is
/// shown, which is the same safe direction every gate resolves in.

@ProviderFor(dictionaryView)
final dictionaryViewProvider = DictionaryViewProvider._();

/// Loads the dictionary, the learner's completed lessons and their tier
/// together.
///
/// **The tier is awaited, not read as it stands.** The shelf is one value
/// that every dictionary surface — and the Saved shelf — resolves once and
/// keeps, so it waits for the answer rather than emitting a free shelf and
/// then a wider one: a paying learner would watch their reference terms
/// arrive a frame late, and a one-shot reader that finished on the first
/// emission would hold the wrong shelf for good. While it waits nothing is
/// shown, which is the same safe direction every gate resolves in.

final class DictionaryViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<DictionaryView>,
          DictionaryView,
          FutureOr<DictionaryView>
        >
    with $FutureModifier<DictionaryView>, $FutureProvider<DictionaryView> {
  /// Loads the dictionary, the learner's completed lessons and their tier
  /// together.
  ///
  /// **The tier is awaited, not read as it stands.** The shelf is one value
  /// that every dictionary surface — and the Saved shelf — resolves once and
  /// keeps, so it waits for the answer rather than emitting a free shelf and
  /// then a wider one: a paying learner would watch their reference terms
  /// arrive a frame late, and a one-shot reader that finished on the first
  /// emission would hold the wrong shelf for good. While it waits nothing is
  /// shown, which is the same safe direction every gate resolves in.
  DictionaryViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionaryViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionaryViewHash();

  @$internal
  @override
  $FutureProviderElement<DictionaryView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DictionaryView> create(Ref ref) {
    return dictionaryView(ref);
  }
}

String _$dictionaryViewHash() => r'1259ca50e681c4fc4dac31cb565e2e68af1839ba';

/// The title of the lesson [lessonId] names, or null when it names none.
///
/// A term's path block shows the lesson by title, not by id: "Where you
/// learned it → m1l2" is a database row, not an answer.

@ProviderFor(lessonTitle)
final lessonTitleProvider = LessonTitleFamily._();

/// The title of the lesson [lessonId] names, or null when it names none.
///
/// A term's path block shows the lesson by title, not by id: "Where you
/// learned it → m1l2" is a database row, not an answer.

final class LessonTitleProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The title of the lesson [lessonId] names, or null when it names none.
  ///
  /// A term's path block shows the lesson by title, not by id: "Where you
  /// learned it → m1l2" is a database row, not an answer.
  LessonTitleProvider._({
    required LessonTitleFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'lessonTitleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lessonTitleHash();

  @override
  String toString() {
    return r'lessonTitleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String?;
    return lessonTitle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LessonTitleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lessonTitleHash() => r'261011589d041a55f6b2243d0d16538dd2dc2f00';

/// The title of the lesson [lessonId] names, or null when it names none.
///
/// A term's path block shows the lesson by title, not by id: "Where you
/// learned it → m1l2" is a database row, not an answer.

final class LessonTitleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String?> {
  LessonTitleFamily._()
    : super(
        retry: null,
        name: r'lessonTitleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The title of the lesson [lessonId] names, or null when it names none.
  ///
  /// A term's path block shows the lesson by title, not by id: "Where you
  /// learned it → m1l2" is a database row, not an answer.

  LessonTitleProvider call(String? lessonId) =>
      LessonTitleProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'lessonTitleProvider';
}
