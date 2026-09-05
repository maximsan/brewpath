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
    r'eb71ca0e1afe014bc66f2c92195dfbcddaaa5dda';

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

String _$todayLessonHash() => r'9cf8ce217bb6b8574bd949e7188e6d72caa27310';

/// Every lesson still ahead of the learner, course-wide.
///
/// **What the purchase opens, counted** — the figure Today's locked card
/// pitches with. Course-wide rather than a position inside one module: once
/// the wall is what the card is about, *lesson 4 of 7* says nothing about what
/// buying would give them.
///
/// Counted from the bank, never written down. A lesson authored into the
/// course changes this number by existing.
///
/// **Not the same figure as the gate sheet's `remainingLessons`**, which
/// counts what the free tier does not carry. They answer different questions —
/// how much course is left, and how much of it the purchase adds — and only
/// coincide for a learner who has finished exactly the free set. The design
/// asks the card for the first of the two.

@ProviderFor(lessonsAhead)
final lessonsAheadProvider = LessonsAheadProvider._();

/// Every lesson still ahead of the learner, course-wide.
///
/// **What the purchase opens, counted** — the figure Today's locked card
/// pitches with. Course-wide rather than a position inside one module: once
/// the wall is what the card is about, *lesson 4 of 7* says nothing about what
/// buying would give them.
///
/// Counted from the bank, never written down. A lesson authored into the
/// course changes this number by existing.
///
/// **Not the same figure as the gate sheet's `remainingLessons`**, which
/// counts what the free tier does not carry. They answer different questions —
/// how much course is left, and how much of it the purchase adds — and only
/// coincide for a learner who has finished exactly the free set. The design
/// asks the card for the first of the two.

final class LessonsAheadProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Every lesson still ahead of the learner, course-wide.
  ///
  /// **What the purchase opens, counted** — the figure Today's locked card
  /// pitches with. Course-wide rather than a position inside one module: once
  /// the wall is what the card is about, *lesson 4 of 7* says nothing about what
  /// buying would give them.
  ///
  /// Counted from the bank, never written down. A lesson authored into the
  /// course changes this number by existing.
  ///
  /// **Not the same figure as the gate sheet's `remainingLessons`**, which
  /// counts what the free tier does not carry. They answer different questions —
  /// how much course is left, and how much of it the purchase adds — and only
  /// coincide for a learner who has finished exactly the free set. The design
  /// asks the card for the first of the two.
  LessonsAheadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lessonsAheadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lessonsAheadHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return lessonsAhead(ref);
  }
}

String _$lessonsAheadHash() => r'3ccfffe4fc7bc055fc502980830830d9044e7aef';

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
    r'050654fa0e8a7cf3e305e202f2e7bf8b33a2c16b';
