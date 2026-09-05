// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).

@ProviderFor(moduleSummary)
final moduleSummaryProvider = ModuleSummaryFamily._();

/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).

final class ModuleSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ModuleSummary>,
          ModuleSummary,
          FutureOr<ModuleSummary>
        >
    with $FutureModifier<ModuleSummary>, $FutureProvider<ModuleSummary> {
  /// Builds the [ModuleSummary] for [moduleId] by joining content (module +
  /// cards) with persisted progress (collected cards).
  ModuleSummaryProvider._({
    required ModuleSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'moduleSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$moduleSummaryHash();

  @override
  String toString() {
    return r'moduleSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ModuleSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ModuleSummary> create(Ref ref) {
    final argument = this.argument as String;
    return moduleSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moduleSummaryHash() => r'2edde811d390d65bbf23d332c2feaa81b14b2df0';

/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).

final class ModuleSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ModuleSummary>, String> {
  ModuleSummaryFamily._()
    : super(
        retry: null,
        name: r'moduleSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Builds the [ModuleSummary] for [moduleId] by joining content (module +
  /// cards) with persisted progress (collected cards).

  ModuleSummaryProvider call(String moduleId) =>
      ModuleSummaryProvider._(argument: moduleId, from: this);

  @override
  String toString() => r'moduleSummaryProvider';
}

/// What [lessonId] paid, for the module ending to report.
///
/// Content only: the lesson's authored points.

@ProviderFor(moduleEndingRun)
final moduleEndingRunProvider = ModuleEndingRunFamily._();

/// What [lessonId] paid, for the module ending to report.
///
/// Content only: the lesson's authored points.

final class ModuleEndingRunProvider
    extends
        $FunctionalProvider<
          AsyncValue<ModuleEndingRun>,
          ModuleEndingRun,
          FutureOr<ModuleEndingRun>
        >
    with $FutureModifier<ModuleEndingRun>, $FutureProvider<ModuleEndingRun> {
  /// What [lessonId] paid, for the module ending to report.
  ///
  /// Content only: the lesson's authored points.
  ModuleEndingRunProvider._({
    required ModuleEndingRunFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'moduleEndingRunProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$moduleEndingRunHash();

  @override
  String toString() {
    return r'moduleEndingRunProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ModuleEndingRun> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ModuleEndingRun> create(Ref ref) {
    final argument = this.argument as String?;
    return moduleEndingRun(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleEndingRunProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moduleEndingRunHash() => r'3edad810f3c687c73d0f68a7ab2af7eda92bbdb6';

/// What [lessonId] paid, for the module ending to report.
///
/// Content only: the lesson's authored points.

final class ModuleEndingRunFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ModuleEndingRun>, String?> {
  ModuleEndingRunFamily._()
    : super(
        retry: null,
        name: r'moduleEndingRunProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What [lessonId] paid, for the module ending to report.
  ///
  /// Content only: the lesson's authored points.

  ModuleEndingRunProvider call(String? lessonId) =>
      ModuleEndingRunProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'moduleEndingRunProvider';
}
