// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_faq_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The FAQ with its counts filled in from the shipped banks.
///
/// Joins here so [helpFaq] stays a pure function of three values, and a wrong
/// count fails in a unit test rather than on the screen.

@ProviderFor(helpQuestions)
final helpQuestionsProvider = HelpQuestionsProvider._();

/// The FAQ with its counts filled in from the shipped banks.
///
/// Joins here so [helpFaq] stays a pure function of three values, and a wrong
/// count fails in a unit test rather than on the screen.

final class HelpQuestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HelpQuestion>>,
          List<HelpQuestion>,
          FutureOr<List<HelpQuestion>>
        >
    with
        $FutureModifier<List<HelpQuestion>>,
        $FutureProvider<List<HelpQuestion>> {
  /// The FAQ with its counts filled in from the shipped banks.
  ///
  /// Joins here so [helpFaq] stays a pure function of three values, and a wrong
  /// count fails in a unit test rather than on the screen.
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
  $FutureProviderElement<List<HelpQuestion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HelpQuestion>> create(Ref ref) {
    return helpQuestions(ref);
  }
}

String _$helpQuestionsHash() => r'3c7357f60718ceeed7c2f1753130cbf0edcfc43e';
