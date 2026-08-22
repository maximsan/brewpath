import 'dart:typed_data';

/// Presents a rendered image through the platform's share UI.
///
/// The one seam in front of `share_plus` (#237): the streak screen hands
/// bytes to this interface, tests hand it a recorder, and no widget ever
/// touches the plugin directly — the no-op payments/ads precedent.
// One member by design: the seam exists to be faked and swapped (#237),
// which a bare function type cannot express as a provider contract.
// ignore: one_member_abstracts
abstract interface class SharePresenter {
  /// Offers [bytes] (a PNG) to the platform share sheet as [fileName].
  Future<void> sharePng({required Uint8List bytes, required String fileName});
}

/// A presenter that presents nothing — tests and inactive contexts.
class NoOpSharePresenter implements SharePresenter {
  /// Creates a [NoOpSharePresenter].
  const NoOpSharePresenter();

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
  }) async {}
}
