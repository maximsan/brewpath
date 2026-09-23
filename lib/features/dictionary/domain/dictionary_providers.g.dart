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
/// The tier is awaited, not read as it stands: emitting a free shelf and then
/// a wider one would show a paying learner their reference terms a frame late
/// and leave a one-shot reader holding the wrong shelf for good.

@ProviderFor(dictionaryView)
final dictionaryViewProvider = DictionaryViewProvider._();

/// Loads the dictionary, the learner's completed lessons and their tier
/// together.
///
/// The tier is awaited, not read as it stands: emitting a free shelf and then
/// a wider one would show a paying learner their reference terms a frame late
/// and leave a one-shot reader holding the wrong shelf for good.

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
  /// The tier is awaited, not read as it stands: emitting a free shelf and then
  /// a wider one would show a paying learner their reference terms a frame late
  /// and leave a one-shot reader holding the wrong shelf for good.
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

/// The surface forms lesson copy may link, compiled once.
///
/// Off the learner's own view rather than the raw bank (#217), so a free
/// learner is never handed a link to an entry the view does not hold.

@ProviderFor(termLinkIndex)
final termLinkIndexProvider = TermLinkIndexProvider._();

/// The surface forms lesson copy may link, compiled once.
///
/// Off the learner's own view rather than the raw bank (#217), so a free
/// learner is never handed a link to an entry the view does not hold.

final class TermLinkIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<TermLinkIndex>,
          TermLinkIndex,
          FutureOr<TermLinkIndex>
        >
    with $FutureModifier<TermLinkIndex>, $FutureProvider<TermLinkIndex> {
  /// The surface forms lesson copy may link, compiled once.
  ///
  /// Off the learner's own view rather than the raw bank (#217), so a free
  /// learner is never handed a link to an entry the view does not hold.
  TermLinkIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'termLinkIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$termLinkIndexHash();

  @$internal
  @override
  $FutureProviderElement<TermLinkIndex> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TermLinkIndex> create(Ref ref) {
    return termLinkIndex(ref);
  }
}

String _$termLinkIndexHash() => r'5449b29bcfd7b1676e2ed3bfea2c863525a1a17b';

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

/// The entry's path row draws the lesson with its module's picture, so the
/// row is looked up through the modules rather than the lesson bank.

@ProviderFor(lessonPlace)
final lessonPlaceProvider = LessonPlaceFamily._();

/// The entry's path row draws the lesson with its module's picture, so the
/// row is looked up through the modules rather than the lesson bank.

final class LessonPlaceProvider
    extends
        $FunctionalProvider<
          AsyncValue<LessonPlace?>,
          LessonPlace?,
          FutureOr<LessonPlace?>
        >
    with $FutureModifier<LessonPlace?>, $FutureProvider<LessonPlace?> {
  /// The entry's path row draws the lesson with its module's picture, so the
  /// row is looked up through the modules rather than the lesson bank.
  LessonPlaceProvider._({
    required LessonPlaceFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'lessonPlaceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lessonPlaceHash();

  @override
  String toString() {
    return r'lessonPlaceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LessonPlace?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LessonPlace?> create(Ref ref) {
    final argument = this.argument as String?;
    return lessonPlace(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LessonPlaceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lessonPlaceHash() => r'f527996924cfa1a7830ef25ec358ef23bb571f26';

/// The entry's path row draws the lesson with its module's picture, so the
/// row is looked up through the modules rather than the lesson bank.

final class LessonPlaceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LessonPlace?>, String?> {
  LessonPlaceFamily._()
    : super(
        retry: null,
        name: r'lessonPlaceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The entry's path row draws the lesson with its module's picture, so the
  /// row is looked up through the modules rather than the lesson bank.

  LessonPlaceProvider call(String? lessonId) =>
      LessonPlaceProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'lessonPlaceProvider';
}
