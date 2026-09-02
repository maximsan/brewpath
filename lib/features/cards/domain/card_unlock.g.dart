// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_unlock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The title of the lesson that awards a card, or null when none does.

@ProviderFor(cardUnlockLessonTitle)
final cardUnlockLessonTitleProvider = CardUnlockLessonTitleFamily._();

/// The title of the lesson that awards a card, or null when none does.

final class CardUnlockLessonTitleProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The title of the lesson that awards a card, or null when none does.
  CardUnlockLessonTitleProvider._({
    required CardUnlockLessonTitleFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'cardUnlockLessonTitleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardUnlockLessonTitleHash();

  @override
  String toString() {
    return r'cardUnlockLessonTitleProvider'
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
    return cardUnlockLessonTitle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CardUnlockLessonTitleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardUnlockLessonTitleHash() =>
    r'0553d49e22b4c38fa07e5a37c3d6b9a5fc9dbe87';

/// The title of the lesson that awards a card, or null when none does.

final class CardUnlockLessonTitleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String?> {
  CardUnlockLessonTitleFamily._()
    : super(
        retry: null,
        name: r'cardUnlockLessonTitleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The title of the lesson that awards a card, or null when none does.

  CardUnlockLessonTitleProvider call(String? lessonId) =>
      CardUnlockLessonTitleProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'cardUnlockLessonTitleProvider';
}
