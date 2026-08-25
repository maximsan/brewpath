// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_guide_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide [VisualGuideRepository].

@ProviderFor(visualGuideRepository)
final visualGuideRepositoryProvider = VisualGuideRepositoryProvider._();

/// The app-wide [VisualGuideRepository].

final class VisualGuideRepositoryProvider
    extends
        $FunctionalProvider<
          VisualGuideRepository,
          VisualGuideRepository,
          VisualGuideRepository
        >
    with $Provider<VisualGuideRepository> {
  /// The app-wide [VisualGuideRepository].
  VisualGuideRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visualGuideRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visualGuideRepositoryHash();

  @$internal
  @override
  $ProviderElement<VisualGuideRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VisualGuideRepository create(Ref ref) {
    return visualGuideRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VisualGuideRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VisualGuideRepository>(value),
    );
  }
}

String _$visualGuideRepositoryHash() =>
    r'fecac13da40c626103c3af404bf11a910f573b70';

/// The guide covering [subject], earned or not.
///
/// Beside the repository rather than in either feature that reads it: the
/// Reference section and the lesson card both ask this question, and it is a
/// content lookup rather than a decision either of them owns.

@ProviderFor(visualGuideForSubject)
final visualGuideForSubjectProvider = VisualGuideForSubjectFamily._();

/// The guide covering [subject], earned or not.
///
/// Beside the repository rather than in either feature that reads it: the
/// Reference section and the lesson card both ask this question, and it is a
/// content lookup rather than a decision either of them owns.

final class VisualGuideForSubjectProvider
    extends
        $FunctionalProvider<
          AsyncValue<VisualGuide?>,
          VisualGuide?,
          FutureOr<VisualGuide?>
        >
    with $FutureModifier<VisualGuide?>, $FutureProvider<VisualGuide?> {
  /// The guide covering [subject], earned or not.
  ///
  /// Beside the repository rather than in either feature that reads it: the
  /// Reference section and the lesson card both ask this question, and it is a
  /// content lookup rather than a decision either of them owns.
  VisualGuideForSubjectProvider._({
    required VisualGuideForSubjectFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'visualGuideForSubjectProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visualGuideForSubjectHash();

  @override
  String toString() {
    return r'visualGuideForSubjectProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VisualGuide?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VisualGuide?> create(Ref ref) {
    final argument = this.argument as String;
    return visualGuideForSubject(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VisualGuideForSubjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visualGuideForSubjectHash() =>
    r'edcca849fdfb1d6d1e9f5faa6d5c96f28d4e9781';

/// The guide covering [subject], earned or not.
///
/// Beside the repository rather than in either feature that reads it: the
/// Reference section and the lesson card both ask this question, and it is a
/// content lookup rather than a decision either of them owns.

final class VisualGuideForSubjectFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VisualGuide?>, String> {
  VisualGuideForSubjectFamily._()
    : super(
        retry: null,
        name: r'visualGuideForSubjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The guide covering [subject], earned or not.
  ///
  /// Beside the repository rather than in either feature that reads it: the
  /// Reference section and the lesson card both ask this question, and it is a
  /// content lookup rather than a decision either of them owns.

  VisualGuideForSubjectProvider call(String subject) =>
      VisualGuideForSubjectProvider._(argument: subject, from: this);

  @override
  String toString() => r'visualGuideForSubjectProvider';
}
