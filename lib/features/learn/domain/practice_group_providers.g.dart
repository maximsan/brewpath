// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_group_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which practice groups are open on the Today tab.
///
/// Held outside the group's widget because two things move it: the header's
/// tap, and Keep Sharp's Start from the card above. Kept alive so the answer
/// survives the list unmounting a group scrolled far off-screen; never
/// stored, so both groups are shut on every launch, as the design has them.

@ProviderFor(OpenPracticeGroups)
final openPracticeGroupsProvider = OpenPracticeGroupsProvider._();

/// Which practice groups are open on the Today tab.
///
/// Held outside the group's widget because two things move it: the header's
/// tap, and Keep Sharp's Start from the card above. Kept alive so the answer
/// survives the list unmounting a group scrolled far off-screen; never
/// stored, so both groups are shut on every launch, as the design has them.
final class OpenPracticeGroupsProvider
    extends $NotifierProvider<OpenPracticeGroups, Set<PracticeGroupKind>> {
  /// Which practice groups are open on the Today tab.
  ///
  /// Held outside the group's widget because two things move it: the header's
  /// tap, and Keep Sharp's Start from the card above. Kept alive so the answer
  /// survives the list unmounting a group scrolled far off-screen; never
  /// stored, so both groups are shut on every launch, as the design has them.
  OpenPracticeGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openPracticeGroupsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openPracticeGroupsHash();

  @$internal
  @override
  OpenPracticeGroups create() => OpenPracticeGroups();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<PracticeGroupKind> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<PracticeGroupKind>>(value),
    );
  }
}

String _$openPracticeGroupsHash() =>
    r'99fdaa7efa187fce33796ee999d4ee6d1fe88779';

/// Which practice groups are open on the Today tab.
///
/// Held outside the group's widget because two things move it: the header's
/// tap, and Keep Sharp's Start from the card above. Kept alive so the answer
/// survives the list unmounting a group scrolled far off-screen; never
/// stored, so both groups are shut on every launch, as the design has them.

abstract class _$OpenPracticeGroups extends $Notifier<Set<PracticeGroupKind>> {
  Set<PracticeGroupKind> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<Set<PracticeGroupKind>, Set<PracticeGroupKind>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<PracticeGroupKind>, Set<PracticeGroupKind>>,
              Set<PracticeGroupKind>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
