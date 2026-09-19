// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_summary.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The learner's own figures for the seven measures Reset clears.
///
/// **Their numbers, not an inventory of storage fields** — seeing *12 days* is
/// what makes someone stop. Every one is a measure Profile already shows, read
/// through the same providers so the sheet and the tab cannot disagree.

@ProviderFor(resetSummary)
final resetSummaryProvider = ResetSummaryProvider._();

/// The learner's own figures for the seven measures Reset clears.
///
/// **Their numbers, not an inventory of storage fields** — seeing *12 days* is
/// what makes someone stop. Every one is a measure Profile already shows, read
/// through the same providers so the sheet and the tab cannot disagree.

final class ResetSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConfirmLine>>,
          List<ConfirmLine>,
          FutureOr<List<ConfirmLine>>
        >
    with
        $FutureModifier<List<ConfirmLine>>,
        $FutureProvider<List<ConfirmLine>> {
  /// The learner's own figures for the seven measures Reset clears.
  ///
  /// **Their numbers, not an inventory of storage fields** — seeing *12 days* is
  /// what makes someone stop. Every one is a measure Profile already shows, read
  /// through the same providers so the sheet and the tab cannot disagree.
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
  $FutureProviderElement<List<ConfirmLine>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConfirmLine>> create(Ref ref) {
    return resetSummary(ref);
  }
}

String _$resetSummaryHash() => r'03bc8ac62884dd2ba4d83fa5520df57f0500d5db';
