// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_summary.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The learner's own figures for the seven measures Reset clears.
///
/// Every one is read through the provider the Profile tab reads, so the sheet
/// and the tab cannot disagree about what is about to be thrown away.

@ProviderFor(resetSummary)
final resetSummaryProvider = ResetSummaryProvider._();

/// The learner's own figures for the seven measures Reset clears.
///
/// Every one is read through the provider the Profile tab reads, so the sheet
/// and the tab cannot disagree about what is about to be thrown away.

final class ResetSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ResetMeasure>>,
          List<ResetMeasure>,
          FutureOr<List<ResetMeasure>>
        >
    with
        $FutureModifier<List<ResetMeasure>>,
        $FutureProvider<List<ResetMeasure>> {
  /// The learner's own figures for the seven measures Reset clears.
  ///
  /// Every one is read through the provider the Profile tab reads, so the sheet
  /// and the tab cannot disagree about what is about to be thrown away.
  ResetSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetSummaryHash();

  @$internal
  @override
  $FutureProviderElement<List<ResetMeasure>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ResetMeasure>> create(Ref ref) {
    return resetSummary(ref);
  }
}

String _$resetSummaryHash() => r'b30224b710fad68bdb79bfc1fef68a27d3b73ea9';
