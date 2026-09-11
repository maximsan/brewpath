// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_faq_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The FAQ, with the Foundations answer filled in once the banks have answered.
///
/// Synchronous on purpose: the four questions are always drawn, and only the
/// one answer that is counted waits — in its own row, never in front of the
/// list.

@ProviderFor(helpQuestions)
final helpQuestionsProvider = HelpQuestionsProvider._();

/// The FAQ, with the Foundations answer filled in once the banks have answered.
///
/// Synchronous on purpose: the four questions are always drawn, and only the
/// one answer that is counted waits — in its own row, never in front of the
/// list.

final class HelpQuestionsProvider
    extends
        $FunctionalProvider<
          List<HelpQuestion>,
          List<HelpQuestion>,
          List<HelpQuestion>
        >
    with $Provider<List<HelpQuestion>> {
  /// The FAQ, with the Foundations answer filled in once the banks have answered.
  ///
  /// Synchronous on purpose: the four questions are always drawn, and only the
  /// one answer that is counted waits — in its own row, never in front of the
  /// list.
  HelpQuestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'helpQuestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$helpQuestionsHash();

  @$internal
  @override
  $ProviderElement<List<HelpQuestion>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<HelpQuestion> create(Ref ref) {
    return helpQuestions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<HelpQuestion> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<HelpQuestion>>(value),
    );
  }
}

String _$helpQuestionsHash() => r'5bbdd189fd7cf25ea300a21c3685e14a810c6a8c';
