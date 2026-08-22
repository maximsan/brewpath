// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freeze_save_notice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The covered day the Learn-tab save notice should announce, or null.
///
/// All watches happen before any await — a rebuild triggered mid-flight (the
/// dismiss invalidation does exactly this) must not find a watch on the far
/// side of an async gap.

@ProviderFor(freezeSaveNoticeDay)
final freezeSaveNoticeDayProvider = FreezeSaveNoticeDayProvider._();

/// The covered day the Learn-tab save notice should announce, or null.
///
/// All watches happen before any await — a rebuild triggered mid-flight (the
/// dismiss invalidation does exactly this) must not find a watch on the far
/// side of an async gap.

final class FreezeSaveNoticeDayProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// The covered day the Learn-tab save notice should announce, or null.
  ///
  /// All watches happen before any await — a rebuild triggered mid-flight (the
  /// dismiss invalidation does exactly this) must not find a watch on the far
  /// side of an async gap.
  FreezeSaveNoticeDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'freezeSaveNoticeDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$freezeSaveNoticeDayHash();

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    return freezeSaveNoticeDay(ref);
  }
}

String _$freezeSaveNoticeDayHash() =>
    r'317a628cd3cbf65966721c261bab314598e3b702';
