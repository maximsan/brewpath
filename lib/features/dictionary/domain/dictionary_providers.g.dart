// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the dictionary and the learner's completed lessons together.

@ProviderFor(dictionaryView)
final dictionaryViewProvider = DictionaryViewProvider._();

/// Loads the dictionary and the learner's completed lessons together.

final class DictionaryViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<DictionaryView>,
          DictionaryView,
          FutureOr<DictionaryView>
        >
    with $FutureModifier<DictionaryView>, $FutureProvider<DictionaryView> {
  /// Loads the dictionary and the learner's completed lessons together.
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

String _$dictionaryViewHash() => r'325ec489594e01ac4bdcd896411b91bc9a333cfa';

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
